import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NodeRepository {
  static const String _keyNodeHost = 'node_host';
  static const String _keyNodePort = 'node_port';
  static const String _keyNodeUser = 'node_user';
  static const String _keyNodePassword = 'node_password';
  static const String _keyUseCustomNode = 'use_custom_node';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> isUsingCustomNode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyUseCustomNode) ?? false;
  }

  Future<void> setUseCustomNode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyUseCustomNode, value);
  }

  Future<NodeConfig?> getCustomNodeConfig() async {
    final prefs = await _prefs;
    final host = prefs.getString(_keyNodeHost);
    final port = prefs.getInt(_keyNodePort);
    final user = prefs.getString(_keyNodeUser);
    final password = prefs.getString(_keyNodePassword);

    if (host == null || port == null || user == null || password == null) {
      return null;
    }

    return NodeConfig(
      host: host,
      port: port,
      user: user,
      password: password,
    );
  }

  Future<void> saveCustomNodeConfig(NodeConfig config) async {
    final prefs = await _prefs;
    await prefs.setString(_keyNodeHost, config.host);
    await prefs.setInt(_keyNodePort, config.port);
    await prefs.setString(_keyNodeUser, config.user);
    await prefs.setString(_keyNodePassword, config.password);
    await prefs.setBool(_keyUseCustomNode, true);
  }

  Future<void> clearCustomNodeConfig() async {
    final prefs = await _prefs;
    await prefs.remove(_keyNodeHost);
    await prefs.remove(_keyNodePort);
    await prefs.remove(_keyNodeUser);
    await prefs.remove(_keyNodePassword);
    await prefs.setBool(_keyUseCustomNode, false);
  }

  Future<void> resetToDefault() async {
    await clearCustomNodeConfig();
  }
}

class NodeConfig {
  final String host;
  final int port;
  final String user;
  final String password;

  const NodeConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
  });

  String get rpcUrl => 'http://$host:$port';
  String get authHeader {
    final bytes = '$user:$password'.codeUnits;
    return base64Encode(bytes);
  }

  factory NodeConfig.fromJson(Map<String, dynamic> json) {
    return NodeConfig(
      host: json['host'] as String,
      port: json['port'] as int,
      user: json['user'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'user': user,
      'password': password,
    };
  }
}
