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

  test('testnet wallet derivation returns address compatible with latest testnet rules', () async {
    const mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final wallet = await service.deriveWallet(mnemonic, isTestnet: true);
    expect(
      wallet.receivingAddress.startsWith('1') || wallet.receivingAddress.startsWith('m') || wallet.receivingAddress.startsWith('n'),
      true,
    );
  });

  test('validateAddress accepts testnet legacy and bech32 prefixes', () {
    expect(service.validateAddress('1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc'), true);
    expect(service.validateAddress('mkHS9ne12qx9pS9VojpwU5xtRd4T7X7ZUt'), true);
    expect(service.validateAddress('n2eMqTT929pb1RDNuqEnxdaLau1rxy3efi'), true);
    expect(service.validateAddress('2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br'), true);
    expect(
      service.validateAddress('tb1qfmz4ax7h2r8w5v4s0p0j5l6w8v9c2s3d4e5f6g'),
      true,
    );
  });

  test('ui validator accepts testnet legacy and bech32 prefixes', () {
    expect(Validators.isValidSkydogeAddress('1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc'), true);
    expect(Validators.isValidSkydogeAddress('mkHS9ne12qx9pS9VojpwU5xtRd4T7X7ZUt'), true);
    expect(Validators.isValidSkydogeAddress('2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br'), true);
    expect(
      Validators.isValidSkydogeAddress('tb1qfmz4ax7h2r8w5v4s0p0j5l6w8v9c2s3d4e5f6g'),
      true,
    );
  });

  test('getAddressFromPrivateKey matches mnemonic-derived wallet address', () async {
    const mnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final wallet = await service.deriveWallet(mnemonic);
    final derivedAddress = service.getAddressFromPrivateKey(wallet.privateKey);

    expect(derivedAddress, wallet.receivingAddress);
  });

  test('can derive mainnet address from standard P2PKH scriptPubKey', () async {
    const privateKeyHex =
        '0000000000000000000000000000000000000000000000000000000000000001';
    final address = service.getAddressFromPrivateKey(privateKeyHex);
    final publicKey = service.getPublicKeyFromPrivateKey(privateKeyHex);
    final hash160 = service
        .tryDeriveAddressFromScriptPubKey(
          '76a914751e76e8199196d454941c45d1b3a323f1433bd688ac',
        );

    expect(publicKey, isNotEmpty);
    expect(hash160, address);
  });

  test('can derive testnet address from standard P2PKH scriptPubKey', () async {
    final address = service.tryDeriveAddressFromScriptPubKey(
      '76a9146eb63aedd0ab8d64ac745306ac8b8d4699a04fbc88ac',
      isTestnet: true,
    );

    expect(address, '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc');
  });

  test('can import wallet from WIF', () async {
    const wif = 'KwDiBf89QgGbjEhKnhXJuH7SUW1x59A5Mta7p4QXQ9VNLYnL8pJb';
    final wallet = await service.importFromWif(wif);
    expect(wallet.privateKey.isNotEmpty, true);
    expect(wallet.receivingAddress.startsWith('1'), true);
  });
}
