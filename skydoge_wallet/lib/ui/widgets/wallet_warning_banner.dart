import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class WalletWarningBanner extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;

  const WalletWarningBanner({
    super.key,
    required this.message,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.warningColor),
            ),
          ),
        ],
      ),
    );
  }
}
