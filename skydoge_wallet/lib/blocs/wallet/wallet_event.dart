import 'package:equatable/equatable.dart';
import '../../../data/models/wallet.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class CreateWalletEvent extends WalletEvent {
  final bool isTestnet;

  const CreateWalletEvent({this.isTestnet = false});

  @override
  List<Object?> get props => [isTestnet];
}

class RecoverWalletEvent extends WalletEvent {
  final String mnemonic;
  final bool isTestnet;

  const RecoverWalletEvent({
    required this.mnemonic,
    this.isTestnet = false,
  });

  @override
  List<Object?> get props => [mnemonic, isTestnet];
}

class UnlockWalletEvent extends WalletEvent {
  final String pin;

  const UnlockWalletEvent({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class LockWalletEvent extends WalletEvent {
  const LockWalletEvent();
}

class RefreshBalanceEvent extends WalletEvent {
  const RefreshBalanceEvent();
}

class SwitchNetworkEvent extends WalletEvent {
  final bool isTestnet;

  const SwitchNetworkEvent({required this.isTestnet});

  @override
  List<Object?> get props => [isTestnet];
}

class BackupWalletEvent extends WalletEvent {
  const BackupWalletEvent();
}

class DeleteWalletEvent extends WalletEvent {
  const DeleteWalletEvent();
}

class CheckWalletExistsEvent extends WalletEvent {
  const CheckWalletExistsEvent();
}
