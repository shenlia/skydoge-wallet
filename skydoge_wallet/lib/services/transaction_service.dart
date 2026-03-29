import '../core/constants/donation_constants.dart';
import '../core/transaction/tx_preview.dart';
import '../data/models/transaction.dart';
import 'rpc_service.dart';
import 'address_service.dart';

class TransactionService {
  final RpcService _rpcService;
  final AddressService _addressService;

  TransactionService({
    required RpcService rpcService,
    required AddressService addressService,
  })  : _rpcService = rpcService,
        _addressService = addressService;

  Future<UnsignedTransaction> buildTransaction({
    required String toAddress,
    required int amount,
    required String fromAddress,
    required int feeRate,
    int minConfirmations = 1,
  }) async {
    if (!_addressService.validateAddress(toAddress)) {
      throw TransactionException('Invalid recipient address');
    }

    if (feeRate < TransactionConstants.minFeeRate || feeRate > TransactionConstants.maxFeeRate) {
      throw TransactionException('Invalid fee rate');
    }

    final utxos = await _rpcService.listUnspent();
    final eligibleUtxos = utxos.where((utxo) => utxo.confirmations >= minConfirmations).toList();

    if (eligibleUtxos.isEmpty) {
      throw TransactionException('No eligible UTXOs found');
    }

    final donationFee = DonationConstants.calculateDonationAmount(amount);
    if (DonationConstants.isDonationDust(amount)) {
      throw TransactionException(
        'Current amount is too low to satisfy the minimum donation output requirement',
      );
    }

    final outputCount = 3;
    final fee = _estimateTransactionSize(1, outputCount) * feeRate;
    final totalNeeded = amount + donationFee + fee;
    final List<Utxo> selectedUtxos = [];
    int selectedAmount = 0;

    for (final utxo in eligibleUtxos) {
      selectedUtxos.add(utxo);
      selectedAmount += utxo.amount;
      if (selectedAmount >= totalNeeded) break;
    }

    if (selectedAmount < totalNeeded) {
      throw TransactionException('Insufficient funds: need $totalNeeded, have $selectedAmount');
    }

    final inputs = selectedUtxos.map((utxo) => TxInput(
      txid: utxo.txid,
      vout: utxo.vout,
      scriptSig: '',
      address: utxo.address,
      amount: utxo.amount,
    )).toList();

    final outputs = <TxOutput>[
      TxOutput(
        address: toAddress,
        amount: amount,
        index: 0,
        isDonation: false,
      ),
    ];

    if (donationFee > 0) {
      outputs.add(TxOutput(
        address: DonationConstants.donationAddress,
        amount: donationFee,
        index: 1,
        isDonation: true,
      ));
    }

    final estimatedSize = _estimateTransactionSize(inputs.length, outputs.length + 1);
    final actualFee = estimatedSize * feeRate;
    final change = selectedAmount - amount - donationFee - actualFee;
    if (change > 0) {
      outputs.add(TxOutput(
        address: fromAddress,
        amount: change,
        index: outputs.length,
        isDonation: false,
      ));
    }

    final rawTx = await _rpcService.createRawTransaction(
      inputs: inputs,
      outputs: outputs,
    );

    return UnsignedTransaction(
      rawHex: rawTx,
      inputs: inputs,
      outputs: outputs,
      fee: actualFee,
      donationFee: donationFee,
      network: _rpcService.isTestnet ? 'testnet' : 'mainnet',
    );
  }

  TxPreview buildPreview({
    required String toAddress,
    required int sendAmount,
    required int donationAmount,
    required int fee,
    required int changeAmount,
  }) {
    return TxPreview(
      toAddress: toAddress,
      sendAmount: sendAmount,
      donationAmount: donationAmount,
      donationAddress: DonationConstants.donationAddress,
      fee: fee,
      totalCost: sendAmount + donationAmount + fee,
      changeAmount: changeAmount,
      network: _rpcService.isTestnet ? 'testnet' : 'mainnet',
    );
  }

  Future<String> signAndBroadcast({
    required UnsignedTransaction unsignedTx,
    required String privateKeyHex,
  }) async {
    try {
      final signedTx = await _rpcService.signRawTransaction(unsignedTx.rawHex);
      final txid = await _rpcService.sendRawTransaction(signedTx);
      return txid;
    } catch (e) {
      throw TransactionException(
        'Failed to sign and broadcast locally prepared transaction: $e',
      );
    }
  }

  Future<String> broadcastTransaction(String signedHex) async {
    return await _rpcService.sendRawTransaction(signedHex);
  }

  int _estimateTransactionSize(int inputs, int outputs) {
    return (inputs * 180) + (outputs * 34) + 10 + inputs;
  }

  int calculateFee(int inputs, int outputs, int feeRate) {
    final size = _estimateTransactionSize(inputs, outputs);
    return size * feeRate;
  }

  int calculateDonationFee(int amount) {
    return DonationConstants.calculateDonationAmount(amount);
  }
}

class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);

  @override
  String toString() => 'TransactionException: $message';
}
