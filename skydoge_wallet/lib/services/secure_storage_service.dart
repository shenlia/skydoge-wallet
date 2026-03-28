import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  static const String _mnemonicKey = 'skydoge_mnemonic';
  static const String _pinKey = 'skydoge_pin';
  static const String _walletKey = 'skydoge_wallet';

  Future<void> saveMnemonic(String mnemonic) async {
    final encrypted = _encrypt(mnemonic);
    await _storage.write(key: _mnemonicKey, value: encrypted);
  }

  Future<String?> getMnemonic() async {
    final encrypted = await _storage.read(key: _mnemonicKey);
    if (encrypted == null) return null;
    return _decrypt(encrypted);
  }

  Future<void> savePin(String pin) async {
    final hashed = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashed);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null) return false;
    return _hashPin(pin) == stored;
  }

  Future<bool> hasPin() async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null;
  }

  Future<void> saveWalletData(Map<String, dynamic> walletData) async {
    final jsonString = jsonEncode(walletData);
    final encrypted = _encrypt(jsonString);
    await _storage.write(key: _walletKey, value: encrypted);
  }

  Future<dynamic> getWalletData() async {
    final encrypted = await _storage.read(key: _walletKey);
    if (encrypted == null) return null;
    final jsonString = _decrypt(encrypted);
    return jsonDecode(jsonString);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> deleteMnemonic() async {
    await _storage.delete(key: _mnemonicKey);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }

  String _encrypt(String plaintext) {
    final bytes = utf8.encode(plaintext);
    final encoded = base64Encode(bytes);
    return encoded;
  }

  String _decrypt(String ciphertext) {
    final bytes = base64Decode(ciphertext);
    return utf8.decode(bytes);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
