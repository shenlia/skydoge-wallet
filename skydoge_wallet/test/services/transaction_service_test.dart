import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/core/chain/chain_config.dart';
import 'package:skydoge_wallet/core/constants/donation_constants.dart';
import 'package:skydoge_wallet/core/constants/network_constants.dart';
import 'package:skydoge_wallet/data/models/transaction.dart';
import 'package:skydoge_wallet/services/address_service.dart';
import 'package:skydoge_wallet/services/rpc_service.dart';
import 'package:skydoge_wallet/services/transaction_service.dart';

class FakeRpcService extends RpcService {
  FakeRpcService()
      : super.testable(
          rpcUrl: 'http://localhost:8332',
          authHeader: 'Basic dGVzdDp0ZXN0',
          isTestnet: false,
        );

  @override
  Future<List<Utxo>> listUnspent() async {
    return const [
      Utxo(
        txid: 'a' * 64,
        vout: 0,
        amount: 200000000,
        confirmations: 10,
        scriptPubKey: '76a914000000000000000000000000000000000000000088ac',
        address: '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
      ),
    ];
  }

  @override
  Future<String> createRawTransaction({
    required List<TxInput> inputs,
    required List<TxOutput> outputs,
    int locktime = 0,
  }) async {
    return 'deadbeef';
  }

  @override
  Future<String> sendRawTransaction(String hex) async {
    return 'mock-txid';
  }
}

void main() {
  group('TransactionService', () {
    final addressService = AddressService();
    final transactionService = TransactionService(
      rpcService: FakeRpcService(),
      addressService: addressService,
    );

    test('builds transaction with mandatory donation output', () async {
      final transaction = await transactionService.buildTransaction(
        toAddress: '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
        sendAmount: 100000000,
        fromAddress: '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
        feeRate: 2,
        chain: ChainConfig.mainnet,
      );

      expect(transaction.donationFee, DonationConstants.calculateDonationFee(100000000));
      expect(transaction.outputs.any((output) => output.isDonation), isTrue);
      expect(transaction.totalCost, greaterThan(transaction.sendAmount));
    });

    test('creates and verifies local authorization signature', () async {
      final addressWallet = await addressService.deriveWallet(
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
        chain: ChainConfig.mainnet,
      );

      final transaction = await transactionService.buildTransaction(
        toAddress: addressWallet.receivingAddress,
        sendAmount: 100000000,
        fromAddress: addressWallet.receivingAddress,
        feeRate: 2,
        chain: ChainConfig.mainnet,
      );

      final signed = transactionService.signTransaction(
        unsignedTx: transaction,
        privateKeyHex: addressWallet.privateKey,
        publicKeyHex: addressWallet.publicKey,
      );

      expect(signed.authorizationSignature.payloadHash, isNotEmpty);
      expect(signed.authorizationSignature.signatureHex, contains(':'));
    });

    test('rejects transactions below minimum donation output', () async {
      expect(
        () => transactionService.buildTransaction(
          toAddress: '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
          sendAmount: 100000,
          fromAddress: '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
          feeRate: 2,
          chain: ChainConfig.mainnet,
        ),
        throwsA(isA<TransactionException>()),
      );
    });
  });
}
