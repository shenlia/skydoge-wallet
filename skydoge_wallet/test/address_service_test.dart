import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/core/utils/formatters.dart';
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

  test('validateAddress accepts testnet legacy and bech32 prefixes', () {
    expect(service.validateAddress('mkHS9ne12qx9pS9VojpwU5xtRd4T7X7ZUt'), true);
    expect(service.validateAddress('n2eMqTT929pb1RDNuqEnxdaLau1rxy3efi'), true);
    expect(service.validateAddress('2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br'), true);
    expect(
      service.validateAddress('tb1qfmz4ax7h2r8w5v4s0p0j5l6w8v9c2s3d4e5f6g'),
      true,
    );
  });

  test('ui validator accepts testnet legacy and bech32 prefixes', () {
    expect(Validators.isValidSkydogeAddress('mkHS9ne12qx9pS9VojpwU5xtRd4T7X7ZUt'), true);
    expect(Validators.isValidSkydogeAddress('2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br'), true);
    expect(
      Validators.isValidSkydogeAddress('tb1qfmz4ax7h2r8w5v4s0p0j5l6w8v9c2s3d4e5f6g'),
      true,
    );
  });

  test('can import wallet from WIF', () async {
    const wif = 'KwDiBf89QgGbjEhKnhXJuH7SUW1x59A5Mta7p4QXQ9VNLYnL8pJb';
    final wallet = await service.importFromWif(wif);
    expect(wallet.privateKey.isNotEmpty, true);
    expect(wallet.receivingAddress.startsWith('1'), true);
  });
}
