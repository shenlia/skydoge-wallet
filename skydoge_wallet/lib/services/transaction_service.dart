import 'dart:typed_data';
import 'package:hex/hex.dart';
import '../core/constants/donation_constants.dart';
import '../core/constants/network_constants.dart';
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
    bool includeDonation = true,
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

    final donationFee = includeDonation 
        ? DonationConstants.calculateDonationFee(amount)
        : 0;

    if (includeDonation && DonationConstants.isDonationBelowDust(amount)) {
      throw TransactionException(DonationConstants.getDonationBelowDustWarning());
    }

    final recipientAmount = amount;
    final totalOutput = recipientAmount + donationFee;

    int estimatedFee = 0;
    int selectedAmount = 0;
    final List<Utxo> selectedUtxos = [];

    for (final utxo in eligibleUtxos) {
      selectedUtxos.add(utxo);
      selectedAmount += utxo.amount;
      estimatedFee = _estimateTransactionSize(selectedUtxos.length, totalOutput > 0 ? 2 : 1) * feeRate;
      
      if (selectedAmount >= totalOutput + estimatedFee) break;
    }

    if (selectedAmount < totalOutput + estimatedFee) {
      throw TransactionException('Insufficient funds: need ${totalOutput + estimatedFee}, have $selectedAmount');
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
        amount: recipientAmount,
        index: 0,
        isDonation: false,
      ),
    ];

    if (includeDonation && donationFee > 0) {
      outputs.add(TxOutput(
        address: DonationConstants.donationAddress,
        amount: donationFee,
        index: 1,
        isDonation: true,
      ));
    }

    final estimatedSize = _estimateTransactionSize(inputs.length, outputs.length);
    final fee = estimatedSize * feeRate;

    final change = selectedAmount - totalOutput - fee;
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
      txid: rawTx,
      inputs: inputs,
      outputs: outputs,
      fee: fee,
      donationFee: donationFee,
    );
  }

  Future<String> signAndBroadcast({
    required UnsignedTransaction unsignedTx,
    required String privateKeyHex,
  }) async {
    try {
      final fundedTx = await _rpcService.fundRawTransaction(unsignedTx.txid);
      final signedTx = await _rpcService.signRawTransaction(fundedTx);
      final txid = await _rpcService.sendRawTransaction(signedTx);
      return txid;
    } catch (e) {
      throw TransactionException('Failed to sign and broadcast: $e');
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
    return DonationConstants.calculateDonationFee(amount);
  }
}

class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);

  @override
  String toString() => 'TransactionException: $message';
}
