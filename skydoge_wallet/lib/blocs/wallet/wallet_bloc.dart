import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/chain/chain_config.dart';
import '../../core/constants/network_constants.dart';
import '../../data/models/wallet.dart';
import '../../services/address_service.dart';
import '../../services/rpc_service.dart';
import '../../services/secure_storage_service.dart';
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
    on<ImportWifWalletEvent>(_onImportWifWallet);
    on<UnlockWalletEvent>(_onUnlockWallet);
    on<LockWalletEvent>(_onLockWallet);
    on<RefreshBalanceEvent>(_onRefreshBalance);
    on<SwitchNetworkEvent>(_onSwitchNetwork);
    on<BackupWalletEvent>(_onBackupWallet);
    on<DeleteWalletEvent>(_onDeleteWallet);
  }

  ChainConfig chainFor(bool isTestnet) => NetworkConstants.chainFor(isTestnet);

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
      final walletData = await _secureStorageService.getWalletData();
      final hasPin = await _secureStorageService.hasPin();

      if (walletData == null) {
        emit(const WalletNotFound());
      } else if (hasPin) {
        emit(WalletLocked(hasPin: true));
      } else {
        final wallet = Wallet.fromJson(walletData as Map<String, dynamic>);
        _initRpcService(wallet.isTestnet);
        emit(
          WalletLoaded(
            wallet: wallet,
            balance: const WalletBalance(
              confirmed: 0,
              unconfirmed: 0,
              immature: 0,
              sidechain: 0,
            ),
            transactions: const [],
            isTestnet: wallet.isTestnet,
          ),
        );
      }
    } catch (error) {
      emit(WalletError(message: 'Failed to check wallet: $error'));
    }
  }

  Future<void> _onCreateWallet(
    CreateWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final chain = chainFor(event.isTestnet);
      final mnemonic = await _addressService.generateMnemonic();
      final walletData = await _addressService.deriveWallet(mnemonic, chain: chain);

      await _secureStorageService.saveMnemonic(mnemonic);

      final wallet = Wallet(
        mnemonic: mnemonic,
        seed: walletData.seed,
        privateKey: walletData.privateKey,
        publicKey: walletData.publicKey,
        wif: walletData.wif,
        receivingAddress: walletData.receivingAddress,
        network: walletData.network,
        walletType: walletData.walletType,
        derivationPath: walletData.derivationPath,
        createdAt: DateTime.now(),
      );

      await _secureStorageService.saveWalletData(wallet.toJson());
      emit(WalletCreated(wallet: wallet, mnemonic: mnemonic));
    } catch (error) {
      emit(WalletError(message: 'Failed to create wallet: $error'));
    }
  }

  Future<void> _onRecoverWallet(
    RecoverWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final chain = chainFor(event.isTestnet);
      final walletData =
          await _addressService.deriveWallet(event.mnemonic, chain: chain);

      await _secureStorageService.saveMnemonic(event.mnemonic);

      final wallet = Wallet(
        mnemonic: event.mnemonic,
        seed: walletData.seed,
        privateKey: walletData.privateKey,
        publicKey: walletData.publicKey,
        wif: walletData.wif,
        receivingAddress: walletData.receivingAddress,
        network: walletData.network,
        walletType: walletData.walletType,
        derivationPath: walletData.derivationPath,
        createdAt: DateTime.now(),
      );

      await _secureStorageService.saveWalletData(wallet.toJson());
      emit(WalletCreated(wallet: wallet, mnemonic: event.mnemonic));
    } catch (error) {
      emit(WalletError(message: 'Failed to recover wallet: $error'));
    }
  }

  Future<void> _onImportWifWallet(
    ImportWifWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final chain = chainFor(event.isTestnet);
      final walletData = await _addressService.importFromWif(
        event.wif.trim(),
        chain: chain,
      );

      final wallet = Wallet(
        mnemonic: '',
        seed: '',
        privateKey: walletData.privateKey,
        publicKey: walletData.publicKey,
        wif: walletData.wif,
        receivingAddress: walletData.receivingAddress,
        network: walletData.network,
        walletType: walletData.walletType,
        derivationPath: walletData.derivationPath,
        createdAt: DateTime.now(),
      );

      await _secureStorageService.saveWalletData(wallet.toJson());
      emit(WalletImported(wallet: wallet));
    } catch (error) {
      emit(WalletError(message: 'Failed to import WIF wallet: $error'));
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

      final wallet = Wallet.fromJson(walletData as Map<String, dynamic>);
      _initRpcService(wallet.isTestnet);

      emit(WalletUnlocked(wallet: wallet));
      add(const RefreshBalanceEvent());
    } catch (error) {
      emit(WalletError(message: 'Failed to unlock wallet: $error'));
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
    Wallet? wallet;
    if (state is WalletLoaded) {
      wallet = (state as WalletLoaded).wallet;
    } else if (state is WalletUnlocked) {
      wallet = (state as WalletUnlocked).wallet;
    } else if (state is WalletImported) {
      wallet = (state as WalletImported).wallet;
    }

    if (wallet == null) {
      return;
    }

    try {
      _initRpcService(wallet.isTestnet);
      final balance = await _rpcService!.getWalletBalance();
      final transactions = await _rpcService!.listTransactions(50);

      emit(
        WalletLoaded(
          wallet: wallet,
          balance: balance,
          transactions: transactions,
          isTestnet: wallet.isTestnet,
        ),
      );
    } catch (error) {
      emit(WalletError(message: 'Failed to refresh balance: $error'));
    }
  }

  Future<void> _onSwitchNetwork(
    SwitchNetworkEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    final currentState = state as WalletLoaded;
    emit(const WalletLoading());

    try {
      final chain = chainFor(event.isTestnet);
      final updatedWallet = currentState.wallet.walletType == 'wif'
          ? currentState.wallet.copyWith(
              receivingAddress: _addressService.getAddressFromPrivateKey(
                currentState.wallet.privateKey,
                chain: chain,
              ),
              network: event.isTestnet ? 1 : 0,
            )
          : currentState.wallet.copyWith(
              receivingAddress: (await _addressService.deriveWallet(
                currentState.wallet.mnemonic,
                chain: chain,
              ))
                  .receivingAddress,
              network: event.isTestnet ? 1 : 0,
              derivationPath: chain.derivationPath,
            );

      await _secureStorageService.saveWalletData(updatedWallet.toJson());

      _initRpcService(event.isTestnet);
      final balance = await _rpcService!.getWalletBalance();
      final transactions = await _rpcService!.listTransactions(50);

      emit(
        WalletLoaded(
          wallet: updatedWallet,
          balance: balance,
          transactions: transactions,
          isTestnet: event.isTestnet,
        ),
      );
    } catch (error) {
      emit(WalletError(message: 'Failed to switch network: $error'));
    }
  }

  Future<void> _onBackupWallet(
    BackupWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    try {
      final wallet = (state as WalletLoaded).wallet;
      if (wallet.walletType == 'wif') {
        emit(WalletBackedUp(mnemonic: wallet.wif));
        return;
      }

      final mnemonic = await _secureStorageService.getMnemonic();
      if (mnemonic == null) {
        emit(const WalletError(message: 'Mnemonic not found'));
        return;
      }

      emit(WalletBackedUp(mnemonic: mnemonic));
    } catch (error) {
      emit(WalletError(message: 'Failed to backup wallet: $error'));
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
    } catch (error) {
      emit(WalletError(message: 'Failed to delete wallet: $error'));
    }
  }

  @override
  Future<void> close() {
    _rpcService?.dispose();
    return super.close();
  }
}
