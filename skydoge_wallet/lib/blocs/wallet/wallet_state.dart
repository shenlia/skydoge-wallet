import 'package:equatable/equatable.dart';
import '../../../data/models/wallet.dart';
import '../../../data/models/transaction.dart' as models;

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
  final List<models.Transaction> transactions;
  final bool isTestnet;
  final String? warningMessage;

  const WalletLoaded({
    required this.wallet,
    required this.balance,
    required this.transactions,
    required this.isTestnet,
    this.warningMessage,
  });

  WalletLoaded copyWith({
    Wallet? wallet,
    WalletBalance? balance,
    List<models.Transaction>? transactions,
    bool? isTestnet,
    String? warningMessage,
    bool clearWarningMessage = false,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isTestnet: isTestnet ?? this.isTestnet,
      warningMessage: clearWarningMessage ? null : warningMessage ?? this.warningMessage,
    );
  }

  @override
  List<Object?> get props => [wallet, balance, transactions, isTestnet, warningMessage];
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
