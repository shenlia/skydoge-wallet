import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../core/theme/app_theme.dart';
import '../../generated/l10n.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _mnemonicController = TextEditingController();
  bool _isRecoverMode = false;
  bool _isTestnet = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _mnemonicController.dispose();
    super.dispose();
  }

  void _createWallet() {
    setState(() => _isLoading = true);
    context.read<WalletBloc>().add(CreateWalletEvent(isTestnet: _isTestnet));
  }

  void _recoverWallet() {
    final s = S.of(context);
    if (_mnemonicController.text.trim().split(' ').length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.pleaseEnterValidMnemonic)),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<WalletBloc>().add(RecoverWalletEvent(
      mnemonic: _mnemonicController.text.trim(),
      isTestnet: _isTestnet,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: SafeArea(
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
              Text(
                s.skydogeWallet,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.yourGatewayToSkydoge,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 48),
              if (!_isRecoverMode) ...[
                _buildOptionCard(
                  icon: Icons.add_circle_outline,
                  title: s.createNewWallet,
                  description: s.createNewWalletDesc,
                  onTap: _createWallet,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  icon: Icons.restore,
                  title: s.recoverExistingWallet,
                  description: s.recoverExistingWalletDesc,
                  onTap: () => setState(() => _isRecoverMode = true),
                ),
              ] else ...[
                _buildBackButton(s),
                const SizedBox(height: 24),
                TextField(
                  controller: _mnemonicController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: s.mnemonicPhrase,
                    hintText: s.enterMnemonicHint,
                    prefixIcon: const Icon(Icons.key),
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
                      : Text(s.recoverWallet),
                ),
              ],
              const SizedBox(height: 24),
              _buildNetworkSwitch(s),
            ],
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

  Widget _buildBackButton(S s) {
    return TextButton.icon(
      onPressed: () => setState(() => _isRecoverMode = false),
      icon: const Icon(Icons.arrow_back),
      label: Text(s.back),
    );
  }

  Widget _buildNetworkSwitch(S s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.network,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isTestnet ? s.testnet : s.mainnet,
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
