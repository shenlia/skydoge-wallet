import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../core/chain/chain_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

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

  @override
  void dispose() {
    _mnemonicController.dispose();
    _wifController.dispose();
    super.dispose();
  }

  void _createWallet() {
    setState(() => _isLoading = true);
    context.read<WalletBloc>().add(CreateWalletEvent(isTestnet: _isTestnet));
  }

  void _recoverWallet() {
    final mnemonic = _mnemonicController.text.trim();
    if (!Validators.isValidMnemonic(mnemonic)) {
      _showMessage('Please enter a valid 12-word mnemonic');
      return;
    }

    setState(() => _isLoading = true);
    context.read<WalletBloc>().add(
          RecoverWalletEvent(
            mnemonic: mnemonic,
            isTestnet: _isTestnet,
          ),
        );
  }

  void _importWif() {
    final wif = _wifController.text.trim();
    if (wif.isEmpty) {
      _showMessage('Please enter a valid WIF private key');
      return;
    }

    setState(() => _isLoading = true);
    context.read<WalletBloc>().add(
          ImportWifWalletEvent(
            wif: wif,
            isTestnet: _isTestnet,
          ),
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final chain = _isTestnet ? ChainConfig.testnet : ChainConfig.mainnet;

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
              const Text(
                'Skydoge Wallet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Non-custodial wallet for the Skydoge mainchain',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              _buildChainSummary(chain),
              const SizedBox(height: 24),
              if (!_isRecoverMode && !_isWifMode) ...[
                _buildOptionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Create New Wallet',
                  description: 'Generate a new mnemonic wallet for Skydoge',
                  onTap: _createWallet,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  icon: Icons.restore,
                  title: 'Recover Mnemonic Wallet',
                  description: 'Restore a 12-word mnemonic wallet',
                  onTap: () => setState(() {
                    _isRecoverMode = true;
                    _isWifMode = false;
                  }),
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  icon: Icons.vpn_key,
                  title: 'Import WIF Wallet',
                  description: 'Import an existing private key in WIF format',
                  onTap: () => setState(() {
                    _isRecoverMode = false;
                    _isWifMode = true;
                  }),
                ),
              ] else if (_isRecoverMode) ...[
                _buildBackButton(),
                const SizedBox(height: 24),
                TextField(
                  controller: _mnemonicController,
                  maxLines: 3,
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
                      : const Text('Recover Wallet'),
                ),
              ] else ...[
                _buildBackButton(),
                const SizedBox(height: 24),
                TextField(
                  controller: _wifController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'WIF Private Key',
                    hintText: 'Enter your WIF private key',
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _importWif,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Import WIF Wallet'),
                ),
              ],
              const SizedBox(height: 24),
              _buildNetworkSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChainSummary(ChainConfig chain) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chain.isTestnet ? 'Skydoge Testnet' : 'Skydoge Mainnet',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Bech32 HRP: ${chain.bech32Hrp}'),
            Text('Genesis: ${Formatters.formatTxid(chain.genesisHash)}'),
            Text('Message start: ${chain.messageStart.map((v) => '0x${v.toRadixString(16)}').join(', ')}'),
          ],
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
                child: Icon(icon, color: AppTheme.primaryColor, size: 32),
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
      onPressed: () => setState(() {
        _isRecoverMode = false;
        _isWifMode = false;
      }),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isTestnet ? 'Testnet' : 'Mainnet',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
