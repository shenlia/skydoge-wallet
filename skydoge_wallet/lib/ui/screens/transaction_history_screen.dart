import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/wallet_warning_banner.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletBloc>().add(const RefreshBalanceEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is! WalletLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = state.transactions;
          final incomingCount = transactions
              .where((tx) => tx.direction.name == 'incoming')
              .length;
          final outgoingCount = transactions.length - incomingCount;
          final donationCount = transactions.where((tx) => tx.isDonation).length;

          if (transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.warningMessage != null) ...[
                      WalletWarningBanner(
                        message: state.warningMessage!,
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No transactions found yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WalletBloc>().add(const RefreshBalanceEvent());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.warningMessage != null) ...[
                        WalletWarningBanner(
                          message: state.warningMessage!,
                          margin: const EdgeInsets.only(bottom: 12),
                        ),
                      ],
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSummaryChip(
                            icon: Icons.swap_horiz,
                            label: '${transactions.length} total',
                            color: AppTheme.primaryColor,
                          ),
                          _buildSummaryChip(
                            icon: Icons.arrow_downward,
                            label: '$incomingCount received',
                            color: AppTheme.successColor,
                          ),
                          _buildSummaryChip(
                            icon: Icons.arrow_upward,
                            label: '$outgoingCount sent',
                            color: AppTheme.errorColor,
                          ),
                          if (donationCount > 0)
                            _buildSummaryChip(
                              icon: Icons.volunteer_activism,
                              label: '$donationCount donation',
                              color: AppTheme.accentColor,
                            ),
                          _buildSummaryChip(
                            icon: Icons.public,
                            label: state.isTestnet ? 'Testnet' : 'Mainnet',
                            color: state.isTestnet
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ...transactions.map(
                  (transaction) => TransactionTile(
                    transaction: transaction,
                    isTestnet: state.isTestnet,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: AppTheme.darkBackground,
    );
  }

  Widget _buildSummaryChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
