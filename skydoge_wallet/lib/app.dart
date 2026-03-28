import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/wallet/wallet_bloc.dart';
import 'blocs/wallet/wallet_event.dart';
import 'blocs/wallet/wallet_state.dart';
import 'core/theme/app_theme.dart';
import 'core/locale/locale_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/backup_screen.dart';
import 'generated/l10n.dart';

class SkydogeWalletApp extends StatelessWidget {
  const SkydogeWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Skydoge Wallet',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const WalletWrapper(),
        );
      },
    );
  }
}

class WalletWrapper extends StatefulWidget {
  const WalletWrapper({super.key});

  @override
  State<WalletWrapper> createState() => _WalletWrapperState();
}

class _WalletWrapperState extends State<WalletWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const CheckWalletExistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletInitial || state is WalletLoading) {
          return const SplashScreen();
        } else if (state is WalletNotFound) {
          return const WelcomeScreen();
        } else if (state is WalletCreated) {
          return BackupScreen(
            wallet: state.wallet,
            mnemonic: state.mnemonic,
          );
        } else if (state is WalletLocked) {
          return const LockScreen();
        } else if (state is WalletUnlocked) {
          return const HomeScreen();
        } else if (state is WalletLoaded) {
          return const HomeScreen();
        } else if (state is WalletError) {
          return ErrorScreen(message: state.message);
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).skydogeWallet,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _unlock() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    context.read<WalletBloc>().add(UnlockWalletEvent(pin: _pinController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).enterPin,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 8,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).enterPin,
                  errorText: _error,
                  counterText: '',
                ),
                onSubmitted: (_) => _unlock(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _unlock,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(S.of(context).unlock),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<WalletBloc>().add(const CheckWalletExistsEvent());
                },
                child: Text(S.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
