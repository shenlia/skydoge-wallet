import '../data/models/sidechain_info.dart';
import 'rpc_service.dart';

class DrivechainService {
  final RpcService _rpcService;

  DrivechainService({required RpcService rpcService}) : _rpcService = rpcService;

  Future<List<SidechainInfo>> getSidechains() async {
    try {
      final result = await _rpcService.call('getsidechaininfo');
      if (result == null) return [];

      final sidechains = <SidechainInfo>[];

      if (result is List) {
        for (final sc in result) {
          sidechains.add(_parseSidechainInfo(sc));
        }
      } else if (result is Map) {
        final sidechainList = result['sidechains'] as List?;
        if (sidechainList != null) {
          for (final sc in sidechainList) {
            sidechains.add(_parseSidechainInfo(sc));
          }
        }
      }

      return sidechains;
    } catch (e) {
      return [];
    }
  }

  Future<SidechainInfo?> getSidechainInfo(String sidechainId) async {
    try {
      final result = await _rpcService.call('getsidechaininfo', [sidechainId]);
      if (result == null) return null;
      return _parseSidechainInfo(result);
    } catch (e) {
      return null;
    }
  }

  Future<List<CrossChainTransaction>> getDepositList() async {
    try {
      final result = await _rpcService.call('getdepositlist');
      if (result == null) return [];

      return (result as List).map((deposit) => _parseCrossChainTransaction(deposit, CrossChainTxType.deposit)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<CrossChainTransaction>> getWithdrawalList() async {
    try {
      final result = await _rpcService.call('getwithdrawallist');
      if (result == null) return [];

      return (result as List).map((withdrawal) => _parseCrossChainTransaction(withdrawal, CrossChainTxType.withdrawal)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> simpleDrivechainDeposit({
    required String sidechainId,
    required double amount,
  }) async {
    try {
      final result = await _rpcService.call('simpledrivechaindeposit', [sidechainId, amount]);
      return result as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> simpleDrivechainWithdraw({
    required String sidechainId,
    required double amount,
    required String address,
  }) async {
    try {
      final result = await _rpcService.call('simpledrivechainwithdraw', [sidechainId, amount, address]);
      return result as String?;
    } catch (e) {
      return null;
    }
  }

  SidechainInfo _parseSidechainInfo(Map<String, dynamic> json) {
    final deposits = <CrossChainTransaction>[];
    final withdrawals = <CrossChainTransaction>[];

    if (json.containsKey('deposits')) {
      for (final d in json['deposits']) {
        deposits.add(_parseCrossChainTransaction(d, CrossChainTxType.deposit));
      }
    }

    if (json.containsKey('withdrawals')) {
      for (final w in json['withdrawals']) {
        withdrawals.add(_parseCrossChainTransaction(w, CrossChainTxType.withdrawal));
      }
    }

    return SidechainInfo(
      sidechainId: json['sidechainid'] as String? ?? json['sidechainId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      version: json['version'] as int? ?? 0,
      status: json['status'] as String? ?? 'unknown',
      depositCount: deposits.length,
      withdrawalCount: withdrawals.length,
      deposits: deposits,
      withdrawals: withdrawals,
    );
  }

  CrossChainTransaction _parseCrossChainTransaction(Map<String, dynamic> json, CrossChainTxType type) {
    return CrossChainTransaction(
      txid: json['txid'] as String? ?? '',
      sidechainId: json['sidechainid'] as String? ?? json['sidechainId'] as String? ?? '',
      amount: _parseSatoshis(json['amount']),
      fee: _parseSatoshis(json['fee']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as int?) ?? 0) * 1000,
      ),
      type: type,
      status: _parseCrossChainStatus(json['status'] as String?),
      hash: json['hash'] as String?,
      confirmations: json['confirmations'] as int?,
    );
  }

  CrossChainTxStatus _parseCrossChainStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return CrossChainTxStatus.confirmed;
      case 'confirming':
        return CrossChainTxStatus.confirming;
      case 'failed':
        return CrossChainTxStatus.failed;
      default:
        return CrossChainTxStatus.pending;
    }
  }

  int _parseSatoshis(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return (value * 100000000).round();
    if (value is String) return (double.parse(value) * 100000000).round();
    return 0;
  }
}
