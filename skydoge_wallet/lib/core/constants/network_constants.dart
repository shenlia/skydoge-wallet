class ChainConfig {
  final String network;
  final String networkId;
  final int defaultPort;
  final String bech32Hrp;
  final int pubKeyHashPrefix;
  final int scriptHashPrefix;
  final int wifPrefix;
  final List<int> extPubKeyPrefix;
  final List<int> extPrivKeyPrefix;
  final int? sidechainPubKeyPrefix;
  final int? sidechainScriptPrefix;
  final String genesisHash;
  final List<int> messageStart;

  const ChainConfig({
    required this.network,
    required this.networkId,
    required this.defaultPort,
    required this.bech32Hrp,
    required this.pubKeyHashPrefix,
    required this.scriptHashPrefix,
    required this.wifPrefix,
    required this.extPubKeyPrefix,
    required this.extPrivKeyPrefix,
    this.sidechainPubKeyPrefix,
    this.sidechainScriptPrefix,
    required this.genesisHash,
    required this.messageStart,
  });

  static const ChainConfig mainnet = ChainConfig(
    network: 'mainnet',
    networkId: 'main',
    defaultPort: 12345,
    bech32Hrp: 'bc',
    pubKeyHashPrefix: 0,
    scriptHashPrefix: 5,
    wifPrefix: 128,
    extPubKeyPrefix: [0x04, 0x88, 0xB2, 0x1E],
    extPrivKeyPrefix: [0x04, 0x88, 0xAD, 0xE4],
    sidechainPubKeyPrefix: 125,
    sidechainScriptPrefix: 63,
    genesisHash: '000000204da4f2092d957aa155339b91892c9e35de481c0a8efe099986936695',
    messageStart: [0xc3, 0xd8, 0xef, 0x81],
  );

  static const ChainConfig testnet = ChainConfig(
    network: 'testnet',
    networkId: 'test',
    defaultPort: 19243,
    bech32Hrp: 'tb',
    pubKeyHashPrefix: 111,
    scriptHashPrefix: 196,
    wifPrefix: 239,
    extPubKeyPrefix: [0x04, 0x35, 0x87, 0xCF],
    extPrivKeyPrefix: [0x04, 0x35, 0x83, 0x94],
    genesisHash: '00000005e65ea5a412b10fce8e3e4b740c71ce00552efa492856d923a2e357c0',
    messageStart: [0xd5, 0xa3, 0xe8, 0xf6],
  );

  bool get isMainnet => network == 'mainnet';
  bool get isTestnet => network == 'testnet';
}

class NetworkConstants {
  static const String mainnetRpcHost = 'pool.skydoge.net';
  static const int mainnetRpcPort = 12345;
  static const String mainnetRpcUser = 'skydoge';
  static const String mainnetRpcPassword = 'your_rpc_password';

  static const String testnetRpcHost = 'testnet.skydoge.net';
  static const int testnetRpcPort = 19243;
  static const String testnetRpcUser = 'testnet';
  static const String testnetRpcPassword = 'testnet_password';

  static const String mainnetExplorerApi = 'http://explorer.skydoge.net';
  static const String testnetExplorerApi = 'http://testnet.explorer.skydoge.net';

  static const int mainnetMagic = 0xc3d8ef81;
  static const int testnetMagic = 0xd5a3e8f6;

  static const int coin = 100000000;
  static const int maxFee = 100000000;
  
  static const int dustThreshold = 546;

  static const Duration rpcTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}

class NetworkConfig {
  final String host;
  final int port;
  final String user;
  final String password;
  final ChainConfig chainConfig;

  const NetworkConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.chainConfig,
  });

  factory NetworkConfig.mainnet() {
    return const NetworkConfig(
      host: NetworkConstants.mainnetRpcHost,
      port: NetworkConstants.mainnetRpcPort,
      user: NetworkConstants.mainnetRpcUser,
      password: NetworkConstants.mainnetRpcPassword,
      chainConfig: ChainConfig.mainnet,
    );
  }

  factory NetworkConfig.testnet() {
    return const NetworkConfig(
      host: NetworkConstants.testnetRpcHost,
      port: NetworkConstants.testnetRpcPort,
      user: NetworkConstants.testnetRpcUser,
      password: NetworkConstants.testnetRpcPassword,
      chainConfig: ChainConfig.testnet,
    );
  }

  bool get isTestnet => chainConfig.isTestnet;
  bool get isMainnet => chainConfig.isMainnet;
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
