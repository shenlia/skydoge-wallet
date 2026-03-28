import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';

import '../core/chain/chain_config.dart';

class AddressService {
  static const _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  Future<String> generateMnemonic() async {
    return bip39.generateMnemonic();
  }

  Future<WalletData> deriveWallet(
    String mnemonic, {
    required ChainConfig chain,
  }) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw AddressException('Invalid mnemonic phrase');
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath(chain.derivationPath);

    final privateKey = child.privateKey;
    if (privateKey == null) {
      throw AddressException('Unable to derive private key');
    }

    final publicKey = child.publicKey;
    final address = _deriveAddress(publicKey, chain: chain);
    final wif = _encodeWif(privateKey, chain: chain, compressed: true);

    return WalletData(
      mnemonic: mnemonic,
      seed: HEX.encode(seed),
      privateKey: HEX.encode(privateKey),
      publicKey: HEX.encode(publicKey),
      receivingAddress: address,
      network: chain.isTestnet ? 1 : 0,
      wif: wif,
      walletType: 'mnemonic',
      derivationPath: chain.derivationPath,
    );
  }

  Future<WalletData> importFromWif(
    String wif, {
    required ChainConfig chain,
  }) async {
    final decoded = _base58Decode(wif);
    if (decoded.length != 37 && decoded.length != 38) {
      throw AddressException('Invalid WIF length');
    }

    final payload = decoded.sublist(0, decoded.length - 4);
    final checksum = decoded.sublist(decoded.length - 4);
    final expectedChecksum = _doubleSha256(payload).sublist(0, 4);
    if (!_listEquals(checksum, expectedChecksum)) {
      throw AddressException('Invalid WIF checksum');
    }

    if (payload.first != chain.wifPrefix) {
      throw AddressException('WIF prefix does not match selected network');
    }

    final compressed = payload.length == 34 && payload.last == 0x01;
    final privateKey = compressed ? payload.sublist(1, 33) : payload.sublist(1);
    if (privateKey.length != 32) {
      throw AddressException('Invalid WIF private key');
    }

    final publicKey = _publicKeyFromPrivateKey(privateKey, compressed: compressed);
    final address = _deriveAddress(publicKey, chain: chain);

    return WalletData(
      mnemonic: '',
      seed: '',
      privateKey: HEX.encode(privateKey),
      publicKey: HEX.encode(publicKey),
      receivingAddress: address,
      network: chain.isTestnet ? 1 : 0,
      wif: wif,
      walletType: 'wif',
      derivationPath: '',
    );
  }

  bool validateAddress(String address, {required ChainConfig chain}) {
    if (address.isEmpty) return false;

    if (address.startsWith(chain.bech32Hrp)) {
      return _validateBech32Address(address, chain: chain);
    }

    return _validateLegacyAddress(address, chain: chain);
  }

  String getAddressFromPrivateKey(
    String privateKeyHex, {
    required ChainConfig chain,
    bool compressed = true,
  }) {
    final privateKeyBytes = HEX.decode(privateKeyHex);
    final publicKey =
        _publicKeyFromPrivateKey(privateKeyBytes, compressed: compressed);
    return _deriveAddress(publicKey, chain: chain);
  }

  String _deriveAddress(Uint8List publicKey, {required ChainConfig chain}) {
    final sha256Hash = _sha256(publicKey);
    final ripeHash160 = _ripemd160(sha256Hash);
    return _encodeP2PKH(ripeHash160, version: chain.pubKeyHashPrefix);
  }

  String _encodeP2PKH(Uint8List hash160, {required int version}) {
    final payload = Uint8List.fromList([version, ...hash160]);
    final checksum = _doubleSha256(payload).sublist(0, 4);
    return _base58Encode(Uint8List.fromList([...payload, ...checksum]));
  }

  String _encodeWif(
    Uint8List privateKey, {
    required ChainConfig chain,
    required bool compressed,
  }) {
    final payload = <int>[chain.wifPrefix, ...privateKey];
    if (compressed) {
      payload.add(0x01);
    }
    final checksum = _doubleSha256(Uint8List.fromList(payload)).sublist(0, 4);
    return _base58Encode(Uint8List.fromList([...payload, ...checksum]));
  }

  Uint8List _publicKeyFromPrivateKey(
    List<int> privateKeyBytes, {
    required bool compressed,
  }) {
    final domain = ECCurve_secp256k1();
    final point = domain.G * BigInt.parse(HEX.encode(privateKeyBytes), radix: 16);
    return Uint8List.fromList(point!.getEncoded(compressed));
  }

  bool _validateLegacyAddress(String address, {required ChainConfig chain}) {
    if (address.length < 26 || address.length > 35) {
      return false;
    }

    final decoded = _base58Decode(address);
    if (decoded.length < 5) {
      return false;
    }

    final payload = decoded.sublist(0, decoded.length - 4);
    final checksum = decoded.sublist(decoded.length - 4);
    final expectedChecksum = _doubleSha256(payload).sublist(0, 4);
    if (!_listEquals(checksum, expectedChecksum)) {
      return false;
    }

    final version = payload.first;
    return version == chain.pubKeyHashPrefix ||
        version == chain.scriptHashPrefix ||
        version == chain.sidechainPubKeyPrefix ||
        version == chain.sidechainScriptPrefix;
  }

  bool _validateBech32Address(String address, {required ChainConfig chain}) {
    final lower = address.toLowerCase();
    return lower.startsWith('${chain.bech32Hrp}1') && lower.length >= 14;
  }

  Uint8List _sha256(Uint8List data) {
    final digest = SHA256Digest();
    return digest.process(data);
  }

  Uint8List _ripemd160(Uint8List data) {
    final digest = RIPEMD160Digest();
    final hash = Uint8List(20);
    digest.update(data, 0, data.length);
    digest.doFinal(hash, 0);
    return hash;
  }

  Uint8List _doubleSha256(Uint8List data) {
    return _sha256(_sha256(data));
  }

  String _base58Encode(Uint8List bytes) {
    var value = BigInt.zero;
    for (final byte in bytes) {
      value = (value << 8) | BigInt.from(byte);
    }

    final buffer = StringBuffer();
    while (value > BigInt.zero) {
      final mod = value.remainder(BigInt.from(58)).toInt();
      value = value ~/ BigInt.from(58);
      buffer.write(_base58Alphabet[mod]);
    }

    for (final byte in bytes) {
      if (byte != 0) break;
      buffer.write('1');
    }

    return buffer.toString().split('').reversed.join();
  }

  Uint8List _base58Decode(String input) {
    var value = BigInt.zero;
    for (final char in input.split('')) {
      final index = _base58Alphabet.indexOf(char);
      if (index == -1) {
        throw AddressException('Invalid Base58 character');
      }
      value = value * BigInt.from(58) + BigInt.from(index);
    }

    final bytes = <int>[];
    while (value > BigInt.zero) {
      bytes.insert(0, (value & BigInt.from(0xff)).toInt());
      value = value >> 8;
    }

    for (final char in input.split('')) {
      if (char != '1') break;
      bytes.insert(0, 0);
    }

    return Uint8List.fromList(bytes);
  }

  bool _listEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

class WalletData {
  final String mnemonic;
  final String seed;
  final String privateKey;
  final String publicKey;
  final String receivingAddress;
  final int network;
  final String wif;
  final String walletType;
  final String derivationPath;

  const WalletData({
    required this.mnemonic,
    required this.seed,
    required this.privateKey,
    required this.publicKey,
    required this.receivingAddress,
    required this.network,
    required this.wif,
    required this.walletType,
    required this.derivationPath,
  });

  Map<String, dynamic> toJson() => {
        'mnemonic': mnemonic,
        'seed': seed,
        'privateKey': privateKey,
        'publicKey': publicKey,
        'receivingAddress': receivingAddress,
        'network': network,
        'wif': wif,
        'walletType': walletType,
        'derivationPath': derivationPath,
      };
}

class AddressException implements Exception {
  final String message;

  AddressException(this.message);

  @override
  String toString() => 'AddressException: $message';
}
