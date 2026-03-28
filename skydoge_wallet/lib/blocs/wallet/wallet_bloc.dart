import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/address_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/rpc_service.dart';
import '../../core/constants/network_constants.dart';
import '../../data/models/wallet.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final AddressService _addressService;
  final SecureStorageService _secureStorageService;
  RpcService? _rpcService;

  WalletBloc({
    required AddressService addressService,
    required SecureStorageService secureStorageService,
  })  : _addressService = addressService,
        _secureStorageService = secureStorageService,
        super(const WalletInitial()) {
    on<CheckWalletExistsEvent>(_onCheckWalletExists);
    on<CreateWalletEvent>(_onCreateWallet);
    on<RecoverWalletEvent>(_onRecoverWallet);
    on<UnlockWalletEvent>(_onUnlockWallet);
    on<LockWalletEvent>(_onLockWallet);
    on<RefreshBalanceEvent>(_onRefreshBalance);
    on<SwitchNetworkEvent>(_onSwitchNetwork);
    on<BackupWalletEvent>(_onBackupWallet);
    on<DeleteWalletEvent>(_onDeleteWallet);
  }

  void _initRpcService(bool isTestnet) {
    final config = isTestnet ? NetworkConfig.testnet() : NetworkConfig.mainnet();
    _rpcService?.dispose();
    _rpcService = RpcService(config: config);
  }

  Future<void> _onCheckWalletExists(
    CheckWalletExistsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final mnemonic = await _secureStorageService.getMnemonic();
      final hasPin = await _secureStorageService.hasPin();

      if (mnemonic == null) {
        emit(const WalletNotFound());
      } else if (hasPin) {
        emit(WalletLocked(hasPin: true));
      } else {
        emit(const WalletNotFound());
      }
    } catch (e) {
      emit(WalletError(message: 'Failed to check wallet: $e'));
    }
  }

  Future<void> _onCreateWallet(
    CreateWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final mnemonic = await _addressService.generateMnemonic();
      final walletData = await _addressService.deriveWallet(
        mnemonic,
        isTestnet: event.isTestnet,
      );

      await _secureStorageService.saveMnemonic(mnemonic);

      final wallet = Wallet(
        mnemonic: mnemonic,
        seed: walletData.seed,
        privateKey: walletData.privateKey,
        publicKey: walletData.publicKey,
        receivingAddress: walletData.receivingAddress,
        network: walletData.network,
        createdAt: DateTime.now(),
      );

      await _secureStorageService.saveWalletData(wallet.toJson());

      emit(WalletCreated(wallet: wallet, mnemonic: mnemonic));
    } catch (e) {
      emit(WalletError(message: 'Failed to create wallet: $e'));
    }
  }

  Future<void> _onRecoverWallet(
    RecoverWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final walletData = await _addressService.deriveWallet(
        event.mnemonic,
        isTestnet: event.isTestnet,
      );

      await _secureStorageService.saveMnemonic(event.mnemonic);

      final wallet = Wallet(
        mnemonic: event.mnemonic,
        seed: walletData.seed,
        privateKey: walletData.privateKey,
        publicKey: walletData.publicKey,
        receivingAddress: walletData.receivingAddress,
        network: walletData.network,
        createdAt: DateTime.now(),
      );

      await _secureStorageService.saveWalletData(wallet.toJson());

      emit(WalletCreated(wallet: wallet, mnemonic: event.mnemonic));
    } catch (e) {
      emit(WalletError(message: 'Failed to recover wallet: $e'));
    }
  }

  Future<void> _onUnlockWallet(
    UnlockWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final isValid = await _secureStorageService.verifyPin(event.pin);
      if (!isValid) {
        emit(const WalletError(message: 'Invalid PIN'));
        return;
      }

      final walletData = await _secureStorageService.getWalletData();
      if (walletData == null) {
        emit(const WalletError(message: 'Wallet data not found'));
        return;
      }

      final mnemonic = await _secureStorageService.getMnemonic();
      if (mnemonic == null) {
        emit(const WalletError(message: 'Mnemonic not found'));
        return;
      }

      final wallet = Wallet.fromJson(walletData);
      final network = wallet.network;
      _initRpcService(network == 1);

      emit(WalletUnlocked(wallet: wallet));
    } catch (e) {
      emit(WalletError(message: 'Failed to unlock wallet: $e'));
    }
  }

  Future<void> _onLockWallet(
    LockWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    final hasPin = await _secureStorageService.hasPin();
    emit(WalletLocked(hasPin: hasPin));
  }

  Future<void> _onRefreshBalance(
    RefreshBalanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    final currentState = state as WalletLoaded;

    try {
      _initRpcService(currentState.isTestnet);
      final balance = await _rpcService!.getWalletBalance();
      final transactions = await _rpcService!.listTransactions(50);

      emit(WalletLoaded(
        wallet: currentState.wallet,
        balance: balance,
        transactions: transactions,
        isTestnet: currentState.isTestnet,
      ));
    } catch (e) {
      emit(WalletError(message: 'Failed to refresh balance: $e'));
    }
  }

  Future<void> _onSwitchNetwork(
    SwitchNetworkEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    final currentState = state as WalletLoaded;

    try {
      final walletData = await _addressService.deriveWallet(
        currentState.wallet.mnemonic,
        isTestnet: event.isTestnet,
      );

      final updatedWallet = currentState.wallet.copyWith(
        receivingAddress: walletData.receivingAddress,
        network: event.isTestnet ? 1 : 0,
      );

      await _secureStorageService.saveWalletData(updatedWallet.toJson());

      _initRpcService(event.isTestnet);
      final balance = await _rpcService!.getWalletBalance();
      final transactions = await _rpcService!.listTransactions(50);

      emit(WalletLoaded(
        wallet: updatedWallet,
        balance: balance,
        transactions: transactions,
        isTestnet: event.isTestnet,
      ));
    } catch (e) {
      emit(WalletError(message: 'Failed to switch network: $e'));
    }
  }

  Future<void> _onBackupWallet(
    BackupWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    try {
      final mnemonic = await _secureStorageService.getMnemonic();
      if (mnemonic == null) {
        emit(const WalletError(message: 'Mnemonic not found'));
        return;
      }

      emit(WalletBackedUp(mnemonic: mnemonic));
    } catch (e) {
      emit(WalletError(message: 'Failed to backup wallet: $e'));
    }
  }

  Future<void> _onDeleteWallet(
    DeleteWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      await _secureStorageService.clearAll();
      emit(const WalletDeleted());
    } catch (e) {
      emit(WalletError(message: 'Failed to delete wallet: $e'));
    }
  }

  @override
  Future<void> close() {
    _rpcService?.dispose();
    return super.close();
  }
}
