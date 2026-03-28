import 'dart:convert';

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
  final String rpcHost;
  final int rpcPort;
  final String rpcUser;
  final String rpcPassword;
  final String explorerApi;
  final String derivationPath;

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
    required this.sidechainPubKeyPrefix,
    required this.sidechainScriptPrefix,
    required this.genesisHash,
    required this.messageStart,
    required this.rpcHost,
    required this.rpcPort,
    required this.rpcUser,
    required this.rpcPassword,
    required this.explorerApi,
    required this.derivationPath,
  });

  bool get isTestnet => network == 'testnet';

  String get rpcUrl => 'http://$rpcHost:$rpcPort';

  String get authorizationHeader {
    final credentials = base64Encode(utf8.encode('$rpcUser:$rpcPassword'));
    return 'Basic $credentials';
  }

  ChainConfig copyWith({
    String? rpcHost,
    int? rpcPort,
    String? rpcUser,
    String? rpcPassword,
    String? explorerApi,
  }) {
    return ChainConfig(
      network: network,
      networkId: networkId,
      defaultPort: defaultPort,
      bech32Hrp: bech32Hrp,
      pubKeyHashPrefix: pubKeyHashPrefix,
      scriptHashPrefix: scriptHashPrefix,
      wifPrefix: wifPrefix,
      extPubKeyPrefix: extPubKeyPrefix,
      extPrivKeyPrefix: extPrivKeyPrefix,
      sidechainPubKeyPrefix: sidechainPubKeyPrefix,
      sidechainScriptPrefix: sidechainScriptPrefix,
      genesisHash: genesisHash,
      messageStart: messageStart,
      rpcHost: rpcHost ?? this.rpcHost,
      rpcPort: rpcPort ?? this.rpcPort,
      rpcUser: rpcUser ?? this.rpcUser,
      rpcPassword: rpcPassword ?? this.rpcPassword,
      explorerApi: explorerApi ?? this.explorerApi,
      derivationPath: derivationPath,
    );
  }

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
    genesisHash:
        '000000204da4f2092d957aa155339b91892c9e35de481c0a8efe099986936695',
    messageStart: [0xc3, 0xd8, 0xef, 0x81],
    rpcHost: 'pool.skydoge.net',
    rpcPort: 8332,
    rpcUser: 'skydoge',
    rpcPassword: 'your_rpc_password',
    explorerApi: 'http://explorer.skydoge.net',
    derivationPath: "m/44'/0'/0'/0/0",
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
    sidechainPubKeyPrefix: 125,
    sidechainScriptPrefix: 63,
    genesisHash:
        '00000005e65ea5a412b10fce8e3e4b740c71ce00552efa492856d923a2e357c0',
    messageStart: [0xd5, 0xa3, 0xe8, 0xf6],
    rpcHost: 'testnet.skydoge.net',
    rpcPort: 18332,
    rpcUser: 'testnet',
    rpcPassword: 'testnet_password',
    explorerApi: 'http://testnet.explorer.skydoge.net',
    derivationPath: "m/44'/1'/0'/0/0",
  );
}
