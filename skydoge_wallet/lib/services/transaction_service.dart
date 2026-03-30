import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';

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

  String get _donationAddress => DonationConstants.donationAddressForNetwork(_rpcService.isTestnet);

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
    _assertSupportedOutputAddress(toAddress);

    if (!_addressService.validateAddress(fromAddress)) {
      throw TransactionException('Invalid change address');
    }
    _assertSupportedOutputAddress(fromAddress);

    if (feeRate < TransactionConstants.minFeeRate || feeRate > TransactionConstants.maxFeeRate) {
      throw TransactionException('Invalid fee rate');
    }

    final utxos = await _rpcService.listUnspent();
    final eligibleUtxos = utxos.where(
      (utxo) =>
          utxo.confirmations >= minConfirmations &&
          _isLocallySignableUtxo(utxo, fromAddress: fromAddress),
    ).toList();

    if (eligibleUtxos.isEmpty) {
      throw TransactionException('No eligible locally signable UTXOs found');
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
      scriptPubKey: utxo.scriptPubKey,
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
      _assertSupportedOutputAddress(_donationAddress);
      outputs.add(TxOutput(
        address: _donationAddress,
        amount: donationFee,
        index: 1,
        isDonation: true,
      ));
    }

    final estimatedSize = _estimateTransactionSize(inputs.length, outputs.length + 1);
    final actualFee = estimatedSize * feeRate;
    var effectiveFee = actualFee;
    final change = selectedAmount - amount - donationFee - actualFee;
    if (change >= DonationConstants.minDonationOutput) {
      outputs.add(TxOutput(
        address: fromAddress,
        amount: change,
        index: outputs.length,
        isDonation: false,
      ));
    } else if (change > 0) {
      effectiveFee += change;
    }

    final rawTx = _serializeUnsignedTransaction(
      inputs: inputs,
      outputs: outputs,
    );

    return UnsignedTransaction(
      rawHex: rawTx,
      inputs: inputs,
      outputs: outputs,
      fee: effectiveFee,
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
      donationAddress: _donationAddress,
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
      final signedTx = await signLocally(
        unsignedTx: unsignedTx,
        privateKeyHex: privateKeyHex,
      );
      final txid = await _rpcService.sendRawTransaction(signedTx);
      return txid;
    } catch (e) {
      throw TransactionException(
        'Failed to sign and broadcast locally prepared transaction: $e',
      );
    }
  }

  Future<String> signLocally({
    required UnsignedTransaction unsignedTx,
    required String privateKeyHex,
  }) async {
    if (privateKeyHex.isEmpty) {
      throw TransactionException('Missing private key for local signing');
    }

    final expectedAddress = _addressService.getAddressFromPrivateKey(
      privateKeyHex,
      isTestnet: _rpcService.isTestnet,
    );
    final publicKeyHex = _addressService.getPublicKeyFromPrivateKey(privateKeyHex);

    for (var index = 0; index < unsignedTx.inputs.length; index++) {
      final input = unsignedTx.inputs[index];
      if (input.scriptPubKey.isEmpty) {
        throw TransactionException('Missing scriptPubKey for local signing');
      }

      if (!_isSupportedP2pkhInputScript(input.scriptPubKey)) {
        throw TransactionException('Unsupported input scriptPubKey for local signing');
      }

      if (input.address.isNotEmpty && input.address != expectedAddress) {
        throw TransactionException(
          'Input address does not match the locally held private key',
        );
      }
    }

    final scriptSigs = <String>[];
    for (var index = 0; index < unsignedTx.inputs.length; index++) {
      final digest = _signatureHash(
        inputs: unsignedTx.inputs,
        outputs: unsignedTx.outputs,
        inputIndex: index,
      );
      final signature = _signDigest(
        privateKeyHex: privateKeyHex,
        digest: digest,
      );
      final signatureWithHashType = Uint8List.fromList([...signature, 0x01]);
      final publicKeyBytes = Uint8List.fromList(HEX.decode(publicKeyHex));
      final scriptSig = _pushData(signatureWithHashType) + _pushData(publicKeyBytes);
      scriptSigs.add(HEX.encode(scriptSig));
    }

    return _serializeSignedTransaction(
      inputs: unsignedTx.inputs,
      outputs: unsignedTx.outputs,
      scriptSigs: scriptSigs,
    );
  }

  Future<String> broadcastTransaction(String signedHex) async {
    if (!_looksLikeSignedTransaction(signedHex)) {
      throw TransactionException('Refusing to broadcast transaction that does not look signed');
    }

    return await _rpcService.sendRawTransaction(signedHex);
  }

  int _estimateTransactionSize(int inputs, int outputs) {
    return (inputs * 180) + (outputs * 34) + 10 + inputs;
  }

  String _serializeUnsignedTransaction({
    required List<TxInput> inputs,
    required List<TxOutput> outputs,
  }) {
    return _serializeTransaction(
      inputs: inputs,
      outputs: outputs,
      scriptSigs: List<String>.filled(inputs.length, ''),
    );
  }

  String _serializeSignedTransaction({
    required List<TxInput> inputs,
    required List<TxOutput> outputs,
    required List<String> scriptSigs,
  }) {
    return _serializeTransaction(
      inputs: inputs,
      outputs: outputs,
      scriptSigs: scriptSigs,
    );
  }

  String _serializeTransaction({
    required List<TxInput> inputs,
    required List<TxOutput> outputs,
    required List<String> scriptSigs,
  }) {
    final bytes = <int>[];
    bytes.addAll(_uint32LE(1));
    bytes.addAll(_varInt(inputs.length));

    for (var index = 0; index < inputs.length; index++) {
      final input = inputs[index];
      bytes.addAll(HEX.decode(_reverseHex(input.txid)));
      bytes.addAll(_uint32LE(input.vout));

      final script = scriptSigs[index].isEmpty ? <int>[] : HEX.decode(scriptSigs[index]);
      bytes.addAll(_varInt(script.length));
      bytes.addAll(script);
      bytes.addAll(_uint32LE(input.sequence));
    }

    bytes.addAll(_varInt(outputs.length));
    for (final output in outputs) {
      bytes.addAll(_uint64LE(output.amount));
      final scriptPubKey = _outputScriptForAddress(output.address);
      bytes.addAll(_varInt(scriptPubKey.length));
      bytes.addAll(scriptPubKey);
    }

    bytes.addAll(_uint32LE(0));
    return HEX.encode(bytes);
  }

  Uint8List _signatureHash({
    required List<TxInput> inputs,
    required List<TxOutput> outputs,
    required int inputIndex,
  }) {
    final bytes = <int>[];
    bytes.addAll(_uint32LE(1));
    bytes.addAll(_varInt(inputs.length));

    for (var index = 0; index < inputs.length; index++) {
      final input = inputs[index];
      bytes.addAll(HEX.decode(_reverseHex(input.txid)));
      bytes.addAll(_uint32LE(input.vout));

      final script = index == inputIndex ? HEX.decode(input.scriptPubKey) : <int>[];
      bytes.addAll(_varInt(script.length));
      bytes.addAll(script);
      bytes.addAll(_uint32LE(input.sequence));
    }

    bytes.addAll(_varInt(outputs.length));
    for (final output in outputs) {
      bytes.addAll(_uint64LE(output.amount));
      final scriptPubKey = _outputScriptForAddress(output.address);
      bytes.addAll(_varInt(scriptPubKey.length));
      bytes.addAll(scriptPubKey);
    }

    bytes.addAll(_uint32LE(0));
    bytes.addAll(_uint32LE(1));
    return _doubleSha256(Uint8List.fromList(bytes));
  }

  Uint8List _signDigest({
    required String privateKeyHex,
    required Uint8List digest,
  }) {
    final domain = ECDomainParameters('secp256k1');
    final privateKey = ECPrivateKey(BigInt.parse(privateKeyHex, radix: 16), domain);
    final signer = ECDSASigner(null, HMac(SHA256Digest(), 64));
    signer.init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));

    var signature = signer.generateSignature(digest) as ECSignature;
    final halfCurveOrder = domain.n >> 1;
    if (signature.s > halfCurveOrder) {
      signature = ECSignature(signature.r, domain.n - signature.s);
    }

    return _encodeDer(signature);
  }

  Uint8List _encodeDer(ECSignature signature) {
    final r = _encodeDerInteger(signature.r);
    final s = _encodeDerInteger(signature.s);
    return Uint8List.fromList([0x30, r.length + s.length, ...r, ...s]);
  }

  List<int> _encodeDerInteger(BigInt value) {
    var bytes = _bigIntToBytes(value);
    if (bytes.isEmpty) {
      bytes = Uint8List.fromList([0]);
    }
    if (bytes.first & 0x80 != 0) {
      bytes = Uint8List.fromList([0, ...bytes]);
    }
    return [0x02, bytes.length, ...bytes];
  }

  Uint8List _bigIntToBytes(BigInt value) {
    if (value == BigInt.zero) {
      return Uint8List(0);
    }

    final bytes = <int>[];
    var current = value;
    while (current > BigInt.zero) {
      bytes.insert(0, (current & BigInt.from(0xff)).toInt());
      current = current >> 8;
    }
    return Uint8List.fromList(bytes);
  }

  List<int> _outputScriptForAddress(String address) {
    _assertSupportedOutputAddress(address);

    final decoded = _base58Decode(address);
    if (decoded.length < 25) {
      throw TransactionException('Unsupported address format for local signing');
    }

    final hash160 = decoded.sublist(1, 21);
    if (address.startsWith('3') || address.startsWith('2')) {
      return [0xa9, 0x14, ...hash160, 0x87];
    }

    return [0x76, 0xa9, 0x14, ...hash160, 0x88, 0xac];
  }

  bool _isLocallySignableUtxo(Utxo utxo, {required String fromAddress}) {
    if (!_isSupportedP2pkhInputScript(utxo.scriptPubKey)) {
      return false;
    }

    final resolvedAddress = _resolveInputAddress(utxo.address, utxo.scriptPubKey);
    return resolvedAddress != null && resolvedAddress == fromAddress;
  }

  void _assertSupportedOutputAddress(String address) {
    if (address.startsWith('bc1') || address.startsWith('tb1')) {
      throw TransactionException('Bech32 outputs are not yet supported for local signing');
    }
  }

  String? _resolveInputAddress(String address, String scriptPubKey) {
    if (address.isNotEmpty) {
      return address;
    }

    return _addressService.tryDeriveAddressFromScriptPubKey(
      scriptPubKey,
      isTestnet: _rpcService.isTestnet,
    );
  }

  Uint8List _base58Decode(String encoded) {
    const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    BigInt value = BigInt.zero;
    for (final char in encoded.split('')) {
      final index = alphabet.indexOf(char);
      if (index < 0) {
        throw TransactionException('Invalid Base58 character in address');
      }
      value = value * BigInt.from(58) + BigInt.from(index);
    }

    final bytes = <int>[];
    while (value > BigInt.zero) {
      bytes.insert(0, (value % BigInt.from(256)).toInt());
      value = value ~/ BigInt.from(256);
    }

    final leadingZeros = encoded.split('').takeWhile((c) => c == '1').length;
    return Uint8List.fromList(List<int>.filled(leadingZeros, 0) + bytes);
  }

  Uint8List _doubleSha256(Uint8List data) {
    final digest = SHA256Digest();
    return digest.process(digest.process(data));
  }

  List<int> _pushData(Uint8List data) {
    return [..._varInt(data.length), ...data];
  }

  List<int> _varInt(int value) {
    if (value < 0xfd) {
      return [value];
    }
    if (value <= 0xffff) {
      return [0xfd, ..._uint16LE(value)];
    }
    return [0xfe, ..._uint32LE(value)];
  }

  List<int> _uint16LE(int value) {
    return [value & 0xff, (value >> 8) & 0xff];
  }

  List<int> _uint32LE(int value) {
    return [
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ];
  }

  List<int> _uint64LE(int value) {
    final lower = value & 0xffffffff;
    final upper = value ~/ 0x100000000;
    return [..._uint32LE(lower), ..._uint32LE(upper)];
  }

  String _reverseHex(String hex) {
    final bytes = HEX.decode(hex);
    return HEX.encode(bytes.reversed.toList());
  }

  bool _looksLikeSignedTransaction(String hex) {
    if (hex.isEmpty || hex.length < 120 || hex.length.isOdd) {
      return false;
    }

    return hex.contains('4630') ||
        hex.contains('4730') ||
        hex.contains('4830') ||
        hex.contains('4930');
  }

  bool _isSupportedP2pkhInputScript(String scriptPubKey) {
    return scriptPubKey.length == 50 &&
        scriptPubKey.startsWith('76a914') &&
        scriptPubKey.endsWith('88ac');
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
