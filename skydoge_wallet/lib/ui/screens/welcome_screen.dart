import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../widgets/status_banner.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _mnemonicController = TextEditingController();
  final _wifController = TextEditingController();
  bool _isRecoverMode = false;
  bool _isWifMode = false;
  bool _isTestnet = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mnemonicController.dispose();
    _wifController.dispose();
    super.dispose();
  }

  void _createWallet() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    context.read<WalletBloc>().add(CreateWalletEvent(isTestnet: _isTestnet));
  }

  void _recoverWallet() {
    if (_isWifMode) {
      if (!Validators.isValidWif(_wifController.text.trim())) {
        setState(() => _errorMessage = 'Please enter a valid WIF private key');
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      context.read<WalletBloc>().add(ImportWifWalletEvent(
        wif: _wifController.text.trim(),
        isTestnet: _isTestnet,
      ));
      return;
    }

    if (!Validators.isValidMnemonic(_mnemonicController.text.trim())) {
      setState(() => _errorMessage = 'Please enter a valid 12-word mnemonic');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    context.read<WalletBloc>().add(RecoverWalletEvent(
      mnemonic: _mnemonicController.text.trim(),
      isTestnet: _isTestnet,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is WalletError) {
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
            } else if (state is WalletCreated) {
              setState(() {
                _isLoading = false;
                _errorMessage = null;
              });
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.account_balance_wallet,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Skydoge Wallet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your gateway to the Skydoge ecosystem',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 48),
                if (_errorMessage != null) ...[
                  StatusBanner(
                    message: _errorMessage!,
                    color: AppTheme.errorColor,
                    icon: Icons.error_outline,
                    margin: const EdgeInsets.only(bottom: 24),
                  ),
                ],
                if (!_isRecoverMode) ...[
                  _buildOptionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Create New Wallet',
                    description: 'Generate a new wallet with a secure mnemonic phrase',
                    onTap: _createWallet,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    icon: Icons.restore,
                    title: 'Recover Existing Wallet',
                    description: 'Restore your wallet using a 12-word mnemonic phrase or WIF private key',
                    onTap: () => setState(() => _isRecoverMode = true),
                  ),
                ] else ...[
                  _buildBackButton(),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Mnemonic')),
                      ButtonSegment(value: true, label: Text('WIF')),
                    ],
                    selected: {_isWifMode},
                    onSelectionChanged: (value) {
                      setState(() => _isWifMode = value.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isWifMode)
                    TextField(
                      controller: _wifController,
                      maxLines: 2,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'WIF Private Key',
                        hintText: 'Enter your WIF private key',
                        prefixIcon: Icon(Icons.vpn_key),
                      ),
                    )
                  else
                    TextField(
                      controller: _mnemonicController,
                      maxLines: 3,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Mnemonic Phrase',
                        hintText: 'Enter your 12-word mnemonic phrase',
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _recoverWallet,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isWifMode ? 'Import WIF' : 'Recover Wallet'),
                  ),
                ],
                const SizedBox(height: 24),
                _buildNetworkSwitch(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () => setState(() => _isRecoverMode = false),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Back'),
    );
  }

  Widget _buildNetworkSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Network',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isTestnet ? 'Testnet' : 'Mainnet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            Switch(
              value: _isTestnet,
              onChanged: (value) => setState(() => _isTestnet = value),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
