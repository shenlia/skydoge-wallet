import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/network_constants.dart';

class ExplorerApiService {
  final String baseUrl;
  final http.Client _client;

  ExplorerApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  factory ExplorerApiService.mainnet() {
    return ExplorerApiService(baseUrl: NetworkConstants.mainnetExplorerApi);
  }

  factory ExplorerApiService.testnet() {
    return ExplorerApiService(baseUrl: NetworkConstants.testnetExplorerApi);
  }

  Future<int> getBalance(String address) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ext/getbalance/$address'),
      ).timeout(NetworkConstants.connectionTimeout);

      if (response.statusCode != 200) return 0;

      final data = jsonDecode(response.body);
      if (data is num) {
        return (data * 100000000).round();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<ExplorerTransaction>> getAddressTxs(String address, {int start = 0, int length = 50}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ext/getaddresstxs/$address/$start/$length'),
      ).timeout(NetworkConstants.connectionTimeout);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as List;
      return data.map((tx) => ExplorerTransaction.fromJson(tx)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ExplorerTx?> getTx(String txid) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ext/gettx/$txid'),
      ).timeout(NetworkConstants.connectionTimeout);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return ExplorerTx.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getBasicStats() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ext/getbasicstats'),
      ).timeout(NetworkConstants.connectionTimeout);

      if (response.statusCode != 200) return {};

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  void dispose() {
    _client.close();
  }
}

class ExplorerTransaction {
  final String txid;
  final int timestamp;
  final int value;
  final bool isIncoming;
  final int confirmations;
  final int? blockHeight;

  ExplorerTransaction({
    required this.txid,
    required this.timestamp,
    required this.value,
    required this.isIncoming,
    required this.confirmations,
    this.blockHeight,
  });

  factory ExplorerTransaction.fromJson(Map<String, dynamic> json) {
    return ExplorerTransaction(
      txid: json['txid'] as String? ?? '',
      timestamp: (json['timestamp'] as int?) ?? 0,
      value: _parseSatoshis(json['value'] ?? json['value_out']),
      isIncoming: (json['vinvoutaddr'] ?? json['addresses'] ?? '').toString().isEmpty == false,
      confirmations: json['confirmations'] as int? ?? 0,
      blockHeight: json['blockHeight'] as int?,
    );
  }

  static int _parseSatoshis(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return (value * 100000000).round();
    if (value is String) return (double.tryParse(value) ?? 0 * 100000000).round();
    return 0;
  }
}

class ExplorerTx {
  final String txid;
  final int timestamp;
  final int fee;
  final List<ExplorerVin> vin;
  final List<ExplorerVout> vout;
  final int confirmations;

  ExplorerTx({
    required this.txid,
    required this.timestamp,
    required this.fee,
    required this.vin,
    required this.vout,
    required this.confirmations,
  });

  factory ExplorerTx.fromJson(Map<String, dynamic> json) {
    return ExplorerTx(
      txid: json['txid'] as String? ?? '',
      timestamp: (json['timestamp'] as int?) ?? 0,
      fee: _parseSatoshis(json['fees'] ?? json['fee']),
      vin: (json['vin'] as List?)?.map((v) => ExplorerVin.fromJson(v)).toList() ?? [],
      vout: (json['vout'] as List?)?.map((v) => ExplorerVout.fromJson(v)).toList() ?? [],
      confirmations: json['confirmations'] as int? ?? 0,
    );
  }

  static int _parseSatoshis(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return (value * 100000000).round();
    if (value is String) return (double.tryParse(value) ?? 0 * 100000000).round();
    return 0;
  }
}

class ExplorerVin {
  final String addr;
  final int value;

  ExplorerVin({required this.addr, required this.value});

  factory ExplorerVin.fromJson(Map<String, dynamic> json) {
    return ExplorerVin(
      addr: json['addr'] as String? ?? '',
      value: _parseSatoshis(json['value']),
    );
  }

  static int _parseSatoshis(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return (value * 100000000).round();
    if (value is String) return (double.tryParse(value) ?? 0 * 100000000).round();
    return 0;
  }
}

class ExplorerVout {
  final String addr;
  final int value;

  ExplorerVout({required this.addr, required this.value});

  factory ExplorerVout.fromJson(Map<String, dynamic> json) {
    return ExplorerVout(
      addr: json['addr'] as String? ?? '',
      value: _parseSatoshis(json['value']),
    );
  }

  static int _parseSatoshis(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return (value * 100000000).round();
    if (value is String) return (double.tryParse(value) ?? 0 * 100000000).round();
    return 0;
  }
}
