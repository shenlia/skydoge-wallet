import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/network_constants.dart';
import '../data/models/transaction.dart';
import '../data/models/wallet.dart';
import '../data/repositories/node_repository.dart';

class RpcService {
  final String rpcUrl;
  final String authHeader;
  final http.Client _client;
  final bool isTestnet;

  RpcService.testable({
    required this.rpcUrl,
    required this.authHeader,
    required this.isTestnet,
    http.Client? client,
  }) : _client = client ?? http.Client();

  RpcService._({
    required this.rpcUrl,
    required this.authHeader,
    required this.isTestnet,
    http.Client? client,
  }) : _client = client ?? http.Client();

  factory RpcService({
    required NetworkConfig config,
    http.Client? client,
  }) {
    return RpcService._(
      rpcUrl: config.rpcUrl,
      authHeader: config.authHeader,
      isTestnet: config.isTestnet,
      client: client,
    );
  }

  factory RpcService.fromNodeConfig({
    required NodeConfig config,
    required bool isTestnet,
    http.Client? client,
  }) {
    return RpcService._(
      rpcUrl: config.rpcUrl,
      authHeader: config.authHeader,
      isTestnet: isTestnet,
      client: client,
    );
  }

  static Future<RpcService> create({required bool isTestnet}) async {
    final nodeRepository = NodeRepository();
    final useCustom = await nodeRepository.isUsingCustomNode();

    if (useCustom) {
      final customConfig = await nodeRepository.getCustomNodeConfig();
      if (customConfig != null) {
        return RpcService.fromNodeConfig(
          config: customConfig,
          isTestnet: isTestnet,
        );
      }
    }

    final defaultConfig =
        isTestnet ? NetworkConfig.testnet() : NetworkConfig.mainnet();
    return RpcService(config: defaultConfig);
  }

  Future<dynamic> call(String method, [List<dynamic>? params]) async {
    final url = Uri.parse(rpcUrl);
    final body = jsonEncode({
      'jsonrpc': '1.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': method,
      'params': params ?? [],
    });

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': authHeader,
              'Content-Type': 'text/plain',
            },
            body: body,
          )
          .timeout(NetworkConstants.rpcTimeout);

      if (response.statusCode != 200) {
        throw RpcException('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error') && data['error'] != null) {
        throw RpcException('RPC Error: ${data['error']}');
      }

      return data['result'];
    } catch (error) {
      if (error is RpcException) rethrow;
      throw RpcException('Failed to connect to node: $error');
    }
  }

  Future<int> getBalance(String address) async {
    try {
      final result = await call('getreceivedbyaddress', [address]);
      return _parseSatoshis(result);
    } catch (_) {
      return 0;
    }
  }

  Future<WalletBalance> getWalletBalance() async {
    try {
      final result = await call('getwalletinfo');
      return WalletBalance(
        confirmed: _parseSatoshis(result['balance']),
        unconfirmed: _parseSatoshis(result['unconfirmed_balance']),
        immature: _parseSatoshis(result['immature_balance']),
        sidechain: 0,
      );
    } catch (_) {
      return const WalletBalance(
        confirmed: 0,
        unconfirmed: 0,
        immature: 0,
        sidechain: 0,
      );
    }
  }

  Future<List<Transaction>> listTransactions(int count, {int skip = 0}) async {
    try {
      final result = await call('listtransactions', ['*', count, skip]);
      return (result as List)
          .map((tx) => _parseTransaction(tx as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Transaction?> getTransaction(String txid) async {
    try {
      final result = await call('gettransaction', [txid]);
      return _parseTransaction(result as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String> sendRawTransaction(String hex) async {
    final result = await call('sendrawtransaction', [hex]);
    return result as String;
  }

  Future<Map<String, dynamic>> getBlockchainInfo() async {
    return (await call('getblockchaininfo')) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getNetworkInfo() async {
    return (await call('getnetworkinfo')) as Map<String, dynamic>;
  }

  Future<String> createRawTransaction({
    required List<TxInput> inputs,
    required List<TxOutput> outputs,
    int locktime = 0,
  }) async {
    final vin = inputs
        .map((input) => {
              'txid': input.txid,
              'vout': input.vout,
            })
        .toList();

    final vout = <String, double>{};
    for (final output in outputs) {
      vout[output.address] = output.amount / 100000000.0;
    }

    final result = await call('createrawtransaction', [vin, vout, locktime]);
    return result as String;
  }

  Future<List<Utxo>> listUnspent() async {
    try {
      final result = await call('listunspent', [0, 9999999]);
      return (result as List)
          .map(
            (utxo) => Utxo(
              txid: utxo['txid'] as String,
              vout: utxo['vout'] as int,
              amount: _parseSatoshis(utxo['amount']),
              confirmations: utxo['confirmations'] as int,
              scriptPubKey: utxo['scriptPubKey'] as String,
              address: utxo['address'] as String,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  int _parseSatoshis(dynamic value) {
    if (value is int) return value;
    if (value is double) return (value * 100000000).round();
    if (value is String) return (double.parse(value) * 100000000).round();
    return 0;
  }

  Transaction _parseTransaction(Map<String, dynamic> tx) {
    final outputs = <TxOutput>[];
    if (tx.containsKey('details')) {
      for (final detail in tx['details'] as List) {
        final address = detail['address'] as String? ?? '';
        final amount = _parseSatoshis(detail['amount']);
        if (amount < 0) {
          outputs.add(
            TxOutput(
              address: address,
              amount: -amount,
              index: outputs.length,
              isDonation: false,
            ),
          );
        }
      }
    }

    final donationAmount = outputs
        .where((output) => output.address == '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc')
        .fold(0, (sum, output) => sum + output.amount);

    return Transaction(
      txid: tx['txid'] as String,
      hash: tx['hash'] as String? ?? tx['txid'] as String,
      version: tx['version'] as int? ?? 1,
      locktime: tx['locktime'] as int? ?? 0,
      inputs: const [],
      outputs: outputs,
      fee: _parseSatoshis(tx['fee']),
      size: tx['size'] as int? ?? 0,
      confirmations: tx['confirmations'] as int? ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (tx['time'] as int? ?? 0) * 1000,
      ),
      status: (tx['confirmations'] as int? ?? 0) > 0
          ? TransactionStatus.confirmed
          : TransactionStatus.pending,
      direction: (tx['category'] as String? ?? 'receive') == 'receive'
          ? TransactionDirection.incoming
          : TransactionDirection.outgoing,
      isDonation: donationAmount > 0,
    );
  }

  void dispose() {
    _client.close();
  }
}

class Utxo {
  final String txid;
  final int vout;
  final int amount;
  final int confirmations;
  final String scriptPubKey;
  final String address;

  const Utxo({
    required this.txid,
    required this.vout,
    required this.amount,
    required this.confirmations,
    required this.scriptPubKey,
    required this.address,
  });
}

class RpcException implements Exception {
  final String message;

  RpcException(this.message);

  @override
  String toString() => 'RpcException: $message';
}
