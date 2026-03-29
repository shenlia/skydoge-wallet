import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction.dart';
import '../screens/transaction_detail_screen.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
      ),
    );
  }
}
