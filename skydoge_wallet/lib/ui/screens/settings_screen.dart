import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/donation_constants.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/node_repository.dart';
import '../../generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NodeRepository _nodeRepository = NodeRepository();
  bool _biometricEnabled = false;
  bool _donationEnabled = true;
  bool _useCustomNode = false;
  NodeConfig? _customNodeConfig;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is! WalletLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(s.settings),
              _buildWalletInfo(state, s),
              const SizedBox(height: 24),
              _buildSectionHeader(s.language),
              _buildLanguageSettings(context),
              const SizedBox(height: 24),
              _buildSectionHeader(s.biometricAuth),
              _buildSecuritySettings(s),
              const SizedBox(height: 24),
              _buildSectionHeader(s.network),
              _buildNetworkSettings(state, s),
              const SizedBox(height: 24),
              _buildSectionHeader(s.donation),
              _buildDonationSettings(s),
              const SizedBox(height: 24),
              _buildSectionHeader(s.deleteWallet),
              _buildDangerZone(context, s),
              const SizedBox(height: 32),
              _buildAboutSection(s),
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

  Widget _buildWalletInfo(WalletLoaded state, S s) {
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
                      Text(
                        s.appTitle,
                        style: const TextStyle(
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
                _showBackupDialog(context, s);
              },
              child: Row(
                children: [
                  const Icon(Icons.key, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s.viewMnemonic)),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSettings(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: localeProvider.locale.languageCode,
            onChanged: (value) {
              localeProvider.setLocale(const Locale('en'));
            },
            secondary: const Icon(Icons.language),
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('简体中文'),
            value: 'zh',
            groupValue: localeProvider.locale.languageCode,
            onChanged: (value) {
              localeProvider.setLocale(const Locale('zh'));
            },
            secondary: const Icon(Icons.language),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(S s) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(s.enableBiometric),
            subtitle: Text(
              s.biometricAuth,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() => _biometricEnabled = value);
            },
            secondary: const Icon(Icons.fingerprint),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(s.changePin),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSettings(WalletLoaded state, S s) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(s.network),
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
                    state.isTestnet ? s.testnet.toUpperCase() : s.mainnet.toUpperCase(),
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
              _showNetworkSwitchDialog(context, state.isTestnet, s);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dns),
            title: Text(s.customNode ?? 'Custom Node'),
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
              _showCustomNodeDialog(context, s);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonationSettings(S s) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(s.donationEnabled),
            subtitle: Text(
              '${s.donationDesc}\n${Formatters.formatAddress(DonationConstants.donationAddress)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            value: _donationEnabled,
            onChanged: (value) {
              setState(() => _donationEnabled = value);
            },
            secondary: const Icon(Icons.volunteer_activism, color: AppTheme.accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, S s) {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.1),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.errorColor),
            title: Text('Lock Wallet', style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              context.read<WalletBloc>().add(const LockWalletEvent());
            },
          ),
          const Divider(height: 1, color: AppTheme.errorColor),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
            title: Text(s.deleteWallet, style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              _showDeleteConfirmation(context, s);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(S s) {
    return Center(
      child: Column(
        children: [
          Text(
            '${s.appTitle} v1.0.2',
            style: const TextStyle(color: Colors.grey),
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

  void _showBackupDialog(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletBackedUp) {
            return AlertDialog(
              title: Text(s.backupWallet),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.backupWarning,
                    style: const TextStyle(fontSize: 14),
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
                  child: Text(s.cancel),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showNetworkSwitchDialog(BuildContext context, bool isTestnet, S s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Switch Network'),
        content: const Text(
          'Are you sure you want to switch networks? This will clear cached data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
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

  void _showDeleteConfirmation(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteWallet),
        content: Text(
          s.deleteWalletWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<WalletBloc>().add(const DeleteWalletEvent());
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  void _showCustomNodeDialog(BuildContext context, S s) {
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
                  hintText: '8332 (mainnet) or 18332 (testnet)',
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
                  SnackBar(content: Text('Reset to default node')),
                );
                setState(() {});
              }
            },
            child: const Text('Reset to Default'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final host = hostController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 8332;
              final user = userController.text.trim();
              final password = passwordController.text.trim();

              if (host.isEmpty || user.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
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
            child: Text(s.send),
          ),
        ],
      ),
    );
  }
}
