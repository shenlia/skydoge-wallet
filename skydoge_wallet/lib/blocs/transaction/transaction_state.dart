import 'package:equatable/equatable.dart';
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
  final int donationFee;
  final String toAddress;
  final int amount;

  const TransactionBuilt({
    required this.transaction,
    required this.donationFee,
    required this.toAddress,
    required this.amount,
  });

  @override
  List<Object?> get props => [transaction, donationFee, toAddress, amount];
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

class TransactionDonationSet extends TransactionState {
  final bool enabled;

  const TransactionDonationSet({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}
