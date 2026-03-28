import '../core/chain/chain_config.dart';
import '../core/constants/donation_constants.dart';
import '../data/models/transaction.dart';
import 'address_service.dart';
import 'local_signer_service.dart';
import 'rpc_service.dart';

class TransactionService {
  final RpcService _rpcService;
  final AddressService _addressService;
  final LocalSignerService _localSignerService;

  TransactionService({
    required RpcService rpcService,
    required AddressService addressService,
    LocalSignerService? localSignerService,
  })  : _rpcService = rpcService,
        _addressService = addressService,
        _localSignerService = localSignerService ?? LocalSignerService();

  Future<UnsignedTransaction> buildTransaction({
    required String toAddress,
    required int sendAmount,
    required String fromAddress,
    required int feeRate,
    required ChainConfig chain,
    int minConfirmations = 1,
  }) async {
    if (!_addressService.validateAddress(toAddress, chain: chain)) {
      throw TransactionException('Invalid recipient address');
    }

    if (feeRate < TransactionConstants.minFeeRate ||
        feeRate > TransactionConstants.maxFeeRate) {
      throw TransactionException('Invalid fee rate');
    }

    if (DonationConstants.requiresMinimumDonation(sendAmount)) {
      throw TransactionException('当前金额过低，无法满足最小捐赠输出要求');
    }

    final donationAmount = DonationConstants.calculateDonationFee(sendAmount);
    final outputs = <TxOutput>[
      TxOutput(
        address: toAddress,
        amount: sendAmount,
        index: 0,
      ),
      if (donationAmount > 0)
        TxOutput(
          address: DonationConstants.donationAddress,
          amount: donationAmount,
          index: 1,
          isDonation: true,
        ),
    ];

    final utxos = await _rpcService.listUnspent();
    final eligible = utxos
        .where((utxo) => utxo.confirmations >= minConfirmations)
        .toList()
      ..sort((left, right) => left.amount.compareTo(right.amount));

    if (eligible.isEmpty) {
      throw TransactionException('No eligible UTXOs found');
    }

    final selectedUtxos = <Utxo>[];
    var selectedAmount = 0;
    var estimatedFee = calculateFee(1, outputs.length + 1, feeRate);
    final totalNeeded = sendAmount + donationAmount;

    for (final utxo in eligible) {
      selectedUtxos.add(utxo);
      selectedAmount += utxo.amount;
      estimatedFee = calculateFee(selectedUtxos.length, outputs.length + 1, feeRate);
      if (selectedAmount >= totalNeeded + estimatedFee) {
        break;
      }
    }

    if (selectedAmount < totalNeeded + estimatedFee) {
      throw TransactionException(
        'Insufficient funds: need ${totalNeeded + estimatedFee}, have $selectedAmount',
      );
    }

    final changeAmount = selectedAmount - totalNeeded - estimatedFee;
    if (changeAmount > 0) {
      outputs.add(
        TxOutput(
          address: fromAddress,
          amount: changeAmount,
          index: outputs.length,
          isChange: true,
        ),
      );
    }

    final inputs = selectedUtxos
        .map(
          (utxo) => TxInput(
            txid: utxo.txid,
            vout: utxo.vout,
            scriptSig: '',
            address: utxo.address,
            amount: utxo.amount,
            scriptPubKey: utxo.scriptPubKey,
          ),
        )
        .toList();

    final rawHex = await _rpcService.createRawTransaction(
      inputs: inputs,
      outputs: outputs,
    );

    return UnsignedTransaction(
      rawHex: rawHex,
      inputs: inputs,
      outputs: outputs,
      fee: estimatedFee,
      donationFee: donationAmount,
      sendAmount: sendAmount,
      totalCost: sendAmount + donationAmount + estimatedFee,
      toAddress: toAddress,
      fromAddress: fromAddress,
    );
  }

  SignedTransaction signTransaction({
    required UnsignedTransaction unsignedTx,
    required String privateKeyHex,
    required String publicKeyHex,
  }) {
    if (privateKeyHex.isEmpty || publicKeyHex.isEmpty) {
      throw TransactionException('Missing local signing material');
    }

    final hasDonation = unsignedTx.outputs.any(
      (output) =>
          output.isDonation &&
          output.address == DonationConstants.donationAddress &&
          output.amount == unsignedTx.donationFee,
    );

    if (!hasDonation) {
      throw TransactionException('Donation output is missing from transaction');
    }

    final signature = _localSignerService.signAuthorization(
      transaction: unsignedTx,
      privateKeyHex: privateKeyHex,
      publicKeyHex: publicKeyHex,
    );

    final signedTransaction = SignedTransaction(
      transaction: unsignedTx,
      authorizationSignature: signature,
    );

    final isValid = _localSignerService.verifyAuthorization(
      transaction: unsignedTx,
      signature: signature,
    );

    if (!isValid) {
      throw TransactionException('Local authorization signature verification failed');
    }

    return signedTransaction;
  }

  Future<String> signAndBroadcast({
    required UnsignedTransaction unsignedTx,
    required String privateKeyHex,
    required String publicKeyHex,
  }) async {
    signTransaction(
      unsignedTx: unsignedTx,
      privateKeyHex: privateKeyHex,
      publicKeyHex: publicKeyHex,
    );
    return _rpcService.sendRawTransaction(unsignedTx.rawHex);
  }

  Future<String> broadcastTransaction(String signedHex) async {
    return _rpcService.sendRawTransaction(signedHex);
  }

  int calculateFee(int inputs, int outputs, int feeRate) {
    final size = _estimateTransactionSize(inputs, outputs);
    return size * feeRate;
  }

  int calculateDonationFee(int amount) {
    return DonationConstants.calculateDonationFee(amount);
  }

  TxPreview createPreview(UnsignedTransaction transaction, {required String network}) {
    return TxPreview(
      toAddress: transaction.toAddress,
      donationAddress: DonationConstants.donationAddress,
      sendAmount: transaction.sendAmount,
      donationAmount: transaction.donationFee,
      fee: transaction.fee,
      totalCost: transaction.totalCost,
      changeAmount: transaction.changeAmount,
      network: network,
    );
  }

  int _estimateTransactionSize(int inputs, int outputs) {
    return (inputs * 180) + (outputs * 34) + 10 + inputs;
  }
}

class TransactionException implements Exception {
  final String message;

  TransactionException(this.message);

  @override
  String toString() => 'TransactionException: $message';
}
