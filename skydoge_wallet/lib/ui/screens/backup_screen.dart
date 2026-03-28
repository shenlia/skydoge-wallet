import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/wallet.dart';

class BackupScreen extends StatefulWidget {
  final Wallet wallet;
  final String mnemonic;

  const BackupScreen({
    super.key,
    required this.wallet,
    required this.mnemonic,
  });

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _hasConfirmedBackup = false;
  bool _showMnemonic = false;

  void _proceed() {
    if (!_hasConfirmedBackup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that you have backed up your mnemonic phrase'),
        ),
      );
      return;
    }

    context.read<WalletBloc>().add(const CheckWalletExistsEvent());
  }

  void _copyMnemonic() {
    Clipboard.setData(ClipboardData(text: widget.mnemonic));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mnemonic copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Wallet'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: AppTheme.warningColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Important: Save Your Mnemonic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Write down these 12 words in order and store them safely. This is the only way to recover your wallet if you lose access to your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Mnemonic Phrase',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _showMnemonic = !_showMnemonic),
                          icon: Icon(
                            _showMnemonic ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_showMnemonic)
                      _buildMnemonicGrid()
                    else
                      _buildHiddenMnemonic(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _copyMnemonic,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy to Clipboard'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                value: _hasConfirmedBackup,
                onChanged: (value) => setState(() => _hasConfirmedBackup = value ?? false),
                title: const Text(
                  'I have written down my mnemonic phrase and understand it is my only recovery method',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _proceed,
                child: const Text('I Understand, Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMnemonicGrid() {
    final words = widget.mnemonic.split(' ');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(12, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${index + 1}. ${words[index]}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHiddenMnemonic() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Tap the eye icon to reveal',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
