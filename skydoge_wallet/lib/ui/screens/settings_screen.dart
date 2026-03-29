import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/donation_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/node_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NodeRepository _nodeRepository = NodeRepository();
  bool _biometricEnabled = false;
  bool _useCustomNode = false;
  NodeConfig? _customNodeConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is! WalletLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Wallet'),
              _buildWalletInfo(state),
              const SizedBox(height: 24),
              _buildSectionHeader('Security'),
              _buildSecuritySettings(),
              const SizedBox(height: 24),
              _buildSectionHeader('Network'),
              _buildNetworkSettings(state),
              const SizedBox(height: 24),
              _buildSectionHeader('Donation'),
              _buildDonationSettings(),
              const SizedBox(height: 24),
              _buildSectionHeader('Danger Zone'),
              _buildDangerZone(context),
              const SizedBox(height: 32),
              _buildAboutSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildWalletInfo(WalletLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skydoge Wallet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        Formatters.formatAddress(state.wallet.receivingAddress),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                context.read<WalletBloc>().add(const BackupWalletEvent());
                _showBackupDialog(context);
              },
              child: Row(
                children: [
                  const Icon(Icons.key, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('View Recovery Phrase')),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face to unlock'),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() => _biometricEnabled = value);
            },
            secondary: const Icon(Icons.fingerprint),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change PIN'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement change PIN
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSettings(WalletLoaded state) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Network'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: state.isTestnet
                        ? AppTheme.warningColor.withOpacity(0.2)
                        : AppTheme.successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    state.isTestnet ? 'TESTNET' : 'MAINNET',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: state.isTestnet ? AppTheme.warningColor : AppTheme.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              _showNetworkSwitchDialog(context, state.isTestnet);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Custom Node'),
            subtitle: FutureBuilder<bool>(
              future: _nodeRepository.isUsingCustomNode(),
              builder: (context, snapshot) {
                final usingCustom = snapshot.data ?? false;
                return Text(
                  usingCustom ? 'Enabled' : 'Using default',
                  style: TextStyle(
                    fontSize: 12,
                    color: usingCustom ? AppTheme.successColor : Colors.grey[400],
                  ),
                );
              },
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showCustomNodeDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonationSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.volunteer_activism, color: AppTheme.accentColor),
            title: const Text('Mandatory 0.01% Donation'),
            subtitle: Text(
              'Donates to: ${Formatters.formatAddress(DonationConstants.donationAddress)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            trailing: const Text(
              'Always On',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.1),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.errorColor),
            title: const Text('Lock Wallet', style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              context.read<WalletBloc>().add(const LockWalletEvent());
            },
          ),
          const Divider(height: 1, color: AppTheme.errorColor),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
            title: const Text('Delete Wallet', style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Skydoge Wallet v1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'Built with Flutter',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletBackedUp) {
            return AlertDialog(
              title: const Text('Recovery Phrase'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Write down these words in order and store them safely:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.mnemonic,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showNetworkSwitchDialog(BuildContext context, bool isTestnet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Network'),
        content: const Text(
          'Are you sure you want to switch networks? This will clear cached data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WalletBloc>().add(SwitchNetworkEvent(isTestnet: !isTestnet));
            },
            child: Text(isTestnet ? 'Switch to Mainnet' : 'Switch to Testnet'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wallet'),
        content: const Text(
          'Are you sure you want to delete this wallet? This action cannot be undone. Make sure you have backed up your recovery phrase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<WalletBloc>().add(const DeleteWalletEvent());
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCustomNodeDialog(BuildContext context) {
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '8332');
    final userController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Node Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connect to your own Skydoge node by providing the RPC configuration below.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Host',
                  hintText: 'e.g., node1.skydoge.net',
                  prefixIcon: Icon(Icons.dns),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: '8332 (mainnet RPC) or 18332 (testnet RPC)',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: 'RPC Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'RPC Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.warningColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure your node has RPC enabled and allows connections from your device.',
                        style: TextStyle(fontSize: 11, color: AppTheme.warningColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _nodeRepository.resetToDefault();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset to default node')),
                );
                setState(() {});
              }
            },
            child: const Text('Reset to Default'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final host = hostController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 8332;
              final user = userController.text.trim();
              final password = passwordController.text.trim();

              if (host.isEmpty || user.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              final config = NodeConfig(
                host: host,
                port: port,
                user: user,
                password: password,
              );

              await _nodeRepository.saveCustomNodeConfig(config);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Custom node saved. Restart app to apply.'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
