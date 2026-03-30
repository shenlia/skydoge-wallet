import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/core/constants/network_constants.dart';
import 'package:skydoge_wallet/data/models/transaction.dart';
import 'package:skydoge_wallet/services/address_service.dart';
import 'package:skydoge_wallet/services/rpc_service.dart';
import 'package:skydoge_wallet/services/transaction_service.dart';

class FakeRpcService extends RpcService {
  FakeRpcService({
    required super.config,
    required this.utxos,
    this.listUnspentError,
  });

  final List<Utxo> utxos;
  final RpcException? listUnspentError;

  @override
  Future<List<Utxo>> listUnspent() async {
    if (listUnspentError != null) {
      throw listUnspentError!;
    }

    return utxos;
  }
}

void main() {
  final addressService = AddressService();
  final transactionService = TransactionService(
    rpcService: RpcService(config: NetworkConfig.mainnet()),
    addressService: addressService,
  );

  test('local signing validates input ownership', () async {
    const privateKeyHex =
        '0000000000000000000000000000000000000000000000000000000000000001';
    final ownerAddress = addressService.getAddressFromPrivateKey(privateKeyHex);

    final unsigned = UnsignedTransaction(
      rawHex: 'deadbeef',
      inputs: [
        TxInput(
          txid: 'abc',
          vout: 0,
          scriptSig: '',
          scriptPubKey: '76a91400',
          address: ownerAddress,
          amount: 1000,
        ),
      ],
      outputs: const [
        TxOutput(address: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc', amount: 100, index: 0),
      ],
      fee: 10,
      donationFee: 1,
      network: 'mainnet',
    );

    final signed = await transactionService.signLocally(
      unsignedTx: unsigned,
      privateKeyHex: privateKeyHex,
    );

    expect(signed, isNot('deadbeef'));
    expect(signed.length, greaterThan(20));
  });

  test('local signing rejects foreign input address', () async {
    const privateKeyHex =
        '0000000000000000000000000000000000000000000000000000000000000001';

    final unsigned = UnsignedTransaction(
      rawHex: 'deadbeef',
      inputs: const [
        TxInput(
          txid: 'abc',
          vout: 0,
          scriptSig: '',
          scriptPubKey: '76a91400',
          address: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
          amount: 1000,
        ),
      ],
      outputs: const [
        TxOutput(address: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc', amount: 100, index: 0),
      ],
      fee: 10,
      donationFee: 1,
      network: 'mainnet',
    );

    expect(
      () => transactionService.signLocally(
        unsignedTx: unsigned,
        privateKeyHex: privateKeyHex,
      ),
      throwsA(isA<TransactionException>()),
    );
  });

  test('local signing rejects missing script pub key', () async {
    const privateKeyHex =
        '0000000000000000000000000000000000000000000000000000000000000001';
    final ownerAddress = addressService.getAddressFromPrivateKey(privateKeyHex);

    final unsigned = UnsignedTransaction(
      rawHex: 'deadbeef',
      inputs: [
        TxInput(
          txid: 'abc',
          vout: 0,
          scriptSig: '',
          address: ownerAddress,
          amount: 1000,
        ),
      ],
      outputs: const [
        TxOutput(address: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc', amount: 100, index: 0),
      ],
      fee: 10,
      donationFee: 1,
      network: 'mainnet',
    );

    expect(
      () => transactionService.signLocally(
        unsignedTx: unsigned,
        privateKeyHex: privateKeyHex,
      ),
      throwsA(isA<TransactionException>()),
    );
  });

  test('local signing rejects non-P2PKH input scripts', () async {
    const privateKeyHex =
        '0000000000000000000000000000000000000000000000000000000000000001';
    final ownerAddress = addressService.getAddressFromPrivateKey(privateKeyHex);

    final unsigned = UnsignedTransaction(
      rawHex: 'deadbeef',
      inputs: [
        TxInput(
          txid: '55' * 32,
          vout: 0,
          scriptSig: '',
          scriptPubKey: 'a914000000000000000000000000000000000000000087',
          address: ownerAddress,
          amount: 2000,
        ),
      ],
      outputs: const [
        TxOutput(address: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc', amount: 1000, index: 0),
      ],
      fee: 10,
      donationFee: 1,
      network: 'mainnet',
    );

    await expectLater(
      transactionService.signLocally(
        unsignedTx: unsigned,
        privateKeyHex: privateKeyHex,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('Unsupported input scriptPubKey'),
        ),
      ),
    );
  });

  test('buildPreview uses testnet donation address on testnet service', () {
    final testnetService = TransactionService(
      rpcService: RpcService(config: NetworkConfig.testnet()),
      addressService: addressService,
    );

    final preview = testnetService.buildPreview(
      toAddress: 'mqcLvjMSC927erejtAw6w7k8tBB9hm3Ann',
      sendAmount: 1000,
      donationAmount: 546,
      fee: 100,
      changeAmount: 0,
    );

    expect(preview.donationAddress, 'mqcLvjMSC927erejtAw6w7k8tBB9hm3Ann');
    expect(preview.network, 'testnet');
  });

  test('broadcastTransaction rejects unsigned placeholder payloads', () async {
    await expectLater(
      transactionService.broadcastTransaction('deadbeef'),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('signed'),
        ),
      ),
    );
  });

  test('local signing works with mnemonic-derived private key and address pair', () async {
    const mnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final wallet = await addressService.deriveWallet(mnemonic);

    final unsigned = UnsignedTransaction(
      rawHex: 'deadbeef',
      inputs: [
        TxInput(
          txid: '11' * 32,
          vout: 1,
          scriptSig: '',
          scriptPubKey: '76a914000000000000000000000000000000000000000088ac',
          address: wallet.receivingAddress,
          amount: 1500,
        ),
      ],
      outputs: const [
        TxOutput(address: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc', amount: 700, index: 0),
      ],
      fee: 20,
      donationFee: 1,
      network: 'mainnet',
    );

    final signed = await transactionService.signLocally(
      unsignedTx: unsigned,
      privateKeyHex: wallet.privateKey,
    );

    expect(signed, isNotEmpty);
    expect(signed, isNot(unsigned.rawHex));
  });

  test('local signing supports P2SH recipients in outputs', () async {
    const privateKeyHex =
        '0000000000000000000000000000000000000000000000000000000000000001';
    final ownerAddress = addressService.getAddressFromPrivateKey(privateKeyHex);

    final unsigned = UnsignedTransaction(
      rawHex: 'deadbeef',
      inputs: [
        TxInput(
          txid: '22' * 32,
          vout: 0,
          scriptSig: '',
          scriptPubKey: '76a914000000000000000000000000000000000000000088ac',
          address: ownerAddress,
          amount: 3000,
        ),
      ],
      outputs: const [
        TxOutput(address: '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy', amount: 1200, index: 0),
      ],
      fee: 30,
      donationFee: 1,
      network: 'mainnet',
    );

    final signed = await transactionService.signLocally(
      unsignedTx: unsigned,
      privateKeyHex: privateKeyHex,
    );

    expect(signed, isNotEmpty);
  });

  test('local signing rejects bech32 recipients with explicit error', () async {
    const privateKeyHex =
        '0000000000000000000000000000000000000000000000000000000000000001';
    final ownerAddress = addressService.getAddressFromPrivateKey(privateKeyHex);

    final unsigned = UnsignedTransaction(
      rawHex: 'deadbeef',
      inputs: [
        TxInput(
          txid: '33' * 32,
          vout: 0,
          scriptSig: '',
          scriptPubKey: '76a914000000000000000000000000000000000000000088ac',
          address: ownerAddress,
          amount: 3000,
        ),
      ],
      outputs: const [
        TxOutput(
          address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
          amount: 1200,
          index: 0,
        ),
      ],
      fee: 30,
      donationFee: 1,
      network: 'mainnet',
    );

    await expectLater(
      transactionService.signLocally(
        unsignedTx: unsigned,
        privateKeyHex: privateKeyHex,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('Bech32 outputs'),
        ),
      ),
    );
  });

  test('buildTransaction folds dust change into fee instead of output', () async {
    final ownerWallet = await addressService.deriveWallet(
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: [
        Utxo(
          txid: '44' * 32,
          vout: 0,
          amount: 3600,
          confirmations: 6,
          scriptPubKey: '76a914000000000000000000000000000000000000000088ac',
          address: ownerWallet.receivingAddress,
        ),
      ],
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    final unsigned = await buildService.buildTransaction(
      toAddress: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
      amount: 2000,
      fromAddress: ownerWallet.receivingAddress,
      feeRate: 2,
    );

    expect(unsigned.outputs.length, 2);
    expect(unsigned.changeAmount, 0);
    expect(unsigned.fee, 1600);
  });

  test('buildTransaction rejects bech32 recipient before signing stage', () async {
    final ownerWallet = await addressService.deriveWallet(
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: [
        Utxo(
          txid: '66' * 32,
          vout: 0,
          amount: 5000000,
          confirmations: 6,
          scriptPubKey: '76a914000000000000000000000000000000000000000088ac',
          address: ownerWallet.receivingAddress,
        ),
      ],
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    await expectLater(
      buildService.buildTransaction(
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        amount: 1000000,
        fromAddress: ownerWallet.receivingAddress,
        feeRate: 2,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('Bech32 outputs'),
        ),
      ),
    );
  });

  test('buildTransaction ignores unsupported UTXOs and fails clearly', () async {
    final ownerWallet = await addressService.deriveWallet(
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: [
        Utxo(
          txid: '77' * 32,
          vout: 0,
          amount: 5000000,
          confirmations: 6,
          scriptPubKey: 'a914000000000000000000000000000000000000000087',
          address: ownerWallet.receivingAddress,
        ),
        Utxo(
          txid: '88' * 32,
          vout: 1,
          amount: 5000000,
          confirmations: 6,
          scriptPubKey: '76a914000000000000000000000000000000000000000088ac',
          address: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
        ),
      ],
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    await expectLater(
      buildService.buildTransaction(
        toAddress: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
        amount: 1000000,
        fromAddress: ownerWallet.receivingAddress,
        feeRate: 2,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('locally signable UTXOs'),
        ),
      ),
    );
  });

  test('buildTransaction accepts signable UTXO even when node omits address field', () async {
    final ownerWallet = await addressService.deriveWallet(
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: [
        const Utxo(
          txid: '99' * 32,
          vout: 0,
          amount: 5000000,
          confirmations: 6,
          scriptPubKey: '76a914d986ed01b7a22225a70edbf2ba7cfb63a15cb3aa88ac',
          address: '',
        ),
      ],
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    final unsigned = await buildService.buildTransaction(
      toAddress: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
      amount: 1000000,
      fromAddress: ownerWallet.receivingAddress,
      feeRate: 2,
    );

    expect(unsigned.inputs, hasLength(1));
    expect(unsigned.inputs.first.address, isEmpty);
  });

  test('buildTransaction rejects recipient from wrong network', () async {
    final ownerWallet = await addressService.deriveWallet(
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: [
        Utxo(
          txid: 'aa' * 32,
          vout: 0,
          amount: 5000000,
          confirmations: 6,
          scriptPubKey: '76a914d986ed01b7a22225a70edbf2ba7cfb63a15cb3aa88ac',
          address: ownerWallet.receivingAddress,
        ),
      ],
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    await expectLater(
      buildService.buildTransaction(
        toAddress: 'mqcLvjMSC927erejtAw6w7k8tBB9hm3Ann',
        amount: 1000000,
        fromAddress: ownerWallet.receivingAddress,
        feeRate: 2,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('active network'),
        ),
      ),
    );
  });

  test('buildTransaction rejects change address from wrong network', () async {
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: const [],
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    await expectLater(
      buildService.buildTransaction(
        toAddress: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
        amount: 1000000,
        fromAddress: 'mqcLvjMSC927erejtAw6w7k8tBB9hm3Ann',
        feeRate: 2,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('active network'),
        ),
      ),
    );
  });

  test('buildTransaction ignores UTXO whose resolved address mismatches active network', () async {
    final ownerWallet = await addressService.deriveWallet(
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: [
        const Utxo(
          txid: 'bb' * 32,
          vout: 0,
          amount: 5000000,
          confirmations: 6,
          scriptPubKey: '76a9146eb63aedd0ab8d64ac745306ac8b8d4699a04fbc88ac',
          address: '',
        ),
      ],
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    await expectLater(
      buildService.buildTransaction(
        toAddress: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
        amount: 1000000,
        fromAddress: ownerWallet.receivingAddress,
        feeRate: 2,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('locally signable UTXOs'),
        ),
      ),
    );
  });

  test('buildTransaction surfaces RPC listUnspent failure clearly', () async {
    final ownerWallet = await addressService.deriveWallet(
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    final fakeRpc = FakeRpcService(
      config: NetworkConfig.mainnet(),
      utxos: const [],
      listUnspentError: RpcException('RPC Error: node unavailable'),
    );
    final buildService = TransactionService(
      rpcService: fakeRpc,
      addressService: addressService,
    );

    await expectLater(
      buildService.buildTransaction(
        toAddress: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
        amount: 1000000,
        fromAddress: ownerWallet.receivingAddress,
        feeRate: 2,
      ),
      throwsA(
        isA<TransactionException>().having(
          (error) => error.message,
          'message',
          contains('Failed to fetch spendable UTXOs'),
        ),
      ),
    );
  });
}
