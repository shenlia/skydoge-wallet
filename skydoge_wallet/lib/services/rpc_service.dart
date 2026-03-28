import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants/network_constants.dart';
import '../data/models/wallet.dart';
import '../data/models/transaction.dart';

class RpcService {
  final NetworkConfig config;
  final http.Client _client;

  RpcService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<dynamic> call(String method, [List<dynamic>? params]) async {
    final url = Uri.parse(config.rpcUrl);
    final body = jsonEncode({
      'jsonrpc': '1.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': method,
      'params': params ?? [],
    });

    try {
      final response = await _client.post(
        url,
        headers: {
          'Authorization': config.authHeader,
          'Content-Type': 'text/plain',
        },
        body: body,
      ).timeout(NetworkConstants.rpcTimeout);

      if (response.statusCode != 200) {
        throw RpcException('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error') && data['error'] != null) {
        throw RpcException('RPC Error: ${data['error']}');
      }

      return data['result'];
    } catch (e) {
      if (e is RpcException) rethrow;
      throw RpcException('Failed to connect to node: $e');
    }
  }

  Future<int> getBalance(String address) async {
    try {
      final result = await call('getreceivedbyaddress', [address]);
      return _parseSatoshis(result);
    } catch (e) {
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
    } catch (e) {
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
      return (result as List).map((tx) => _parseTransaction(tx)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Transaction?> getTransaction(String txid) async {
    try {
      final result = await call('gettransaction', [txid]);
      return _parseTransaction(result);
    } catch (e) {
      return null;
    }
  }

  Future<String> sendToAddress(String address, double amount) async {
    final result = await call('sendtoaddress', [address, amount]);
    return result as String;
  }

  Future<String> sendRawTransaction(String hex) async {
    final result = await call('sendrawtransaction', [hex]);
    return result as String;
  }

  Future<Map<String, dynamic>> getBlockchainInfo() async {
    return await call('getblockchaininfo');
  }

  Future<Map<String, dynamic>> getNetworkInfo() async {
    return await call('getnetworkinfo');
  }

  Future<String> createRawTransaction({
    required List<TxInput> inputs,
    required List<TxOutput> outputs,
    int locktime = 0,
  }) async {
    final vin = inputs.map((input) => {
      'txid': input.txid,
      'vout': input.vout,
    }).toList();

    final vout = outputs.map((output) => {
      output.address: (output.amount / 100000000.0),
    }).toList();

    final result = await call('createrawtransaction', [vin, vout, locktime]);
    return result as String;
  }

  Future<String> fundRawTransaction(String hex) async {
    final result = await call('fundrawtransaction', [hex]);
    return result['hex'] as String;
  }

  Future<String> signRawTransaction(String hex) async {
    final result = await call('signrawtransaction', [hex]);
    if (result['complete'] != true) {
      throw RpcException('Transaction signing failed: ${result['errors']}');
    }
    return result['hex'] as String;
  }

  Future<List<Utxo>> listUnspent() async {
    try {
      final result = await call('listunspent', [0, 9999999]);
      return (result as List).map((utxo) => Utxo(
        txid: utxo['txid'] as String,
        vout: utxo['vout'] as int,
        amount: _parseSatoshis(utxo['amount']),
        confirmations: utxo['confirmations'] as int,
        scriptPubKey: utxo['scriptPubKey'] as String,
        address: utxo['address'] as String,
      )).toList();
    } catch (e) {
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
    final inputs = <TxInput>[];
    final outputs = <TxOutput>[];

    if (tx.containsKey('details')) {
      for (final detail in tx['details']) {
        final address = detail['address'] as String? ?? '';
        final amount = _parseSatoshis(detail['amount']);
        if (amount > 0) {
          inputs.add(TxInput(
            txid: tx['txid'] as String,
            vout: 0,
            scriptSig: '',
            address: address,
            amount: amount,
          ));
        } else if (amount < 0) {
          outputs.add(TxOutput(
            address: address,
            amount: -amount,
            index: outputs.length,
          ));
        }
      }
    }

    return Transaction(
      txid: tx['txid'] as String,
      hash: tx['hash'] as String? ?? tx['txid'] as String,
      version: tx['version'] as int? ?? 1,
      locktime: tx['locktime'] as int? ?? 0,
      inputs: inputs,
      outputs: outputs,
      fee: _parseSatoshis(tx['fee']),
      size: tx['size'] as int? ?? 0,
      confirmations: tx['confirmations'] as int? ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch((tx['time'] as int? ?? 0) * 1000),
      status: (tx['confirmations'] as int? ?? 0) > 0
          ? TransactionStatus.confirmed
          : TransactionStatus.pending,
      direction: (tx['category'] as String? ?? 'receive') == 'receive'
          ? TransactionDirection.incoming
          : TransactionDirection.outgoing,
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
