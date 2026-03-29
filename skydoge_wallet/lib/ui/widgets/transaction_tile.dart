import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.direction == TransactionDirection.incoming;
    final isDonation = transaction.isDonation;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDonation
                ? AppTheme.accentColor.withOpacity(0.1)
                : (isIncoming
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDonation
                ? Icons.volunteer_activism
                : (isIncoming ? Icons.arrow_downward : Icons.arrow_upward),
            color: isDonation
                ? AppTheme.accentColor
                : (isIncoming ? AppTheme.successColor : AppTheme.errorColor),
          ),
        ),
        title: Text(
          isDonation
              ? 'Donation'
              : (isIncoming ? 'Received' : 'Sent'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Formatters.relativeTime(transaction.timestamp),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            if (isDonation)
              const Text(
                'Skydoge Development Fund',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncoming ? '+' : '-'}${Formatters.formatSatoshis(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDonation
                    ? AppTheme.accentColor
                    : (isIncoming ? AppTheme.successColor : AppTheme.errorColor),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (transaction.isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  )
                else
                  Text(
                    '${transaction.confirmations} confirmations',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          _showTransactionDetails(context);
        },
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Transaction ID', Formatters.formatTxid(transaction.txid, visibleChars: 16)),
            _buildDetailRow('Direction', transaction.direction.name),
            _buildDetailRow('Amount', Formatters.formatSatoshis(transaction.amount)),
            _buildDetailRow('Fee', Formatters.formatSatoshis(transaction.fee)),
            _buildDetailRow('Confirmations', transaction.confirmations.toString()),
            _buildDetailRow('Date', Formatters.formatDateTime(transaction.timestamp)),
            if (transaction.isDonation) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.volunteer_activism, color: AppTheme.accentColor),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(
                          'This transaction includes a mandatory 0.01% donation to support Skydoge development',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement block explorer lookup
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('View on Block Explorer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400]),
          ),
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
