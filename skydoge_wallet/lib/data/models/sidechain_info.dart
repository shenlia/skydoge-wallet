import 'package:equatable/equatable.dart';

class SidechainInfo extends Equatable {
  final String sidechainId;
  final String name;
  final String description;
  final int version;
  final String status;
  final int depositCount;
  final int withdrawalCount;
  final List<CrossChainTransaction> deposits;
  final List<CrossChainTransaction> withdrawals;

  const SidechainInfo({
    required this.sidechainId,
    required this.name,
    required this.description,
    required this.version,
    required this.status,
    required this.depositCount,
    required this.withdrawalCount,
    required this.deposits,
    required this.withdrawals,
  });

  bool get isActive => status == 'active';

  Map<String, dynamic> toJson() {
    return {
      'sidechainId': sidechainId,
      'name': name,
      'description': description,
      'version': version,
      'status': status,
      'depositCount': depositCount,
      'withdrawalCount': withdrawalCount,
      'deposits': deposits.map((d) => d.toJson()).toList(),
      'withdrawals': withdrawals.map((w) => w.toJson()).toList(),
    };
  }

  factory SidechainInfo.fromJson(Map<String, dynamic> json) {
    return SidechainInfo(
      sidechainId: json['sidechainId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as int,
      status: json['status'] as String,
      depositCount: json['depositCount'] as int? ?? 0,
      withdrawalCount: json['withdrawalCount'] as int? ?? 0,
      deposits: (json['deposits'] as List?)?.map((d) => CrossChainTransaction.fromJson(d)).toList() ?? [],
      withdrawals: (json['withdrawals'] as List?)?.map((w) => CrossChainTransaction.fromJson(w)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [sidechainId, name, description, version, status, depositCount, withdrawalCount, deposits, withdrawals];
}

class CrossChainTransaction extends Equatable {
  final String txid;
  final String sidechainId;
  final int amount;
  final int fee;
  final DateTime timestamp;
  final CrossChainTxType type;
  final CrossChainTxStatus status;
  final String? hash;
  final int? confirmations;

  const CrossChainTransaction({
    required this.txid,
    required this.sidechainId,
    required this.amount,
    required this.fee,
    required this.timestamp,
    required this.type,
    required this.status,
    this.hash,
    this.confirmations,
  });

  bool get isPending => status == CrossChainTxStatus.pending;

  Map<String, dynamic> toJson() {
    return {
      'txid': txid,
      'sidechainId': sidechainId,
      'amount': amount,
      'fee': fee,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'hash': hash,
      'confirmations': confirmations,
    };
  }

  factory CrossChainTransaction.fromJson(Map<String, dynamic> json) {
    return CrossChainTransaction(
      txid: json['txid'] as String,
      sidechainId: json['sidechainId'] as String,
      amount: json['amount'] as int,
      fee: json['fee'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: CrossChainTxType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CrossChainTxType.deposit,
      ),
      status: CrossChainTxStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CrossChainTxStatus.pending,
      ),
      hash: json['hash'] as String?,
      confirmations: json['confirmations'] as int?,
    );
  }

  @override
  List<Object?> get props => [txid, sidechainId, amount, fee, timestamp, type, status, hash, confirmations];
}

enum CrossChainTxType {
  deposit,
  withdrawal,
}

enum CrossChainTxStatus {
  pending,
  confirming,
  confirmed,
  failed,
}
