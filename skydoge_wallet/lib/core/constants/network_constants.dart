class NetworkConstants {
  static const String mainnetRpcHost = 'node1.skydoge.net';
  static const int mainnetRpcPort = 8332;
  static const String mainnetRpcUser = 'skydoge';
  static const String mainnetRpcPassword = 'your_rpc_password';

  static const String testnetRpcHost = 'testnet.skydoge.net';
  static const int testnetRpcPort = 18332;
  static const String testnetRpcUser = 'testnet';
  static const String testnetRpcPassword = 'testnet_password';

  static const int mainnetMagic = 0xD9B4BEF9;
  static const int testnetMagic = 0x0709110B;

  static const int coin = 100000000;
  static const int maxFee = 100000000;

  static const Duration rpcTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}

class NetworkConfig {
  final String host;
  final int port;
  final String user;
  final String password;
  final bool isTestnet;

  const NetworkConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.isTestnet,
  });

  factory NetworkConfig.mainnet() {
    return const NetworkConfig(
      host: NetworkConstants.mainnetRpcHost,
      port: NetworkConstants.mainnetRpcPort,
      user: NetworkConstants.mainnetRpcUser,
      password: NetworkConstants.mainnetRpcPassword,
      isTestnet: false,
    );
  }

  factory NetworkConfig.testnet() {
    return const NetworkConfig(
      host: NetworkConstants.testnetRpcHost,
      port: NetworkConstants.testnetRpcPort,
      user: NetworkConstants.testnetRpcUser,
      password: NetworkConstants.testnetRpcPassword,
      isTestnet: true,
    );
  }

  String get rpcUrl => 'http://$host:$port';
  String get authHeader => 'Basic ${_encodeAuth(user, password)}';

  String _encodeAuth(String user, String password) {
    final bytes = '$user:$password'.codeUnits;
    return hexEncode(bytes);
  }

  String hexEncode(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
