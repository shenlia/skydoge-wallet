import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skydoge_wallet/core/constants/network_constants.dart';
import 'package:skydoge_wallet/services/rpc_service.dart';

void main() {
  http.Response rpcSuccess(Object result) {
    return http.Response(
      jsonEncode({
        'result': result,
        'error': null,
        'id': 1,
      }),
      200,
    );
  }

  test('getWalletBalance throws when RPC shape is invalid', () async {
    final service = RpcService(
      config: NetworkConfig.mainnet(),
      client: MockClient((_) async => rpcSuccess(['unexpected'])),
    );

    await expectLater(
      service.getWalletBalance(),
      throwsA(
        isA<RpcException>().having(
          (error) => error.message,
          'message',
          contains('wallet info response shape'),
        ),
      ),
    );
  });

  test('listTransactions throws when RPC shape is invalid', () async {
    final service = RpcService(
      config: NetworkConfig.mainnet(),
      client: MockClient((_) async => rpcSuccess({'unexpected': true})),
    );

    await expectLater(
      service.listTransactions(10),
      throwsA(
        isA<RpcException>().having(
          (error) => error.message,
          'message',
          contains('transactions response shape'),
        ),
      ),
    );
  });

  test('getTransaction throws when RPC shape is invalid', () async {
    final service = RpcService(
      config: NetworkConfig.mainnet(),
      client: MockClient((_) async => rpcSuccess(['unexpected'])),
    );

    await expectLater(
      service.getTransaction('abc'),
      throwsA(
        isA<RpcException>().having(
          (error) => error.message,
          'message',
          contains('transaction response shape'),
        ),
      ),
    );
  });

  test('listUnspent throws when RPC shape is invalid', () async {
    final service = RpcService(
      config: NetworkConfig.mainnet(),
      client: MockClient((_) async => rpcSuccess({'unexpected': true})),
    );

    await expectLater(
      service.listUnspent(),
      throwsA(
        isA<RpcException>().having(
          (error) => error.message,
          'message',
          contains('UTXO response shape'),
        ),
      ),
    );
  });
}
