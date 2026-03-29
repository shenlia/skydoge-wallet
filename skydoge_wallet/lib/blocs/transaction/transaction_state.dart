import 'package:equatable/equatable.dart';
import '../../core/transaction/tx_preview.dart';
import '../../data/models/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionBuilding extends TransactionState {
  const TransactionBuilding();
}

class TransactionBuilt extends TransactionState {
  final UnsignedTransaction transaction;
  final TxPreview preview;

  const TransactionBuilt({
    required this.transaction,
    required this.preview,
  });

  @override
  List<Object?> get props => [transaction, preview];
}

class TransactionSigning extends TransactionState {
  const TransactionSigning();
}

class TransactionBroadcasting extends TransactionState {
  const TransactionBroadcasting();
}

class TransactionBroadcasted extends TransactionState {
  final String txid;

  const TransactionBroadcasted({required this.txid});

  @override
  List<Object?> get props => [txid];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransactionFeeRateSet extends TransactionState {
  final String feeLevel;
  final int feeRate;

  const TransactionFeeRateSet({
    required this.feeLevel,
    required this.feeRate,
  });

  @override
  List<Object?> get props => [feeLevel, feeRate];
}
