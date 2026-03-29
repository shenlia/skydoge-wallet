import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/donation_constants.dart';
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

    if (address.isEmpty) {
      setState(() => _error = 'Please enter a recipient address');
      return;
    }

    if (!Validators.isValidSkydogeAddress(address)) {
      setState(() => _error = 'Invalid Skydoge address');
      return;
    }

    if (amountText.isEmpty) {
      setState(() => _error = 'Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Invalid amount');
      return;
    }

    final amountSatoshis = (amount * 100000000).round();

    final walletState = context.read<WalletBloc>().state;
    if (walletState is! WalletLoaded) return;

    final feeRate = TransactionConstants.getFeeRate(_feeLevel);

    context.read<TransactionBloc>().add(BuildTransactionEvent(
      toAddress: address,
      amount: amountSatoshis,
      feeRate: feeRate,
      fromAddress: walletState.wallet.receivingAddress,
      privateKey: walletState.wallet.privateKey,
    ));
  }

  void _showConfirmationDialog(BuildContext context, TransactionBuilt state) {
    final preview = state.preview;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('To:', Formatters.formatAddress(preview.toAddress)),
            const SizedBox(height: 8),
            _buildDetailRow('Amount:', Formatters.formatSatoshis(preview.sendAmount)),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Donation (0.01%):',
              Formatters.formatSatoshis(preview.donationAmount),
              valueColor: AppTheme.accentColor,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Donation Address:',
              Formatters.formatAddress(preview.donationAddress, visibleChars: 10),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Fee:',
              Formatters.formatSatoshis(preview.fee),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Total Cost:',
              Formatters.formatSatoshis(preview.totalCost),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Network:',
              preview.network,
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: valueColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send SKYDOGE'),
      ),
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
                    hintText: 'Enter Skydoge address or scan QR',
                    prefixIcon: const Icon(Icons.person),
                    errorText: _error?.contains('address') == true ? _error : null,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () {
                        // TODO: Implement QR scanning
                      },
                    ),
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
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount != null) {
                        setState(() {});
                      }
                    }
                  },
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
                  child: ListTile(
                    title: const Text('Mandatory 0.01% Donation'),
                    subtitle: Text(
                      'Every transfer includes an on-chain donation output\nDonation address: ${Formatters.formatAddress(DonationConstants.donationAddress)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),
                ),
                if (_amountController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Donation Amount:'),
                        Builder(builder: (context) {
                          final amount = double.tryParse(_amountController.text) ?? 0;
                          final donation = DonationConstants.calculateDonationFee((amount * 100000000).round());
                          return Text(
                            Formatters.formatSatoshis(donation),
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (state is TransactionBuilding || state is TransactionSigning || state is TransactionBroadcasting)
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
