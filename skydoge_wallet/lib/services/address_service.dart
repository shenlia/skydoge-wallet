import 'dart:math';
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:pointycastle/export.dart';
import 'package:hex/hex.dart';

class AddressService {
  Future<String> generateMnemonic() async {
    return bip39.generateMnemonic();
  }

  Future<WalletData> deriveWallet(String mnemonic, {bool isTestnet = false}) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);

    final child = root.derivePath("m/44'/0'/0'/0/0");
    final privateKey = child.privateKey!;
    final publicKey = child.publicKey;

    final address = _deriveAddress(publicKey, isTestnet: isTestnet);

    return WalletData(
      mnemonic: mnemonic,
      seed: HEX.encode(seed),
      privateKey: HEX.encode(privateKey),
      publicKey: HEX.encode(publicKey),
      receivingAddress: address,
      network: isTestnet ? 1 : 0,
    );
  }

  String _deriveAddress(Uint8List publicKey, {bool isTestnet = false}) {
    final sha256Hash = _sha256(publicKey);
    final ripeHash160 = _ripemd160(sha256Hash);

    if (isTestnet) {
      return _encodeP2PKH(ripeHash160, version: 0x6F);
    } else {
      return _encodeP2PKH(ripeHash160, version: 0x00);
    }
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

  String _encodeP2PKH(Uint8List hash160, {required int version}) {
    final versionBytes = Uint8List.fromList([version]);
    final payload = Uint8List.fromList([...versionBytes, ...hash160]);
    final checksum = _doubleSha256(payload).sublist(0, 4);
    final addressBytes = Uint8List.fromList([...payload, ...checksum]);
    return _base58Encode(addressBytes);
  }

  Uint8List _doubleSha256(Uint8List data) {
    final first = _sha256(data);
    return _sha256(first);
  }

  String _base58Encode(Uint8List data) {
    const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final digits = <int>[];
    for (var byte in data) {
      digits.add(byte);
    }

    final result = <int>[];
    while (digits.isNotEmpty) {
      var carry = 0;
      for (var i = 0; i < digits.length; i++) {
        carry = carry * 256 + digits[i];
        digits[i] = carry ~/ 58;
        carry = carry % 58;
      }
      while (carry > 0) {
        result.add(carry % 58);
        carry = carry ~/ 58;
      }
      while (digits.isNotEmpty && digits[0] == 0) {
        result.add(0);
        digits.removeAt(0);
      }
    }

    for (var i = result.length - 1; i >= 0; i--) {
      if (result[i] != 0) break;
      result.removeLast();
    }

    final prefixZeros = data.takeWhile((b) => b == 0).length;
    final encoded = '1' * prefixZeros + result.reversed.map((i) => alphabet[i]).join();
    return encoded;
  }

  bool validateAddress(String address) {
    if (address.isEmpty) return false;

    if (address.startsWith('1') || address.startsWith('3')) {
      return _validateLegacyAddress(address);
    }

    if (address.startsWith('bc1')) {
      return _validateBech32Address(address);
    }

    if (address.startsWith('S') && !address.startsWith('Sfee')) {
      return _validateLegacyAddress(address);
    }

    return false;
  }

  bool _validateLegacyAddress(String address) {
    if (address.length < 26 || address.length > 35) return false;
    const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    return address.split('').every((c) => alphabet.contains(c));
  }

  bool _validateBech32Address(String address) {
    if (address.length < 42 || address.length > 62) return false;
    if (!address.startsWith('bc1')) return false;
    const bech32Charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
    return address.substring(3).split('').every((c) => bech32Charset.contains(c.toLowerCase()));
  }

  String getAddressFromPrivateKey(String privateKeyHex, {bool isTestnet = false}) {
    final privateKeyBytes = HEX.decode(privateKeyHex);
    final ecPoint = _publicKeyFromPrivateKey(privateKeyBytes);
    return _deriveAddress(ecPoint, isTestnet: isTestnet);
  }

  Uint8List _publicKeyFromPrivateKey(List<int> privateKeyBytes) {
    final domain = ECCurve_secp256k1();
    final point = domain.G * BigInt.parse(HEX.encode(privateKeyBytes), radix: 16);
    return Uint8List.fromList(point!.getEncoded(false));
  }
}

class WalletData {
  final String mnemonic;
  final String seed;
  final String privateKey;
  final String publicKey;
  final String receivingAddress;
  final int network;

  const WalletData({
    required this.mnemonic,
    required this.seed,
    required this.privateKey,
    required this.publicKey,
    required this.receivingAddress,
    required this.network,
  });

  Map<String, dynamic> toJson() => {
    'mnemonic': mnemonic,
    'seed': seed,
    'privateKey': privateKey,
    'publicKey': publicKey,
    'receivingAddress': receivingAddress,
    'network': network,
  };
}
