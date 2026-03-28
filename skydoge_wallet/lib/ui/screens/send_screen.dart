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
import '../../generated/l10n.dart';

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
    final s = S.of(context);
    final address = _addressController.text.trim();
    final amountText = _amountController.text.trim();

    if (address.isEmpty) {
      setState(() => _error = s.pleaseEnterValidAddress);
      return;
    }

    if (!Validators.isValidSkydogeAddress(address)) {
      setState(() => _error = s.invalidAddress);
      return;
    }

    if (amountText.isEmpty) {
      setState(() => _error = s.pleaseEnterValidAmount);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _error = s.invalidAddress);
      return;
    }

    final amountSatoshis = (amount * 100000000).round();

    if (DonationConstants.isDonationBelowDust(amountSatoshis)) {
      setState(() => _error = DonationConstants.getDonationBelowDustWarning());
      return;
    }

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
    final s = S.of(context);
    final donationFee = state.donationFee;
    final totalAmount = state.amount;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.confirmTransaction),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(s.recipientAddress, Formatters.formatAddress(state.toAddress)),
            const SizedBox(height: 8),
            _buildDetailRow(s.amount, Formatters.formatSatoshis(totalAmount)),
            if (donationFee > 0) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                s.donationFee,
                '${Formatters.formatSatoshis(donationFee)} (0.01%)',
                valueColor: AppTheme.accentColor,
              ),
            ],
            const SizedBox(height: 8),
            _buildDetailRow(
              s.fee,
              Formatters.formatSatoshis(state.transaction.fee),
            ),
            const Divider(),
            _buildDetailRow(
              s.total,
              Formatters.formatSatoshis(totalAmount + donationFee + state.transaction.fee),
              valueColor: AppTheme.primaryColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TransactionBloc>().add(const SignTransactionEvent());
            },
            child: Text(s.confirmSend),
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
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.sendSkydoge),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionBuilt) {
            _showConfirmationDialog(context, state);
          } else if (state is TransactionBroadcasted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${s.transactionSent}\nTXID: ${Formatters.formatTxid(state.txid)}'),
                backgroundColor: AppTheme.successColor,
                duration: const Duration(seconds: 5),
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
                    labelText: s.recipientAddress,
                    hintText: s.enterRecipientAddress,
                    prefixIcon: const Icon(Icons.person),
                    errorText: _error?.contains('address') == true || _error?.contains('Invalid') == true ? _error : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: s.amount,
                    hintText: '0.0',
                    prefixIcon: const Icon(Icons.monetization_on),
                    suffixText: 'SKYDOGE',
                    errorText: _error?.contains('amount') == true || _error?.contains('below') == true ? _error : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Text(
                  s.transactionFee,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'low', label: Text(s.lowFee)),
                    ButtonSegment(value: 'medium', label: Text(s.mediumFee)),
                    ButtonSegment(value: 'high', label: Text(s.highFee)),
                  ],
                  selected: {_feeLevel},
                  onSelectionChanged: (value) {
                    setState(() => _feeLevel = value.first);
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.volunteer_activism, color: AppTheme.accentColor),
                            const SizedBox(width: 8),
                            Text(
                              s.includeDonation,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${s.donationDesc}\n${s.donationAmount} 0.01%\n${Formatters.formatAddress(DonationConstants.donationAddress)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_amountController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Builder(builder: (context) {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    final donation = DonationConstants.calculateDonationFee((amount * 100000000).round());
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${s.donationAmount} (0.01%):'),
                          Text(
                            Formatters.formatSatoshis(donation),
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 32),
                if (state is TransactionBuilding || state is TransactionSigning || state is TransactionBroadcasting)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _buildTransaction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(s.continueBtn),
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
