import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class BuildTransactionEvent extends TransactionEvent {
  final String toAddress;
  final int amount;
  final int feeRate;
  final String fromAddress;
  final String privateKey;

  const BuildTransactionEvent({
    required this.toAddress,
    required this.amount,
    required this.feeRate,
    required this.fromAddress,
    required this.privateKey,
  });

  @override
  List<Object?> get props => [toAddress, amount, feeRate, fromAddress, privateKey];
}

class SignTransactionEvent extends TransactionEvent {
  const SignTransactionEvent();
}

class BroadcastTransactionEvent extends TransactionEvent {
  const BroadcastTransactionEvent();
}

class ResetTransactionEvent extends TransactionEvent {
  const ResetTransactionEvent();
}

class SetFeeRateEvent extends TransactionEvent {
  final String feeLevel;

  const SetFeeRateEvent({required this.feeLevel});

  @override
  List<Object?> get props => [feeLevel];
}
