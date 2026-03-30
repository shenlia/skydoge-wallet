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
  });

  final List<Utxo> utxos;

  @override
  Future<List<Utxo>> listUnspent() async => utxos;
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
}
