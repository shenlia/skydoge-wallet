import 'package:equatable/equatable.dart';
import '../../../data/models/wallet.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletNotFound extends WalletState {
  const WalletNotFound();
}

class WalletCreated extends WalletState {
  final Wallet wallet;
  final String mnemonic;

  const WalletCreated({
    required this.wallet,
    required this.mnemonic,
  });

  @override
  List<Object?> get props => [wallet, mnemonic];
}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final WalletBalance balance;
  final List<Transaction> transactions;
  final bool isTestnet;

  const WalletLoaded({
    required this.wallet,
    required this.balance,
    required this.transactions,
    required this.isTestnet,
  });

  @override
  List<Object?> get props => [wallet, balance, transactions, isTestnet];
}

class WalletLocked extends WalletState {
  final bool hasPin;

  const WalletLocked({required this.hasPin});

  @override
  List<Object?> get props => [hasPin];
}

class WalletUnlocked extends WalletState {
  final Wallet wallet;

  const WalletUnlocked({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

class WalletBackedUp extends WalletState {
  final String mnemonic;

  const WalletBackedUp({required this.mnemonic});

  @override
  List<Object?> get props => [mnemonic];
}

class WalletDeleted extends WalletState {
  const WalletDeleted();
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}

class Transaction {
  final String txid;
  final int amount;
  final DateTime timestamp;
  final int confirmations;
  final bool isIncoming;

  const Transaction({
    required this.txid,
    required this.amount,
    required this.timestamp,
    required this.confirmations,
    required this.isIncoming,
  });
}
