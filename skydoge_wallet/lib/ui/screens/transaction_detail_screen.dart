import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction.dart';
import '../../services/explorer_api_service.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;
  final bool isTestnet;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.isTestnet = false,
  });

  @override
  Widget build(BuildContext context) {
    final explorerBaseUrl = _explorerBaseUrl(transaction);
    final explorerTxUrl = '$explorerBaseUrl/tx/${transaction.txid}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Detail'),
      ),
      backgroundColor: AppTheme.darkBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Transaction ID',
                    Formatters.formatTxid(transaction.txid, visibleChars: 16),
                  ),
                  _buildDetailRow('Direction', transaction.direction.name),
                  _buildDetailRow('Amount', Formatters.formatSatoshis(transaction.amount)),
                  _buildDetailRow('Fee', Formatters.formatSatoshis(transaction.fee)),
                  _buildDetailRow(
                    'Confirmations',
                    transaction.confirmations.toString(),
                  ),
                  _buildDetailRow('Network', isTestnet ? 'testnet' : 'mainnet'),
                  _buildDetailRow(
                    'Date',
                    Formatters.formatDateTime(transaction.timestamp),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outputs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (transaction.outputs.isEmpty)
                    const Text('No outputs available', style: TextStyle(color: Colors.grey))
                  else
                    ...transaction.outputs.map(
                      (output) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: output.isDonation
                                ? AppTheme.accentColor.withOpacity(0.12)
                                : Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: output.isDonation
                                  ? AppTheme.accentColor.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                output.isDonation ? 'Donation Output' : 'Output #${output.index}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: output.isDonation ? AppTheme.accentColor : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(Formatters.formatAddress(output.address, visibleChars: 12)),
                              const SizedBox(height: 6),
                              Text(Formatters.formatSatoshis(output.amount)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (transaction.isDonation) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.volunteer_activism, color: AppTheme.accentColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This transaction contains the mandatory 0.01% Skydoge donation output.',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    explorerTxUrl,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyToClipboard(
                            context,
                            value: transaction.txid,
                            message: 'Transaction ID copied to clipboard',
                          ),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy TxID'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyToClipboard(
                            context,
                            value: explorerTxUrl,
                            message: 'Explorer link copied to clipboard',
                          ),
                          icon: const Icon(Icons.link),
                          label: const Text('Copy Explorer Link'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Block Explorer: $explorerTxUrl'),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('View on Block Explorer'),
          ),
        ],
      ),
    );
  }

  String _explorerBaseUrl(Transaction transaction) {
    if (isTestnet) {
      return ExplorerApiService.testnet().baseUrl;
    }

    final hasTestnetPrefix = transaction.outputs.any(
      (output) =>
          output.address.startsWith('m') ||
          output.address.startsWith('n') ||
          output.address.startsWith('2') ||
          output.address.startsWith('tb1'),
    );
    return hasTestnetPrefix
        ? ExplorerApiService.testnet().baseUrl
        : ExplorerApiService.mainnet().baseUrl;
  }

  void _copyToClipboard(
    BuildContext context, {
    required String value,
    required String message,
  }) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
