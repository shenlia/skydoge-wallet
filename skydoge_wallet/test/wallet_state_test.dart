import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/blocs/wallet/wallet_state.dart';
import 'package:skydoge_wallet/data/models/transaction.dart';
import 'package:skydoge_wallet/data/models/wallet.dart';

void main() {
  const wallet = Wallet(
    id: 'wallet-1',
    name: 'Skydoge Wallet',
    type: 'mnemonic',
    mnemonic: 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    seed: 'seed',
    privateKey: 'priv',
    publicKey: 'pub',
    receivingAddress: '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc',
    network: 0,
    createdAt: DateTime.utc(2026, 3, 30),
  );

  const balance = WalletBalance(
    confirmed: 100,
    unconfirmed: 20,
    immature: 0,
    sidechain: 0,
  );

  final tx = Transaction(
    txid: 'tx-1',
    hash: 'tx-1',
    version: 1,
    locktime: 0,
    inputs: const [],
    outputs: const [],
    fee: 1,
    size: 100,
    confirmations: 1,
    timestamp: DateTime.utc(2026, 3, 30),
  );

  test('WalletLoaded copyWith preserves loaded data while adding warning', () {
    final state = WalletLoaded(
      wallet: wallet,
      balance: balance,
      transactions: [tx],
      isTestnet: false,
    );

    final updated = state.copyWith(warningMessage: 'Refresh failed');

    expect(updated.wallet, wallet);
    expect(updated.balance, balance);
    expect(updated.transactions, [tx]);
    expect(updated.warningMessage, 'Refresh failed');
  });

  test('WalletLoaded copyWith can clear warning message', () {
    final state = WalletLoaded(
      wallet: wallet,
      balance: balance,
      transactions: [tx],
      isTestnet: false,
      warningMessage: 'Refresh failed',
    );

    final updated = state.copyWith(clearWarningMessage: true);

    expect(updated.warningMessage, isNull);
    expect(updated.wallet, wallet);
    expect(updated.balance, balance);
    expect(updated.transactions, [tx]);
  });
}
