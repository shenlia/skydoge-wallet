import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/address_service.dart';
import 'services/secure_storage_service.dart';
import 'services/rpc_service.dart';
import 'services/transaction_service.dart';
import 'blocs/wallet/wallet_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/network_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final addressService = AddressService();
  final secureStorageService = SecureStorageService();

  final walletBloc = WalletBloc(
    addressService: addressService,
    secureStorageService: secureStorageService,
  );

  final networkConfig = NetworkConfig.mainnet();
  final rpcService = RpcService(config: networkConfig);
  final transactionService = TransactionService(
    rpcService: rpcService,
    addressService: addressService,
  );

  final transactionBloc = TransactionBloc(
    transactionService: transactionService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AddressService>.value(value: addressService),
        Provider<SecureStorageService>.value(value: secureStorageService),
        Provider<RpcService>.value(value: rpcService),
        Provider<TransactionService>.value(value: transactionService),
        BlocProvider<WalletBloc>.value(value: walletBloc),
        BlocProvider<TransactionBloc>.value(value: transactionBloc),
      ],
      child: const SkydogeWalletApp(),
    ),
  );
}
