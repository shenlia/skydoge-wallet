import 'package:equatable/equatable.dart';

enum TransactionStatus {
  pending,
  confirmed,
  failed,
  abandoned,
}

enum TransactionDirection {
  incoming,
  outgoing,
}

class Transaction extends Equatable {
  final String txid;
  final String hash;
  final int version;
  final int locktime;
  final List<TxInput> inputs;
  final List<TxOutput> outputs;
  final int fee;
  final int size;
  final int confirmations;
  final DateTime timestamp;
  final TransactionStatus status;
  final TransactionDirection direction;
  final bool isDonation;

  const Transaction({
    required this.txid,
    required this.hash,
    required this.version,
    required this.locktime,
    required this.inputs,
    required this.outputs,
    required this.fee,
    required this.size,
    required this.confirmations,
    required this.timestamp,
    required this.status,
    required this.direction,
    this.isDonation = false,
  });

  int get amount {
    if (direction == TransactionDirection.incoming) {
      return outputs.fold(0, (sum, output) => sum + output.amount);
    } else {
      return inputs.fold(0, (sum, input) => sum + input.amount) - fee;
    }
  }

  bool get isPending => status == TransactionStatus.pending;
  bool get isConfirmed => status == TransactionStatus.confirmed;

  Map<String, dynamic> toJson() {
    return {
      'txid': txid,
      'hash': hash,
      'version': version,
      'locktime': locktime,
      'inputs': inputs.map((i) => i.toJson()).toList(),
      'outputs': outputs.map((o) => o.toJson()).toList(),
      'fee': fee,
      'size': size,
      'confirmations': confirmations,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'direction': direction.name,
      'isDonation': isDonation,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      txid: json['txid'] as String,
      hash: json['hash'] as String,
      version: json['version'] as int,
      locktime: json['locktime'] as int,
      inputs: (json['inputs'] as List).map((i) => TxInput.fromJson(i)).toList(),
      outputs: (json['outputs'] as List).map((o) => TxOutput.fromJson(o)).toList(),
      fee: json['fee'] as int,
      size: json['size'] as int,
      confirmations: json['confirmations'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      direction: TransactionDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => TransactionDirection.outgoing,
      ),
      isDonation: json['isDonation'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [txid, hash, version, locktime, inputs, outputs, fee, size, confirmations, timestamp, status, direction, isDonation];
}

class TxInput extends Equatable {
  final String txid;
  final int vout;
  final String scriptSig;
  final String address;
  final int amount;

  const TxInput({
    required this.txid,
    required this.vout,
    required this.scriptSig,
    required this.address,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'txid': txid,
      'vout': vout,
      'scriptSig': scriptSig,
      'address': address,
      'amount': amount,
    };
  }

  factory TxInput.fromJson(Map<String, dynamic> json) {
    return TxInput(
      txid: json['txid'] as String,
      vout: json['vout'] as int,
      scriptSig: json['scriptSig'] as String? ?? '',
      address: json['address'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [txid, vout, scriptSig, address, amount];
}

class TxOutput extends Equatable {
  final String address;
  final int amount;
  final int index;
  final bool isDonation;
  final String? scriptPubKey;

  const TxOutput({
    required this.address,
    required this.amount,
    required this.index,
    this.isDonation = false,
    this.scriptPubKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'amount': amount,
      'index': index,
      'isDonation': isDonation,
      'scriptPubKey': scriptPubKey,
    };
  }

  factory TxOutput.fromJson(Map<String, dynamic> json) {
    return TxOutput(
      address: json['address'] as String,
      amount: json['amount'] as int,
      index: json['index'] as int,
      isDonation: json['isDonation'] as bool? ?? false,
      scriptPubKey: json['scriptPubKey'] as String?,
    );
  }

  @override
  List<Object?> get props => [address, amount, index, isDonation, scriptPubKey];
}

class UnsignedTransaction extends Equatable {
  final String txid;
  final List<TxInput> inputs;
  final List<TxOutput> outputs;
  final int fee;
  final int donationFee;

  const UnsignedTransaction({
    required this.txid,
    required this.inputs,
    required this.outputs,
    required this.fee,
    required this.donationFee,
  });

  int get totalInputAmount => inputs.fold(0, (sum, input) => sum + input.amount);
  int get totalOutputAmount => outputs.fold(0, (sum, output) => sum + output.amount);
  int get changeAmount => totalInputAmount - totalOutputAmount - fee;

  @override
  List<Object?> get props => [txid, inputs, outputs, fee, donationFee];
}
