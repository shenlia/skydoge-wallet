import 'dart:math';
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:pointycastle/export.dart';
import 'package:hex/hex.dart';
import '../core/constants/network_constants.dart';

class AddressService {
  final ChainConfig _chainConfig;

  AddressService({ChainConfig? chainConfig}) 
      : _chainConfig = chainConfig ?? ChainConfig.mainnet;

  Future<String> generateMnemonic() async {
    return bip39.generateMnemonic();
  }

  Future<WalletData> deriveWallet(String mnemonic, {bool isTestnet = false}) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);

    final child = root.derivePath(WalletConstants.hdWalletPath);
    final privateKey = child.privateKey!;
    final publicKey = child.publicKey;

    final chainCfg = isTestnet ? ChainConfig.testnet : ChainConfig.mainnet;
    final address = _deriveAddress(publicKey, chainConfig: chainCfg);

    return WalletData(
      mnemonic: mnemonic,
      seed: HEX.encode(seed),
      privateKey: HEX.encode(privateKey),
      publicKey: HEX.encode(publicKey),
      receivingAddress: address,
      network: isTestnet ? 1 : 0,
    );
  }

  WalletData importFromWif(String wif, {bool isTestnet = false}) {
    final privateKeyBytes = _decodeWif(wif, isTestnet: isTestnet);
    final publicKey = _publicKeyFromPrivateKey(privateKeyBytes);
    final chainCfg = isTestnet ? ChainConfig.testnet : ChainConfig.mainnet;
    final address = _deriveAddress(publicKey, chainConfig: chainCfg);

    return WalletData(
      mnemonic: '',
      seed: '',
      privateKey: HEX.encode(privateKeyBytes),
      publicKey: HEX.encode(publicKey),
      receivingAddress: address,
      network: isTestnet ? 1 : 0,
      walletType: 'wif',
    );
  }

  List<int> _decodeWif(String wif, {required bool isTestnet}) {
    final decoded = base58Decode(wif);
    if (decoded.length < 4) {
      throw Exception('Invalid WIF format');
    }

    final withoutChecksum = decoded.sublist(0, decoded.length - 4);
    final checksum = decoded.sublist(decoded.length - 4);
    final calculatedChecksum = _doubleSha256(withoutChecksum).sublist(0, 4);

    if (!_listEquals(checksum, calculatedChecksum)) {
      throw Exception('Invalid WIF checksum');
    }

    final expectedVersion = isTestnet ? 0xEF : 0x80;
    if (withoutChecksum[0] != expectedVersion) {
      throw Exception('Invalid WIF version byte');
    }

    List<int> privateKeyBytes;
    if (withoutChecksum.length == 34) {
      privateKeyBytes = withoutChecksum.sublist(1, 33);
    } else if (withoutChecksum.length == 33) {
      privateKeyBytes = withoutChecksum.sublist(1);
    } else {
      throw Exception('Invalid WIF length');
    }

    return privateKeyBytes;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _deriveAddress(Uint8List publicKey, {required ChainConfig chainConfig}) {
    final sha256Hash = _sha256(publicKey);
    final ripeHash160 = _ripemd160(sha256Hash);

    return _encodeP2PKH(ripeHash160, version: chainConfig.pubKeyHashPrefix);
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
    return '1' * prefixZeros + result.reversed.map((i) => alphabet[i]).join();
  }

  List<int> base58Decode(String input) {
    const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final result = <int>[];
    int leadingOnes = 0;

    for (int i = 0; i < input.length; i++) {
      if (input[i] != '1') break;
      leadingOnes++;
    }

    for (int i = 0; i < input.length; i++) {
      int carry = 0;
      for (int j = i; j < input.length; j++) {
        final digitValue = alphabet.indexOf(input[j]);
        if (digitValue == -1) throw Exception('Invalid character: ${input[j]}');
        carry = carry * 58 + digitValue;
      }
      result.add(carry ~/ 256);
      carry = carry % 256;
    }

    return [List.filled(leadingOnes, 0), ...result].expand((x) => x).toList();
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
    final publicKey = _publicKeyFromPrivateKey(privateKeyBytes);
    final chainCfg = isTestnet ? ChainConfig.testnet : ChainConfig.mainnet;
    return _deriveAddress(publicKey, chainConfig: chainCfg);
  }

  Uint8List _publicKeyFromPrivateKey(List<int> privateKeyBytes) {
    final domain = ECCurve_secp256k1();
    final point = domain.G * BigInt.parse(HEX.encode(privateKeyBytes), radix: 16);
    return Uint8List.fromList(point!.getEncoded(false));
  }

  bool isValidWif(String wif) {
    try {
      _decodeWif(wif, isTestnet: false);
      return true;
    } catch (_) {
      try {
        _decodeWif(wif, isTestnet: true);
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}

class WalletData {
  final String mnemonic;
  final String seed;
  final String privateKey;
  final String publicKey;
  final String receivingAddress;
  final int network;
  final String walletType;

  const WalletData({
    required this.mnemonic,
    required this.seed,
    required this.privateKey,
    required this.publicKey,
    required this.receivingAddress,
    required this.network,
    this.walletType = 'mnemonic',
  });

  Map<String, dynamic> toJson() => {
    'mnemonic': mnemonic,
    'seed': seed,
    'privateKey': privateKey,
    'publicKey': publicKey,
    'receivingAddress': receivingAddress,
    'network': network,
    'walletType': walletType,
  };

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      mnemonic: json['mnemonic'] as String? ?? '',
      seed: json['seed'] as String? ?? '',
      privateKey: json['privateKey'] as String,
      publicKey: json['publicKey'] as String,
      receivingAddress: json['receivingAddress'] as String,
      network: json['network'] as int,
      walletType: json['walletType'] as String? ?? 'mnemonic',
    );
  }
}
