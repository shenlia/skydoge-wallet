import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/core/chain/chain_config.dart';
import 'package:skydoge_wallet/services/address_service.dart';

void main() {
  final service = AddressService();
  const mnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  group('AddressService', () {
    test('derives mainnet wallet from mnemonic', () async {
      final wallet = await service.deriveWallet(mnemonic, chain: ChainConfig.mainnet);

      expect(wallet.receivingAddress, isNotEmpty);
      expect(wallet.privateKey.length, 64);
      expect(wallet.walletType, 'mnemonic');
      expect(wallet.wif, isNotEmpty);
    });

    test('imports WIF on selected network', () async {
      final derived = await service.deriveWallet(mnemonic, chain: ChainConfig.mainnet);
      final imported = await service.importFromWif(derived.wif, chain: ChainConfig.mainnet);

      expect(imported.receivingAddress, derived.receivingAddress);
      expect(imported.walletType, 'wif');
    });

    test('validates mainnet address', () async {
      final wallet = await service.deriveWallet(mnemonic, chain: ChainConfig.mainnet);
      expect(
        service.validateAddress(wallet.receivingAddress, chain: ChainConfig.mainnet),
        isTrue,
      );
      expect(
        service.validateAddress(wallet.receivingAddress, chain: ChainConfig.testnet),
        isFalse,
      );
    });
  });
}
