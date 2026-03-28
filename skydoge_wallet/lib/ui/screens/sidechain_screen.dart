import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/sidechain_info.dart';
import '../../services/drivechain_service.dart';
import '../../services/rpc_service.dart';
import 'package:provider/provider.dart';

class SidechainScreen extends StatefulWidget {
  const SidechainScreen({super.key});

  @override
  State<SidechainScreen> createState() => _SidechainScreenState();
}

class _SidechainScreenState extends State<SidechainScreen> {
  List<SidechainInfo> _sidechains = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSidechains();
  }

  Future<void> _loadSidechains() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final walletState = context.read<WalletBloc>().state;
      if (walletState is! WalletLoaded) return;

      final networkConfig = walletState.isTestnet
          ? NetworkConfig.testnet()
          : NetworkConfig.mainnet();
      final rpcService = RpcService(config: networkConfig);
      final drivechainService = DrivechainService(rpcService: rpcService);

      final sidechains = await drivechainService.getSidechains();

      setState(() {
        _sidechains = sidechains;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load sidechains: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sidechains'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSidechains,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSidechains,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _sidechains.isEmpty
                  ? _buildEmptyState()
                  : _buildSidechainsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'No Sidechains Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sidechains will appear here when available',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildSidechainsList() {
    return RefreshIndicator(
      onRefresh: _loadSidechains,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sidechains.length,
        itemBuilder: (context, index) {
          final sidechain = _sidechains[index];
          return _buildSidechainCard(sidechain);
        },
      ),
    );
  }

  Widget _buildSidechainCard(SidechainInfo sidechain) {
    final iconData = _getSidechainIcon(sidechain.name);
    final color = _getSidechainColor(sidechain.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showSidechainDetails(sidechain),
        borderRadius: BorderRadius.circular(16),
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: color, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sidechain.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: sidechain.isActive
                                ? AppTheme.successColor.withOpacity(0.2)
                                : AppTheme.warningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            sidechain.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: sidechain.isActive
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              if (sidechain.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  sidechain.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Deposits', sidechain.depositCount.toString()),
                  _buildStat('Withdrawals', sidechain.withdrawalCount.toString()),
                  _buildStat('Version', sidechain.version.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getSidechainIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('eth')) return Icons.toll;
    if (nameLower.contains('thunder')) return Icons.flash_on;
    if (nameLower.contains('bitasset') || nameLower.contains('nft')) return Icons.image;
    if (nameLower.contains('dns')) return Icons.dns;
    if (nameLower.contains('hive')) return Icons.psychology;
    return Icons.link;
  }

  Color _getSidechainColor(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('eth')) return Colors.purple;
    if (nameLower.contains('thunder')) return Colors.amber;
    if (nameLower.contains('bitasset') || nameLower.contains('nft')) return Colors.blue;
    if (nameLower.contains('dns')) return Colors.green;
    if (nameLower.contains('hive')) return Colors.orange;
    return AppTheme.primaryColor;
  }

  void _showSidechainDetails(SidechainInfo sidechain) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      sidechain.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (sidechain.description.isNotEmpty) ...[
                    Text(
                      sidechain.description,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildDetailRow('Status', sidechain.status),
                  _buildDetailRow('Version', sidechain.version.toString()),
                  _buildDetailRow('Sidechain ID', sidechain.sidechainId),
                  const SizedBox(height: 24),
                  const Text(
                    'Cross-Chain Transactions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (sidechain.deposits.isEmpty && sidechain.withdrawals.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No cross-chain transactions yet',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    )
                  else ...[
                    if (sidechain.deposits.isNotEmpty) ...[
                      const Text(
                        'Recent Deposits',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...sidechain.deposits.map((d) => _buildCrossChainTile(d)),
                      const SizedBox(height: 16),
                    ],
                    if (sidechain.withdrawals.isNotEmpty) ...[
                      const Text(
                        'Recent Withdrawals',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...sidechain.withdrawals.map((w) => _buildCrossChainTile(w)),
                    ],
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: sidechain.isActive
                          ? () => _showDepositDialog(sidechain)
                          : null,
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text('Deposit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: sidechain.isActive
                          ? () => _showWithdrawDialog(sidechain)
                          : null,
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text('Withdraw'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildCrossChainTile(CrossChainTransaction tx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          tx.type == CrossChainTxType.deposit
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: tx.type == CrossChainTxType.deposit
              ? AppTheme.successColor
              : AppTheme.warningColor,
        ),
        title: Text(Formatters.formatSatoshis(tx.amount)),
        subtitle: Text(
          '${tx.type.name.toUpperCase()} - ${tx.status.name}',
        ),
        trailing: Text(
          Formatters.relativeTime(tx.timestamp),
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ),
    );
  }

  void _showDepositDialog(SidechainInfo sidechain) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deposit to ${sidechain.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            suffixText: 'SKYDOGE',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deposit initiated to ${sidechain.name}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(SidechainInfo sidechain) {
    final amountController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Withdraw from ${sidechain.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                suffixText: 'SKYDOGE',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Withdrawal initiated from ${sidechain.name}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
