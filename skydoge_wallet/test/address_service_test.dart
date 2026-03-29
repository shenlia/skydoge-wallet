import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/services/address_service.dart';

void main() {
  final service = AddressService();

  test('mnemonic generation returns 12 words', () async {
    final mnemonic = await service.generateMnemonic();
    expect(mnemonic.split(' ').length, 12);
  });

  test('mainnet wallet derivation returns legacy address', () async {
    const mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final wallet = await service.deriveWallet(mnemonic);
    expect(wallet.receivingAddress.startsWith('1'), true);
  });

  test('testnet wallet derivation returns testnet address', () async {
    const mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final wallet = await service.deriveWallet(mnemonic, isTestnet: true);
    expect(wallet.receivingAddress.startsWith('m') || wallet.receivingAddress.startsWith('n'), true);
  });

  test('can import wallet from WIF', () async {
    const wif = 'KwDiBf89QgGbjEhKnhXJuH7SUW1x59A5Mta7p4QXQ9VNLYnL8pJb';
    final wallet = await service.importFromWif(wif);
    expect(wallet.privateKey.isNotEmpty, true);
    expect(wallet.receivingAddress.startsWith('1'), true);
  });
}
