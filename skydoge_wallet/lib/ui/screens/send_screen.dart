import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../core/constants/network_constants.dart';
import '../../core/constants/donation_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  String _feeLevel = 'medium';
  String? _error;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _buildTransaction() {
    final address = _addressController.text.trim();
    final amountText = _amountController.text.trim();
    final walletState = context.read<WalletBloc>().state;

    if (walletState is! WalletLoaded) return;
    if (address.isEmpty) {
      setState(() => _error = 'Please enter a recipient address');
      return;
    }

    final chain = NetworkConstants.chainFor(walletState.isTestnet);
    if (!Validators.isValidSkydogeAddress(address, chain: chain)) {
      setState(() => _error = 'Invalid Skydoge address');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Invalid amount');
      return;
    }

    final sendAmount = (amount * 100000000).round();
    final feeRate = TransactionConstants.getFeeRate(_feeLevel);

    context.read<TransactionBloc>().add(
          BuildTransactionEvent(
            toAddress: address,
            sendAmount: sendAmount,
            feeRate: feeRate,
            fromAddress: walletState.wallet.receivingAddress,
            privateKey: walletState.wallet.privateKey,
            isTestnet: walletState.isTestnet,
          ),
        );
  }

  void _showConfirmationDialog(BuildContext context, TransactionBuilt state) {
    final preview = state.preview;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Network', preview.network),
            const SizedBox(height: 8),
            _buildDetailRow('To', Formatters.formatAddress(preview.toAddress)),
            const SizedBox(height: 8),
            _buildDetailRow('Send amount', Formatters.formatSatoshis(preview.sendAmount)),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Donation (0.01%)',
              Formatters.formatSatoshis(preview.donationAmount),
              valueColor: AppTheme.accentColor,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Donation address',
              Formatters.formatAddress(preview.donationAddress),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Fee', Formatters.formatSatoshis(preview.fee)),
            const SizedBox(height: 8),
            _buildDetailRow('Change', Formatters.formatSatoshis(preview.changeAmount)),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Total cost',
              Formatters.formatSatoshis(preview.totalCost),
              valueColor: AppTheme.primaryColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TransactionBloc>().add(const SignTransactionEvent());
            },
            child: const Text('Confirm & Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(color: valueColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;
    final sendAmount = (enteredAmount * 100000000).round();
    final donation = DonationConstants.calculateDonationFee(sendAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('Send SKYDOGE')),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionBuilt) {
            _showConfirmationDialog(context, state);
          } else if (state is TransactionBroadcasted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transaction sent! TXID: ${Formatters.formatTxid(state.txid)}'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pop(context);
          } else if (state is TransactionError) {
            setState(() => _error = state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Recipient Address',
                    hintText: 'Enter Skydoge address',
                    prefixIcon: const Icon(Icons.person),
                    errorText: _error?.contains('address') == true ? _error : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.0',
                    prefixIcon: const Icon(Icons.monetization_on),
                    suffixText: 'SKYDOGE',
                    errorText: _error?.contains('amount') == true ? _error : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transaction Fee',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'low', label: Text('Low')),
                    ButtonSegment(value: 'medium', label: Text('Medium')),
                    ButtonSegment(value: 'high', label: Text('High')),
                  ],
                  selected: {_feeLevel},
                  onSelectionChanged: (value) {
                    setState(() => _feeLevel = value.first);
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mandatory donation',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Every transfer includes a 0.01% donation to ${Formatters.formatAddress(DonationConstants.donationAddress)}.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Donation amount'),
                            Text(
                              Formatters.formatSatoshis(donation),
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (DonationConstants.requiresMinimumDonation(sendAmount)) ...[
                          const SizedBox(height: 8),
                          const Text(
                            '当前金额过低，无法满足最小捐赠输出要求',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_error != null && _error!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                if (state is TransactionBuilding ||
                    state is TransactionSigning ||
                    state is TransactionBroadcasting)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _buildTransaction,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Continue'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
