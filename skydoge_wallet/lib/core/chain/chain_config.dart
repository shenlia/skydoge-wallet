class ChainConfig {
  final String network;
  final String networkId;
  final int defaultPort;
  final int rpcPort;
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
    required this.rpcPort,
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
  });

  bool get isTestnet => networkId == 'test';

  static const ChainConfig mainnet = ChainConfig(
    network: 'mainnet',
    networkId: 'main',
    defaultPort: 12345,
    rpcPort: 8332,
    bech32Hrp: 'bc',
    pubKeyHashPrefix: 0,
    scriptHashPrefix: 5,
    wifPrefix: 128,
    extPubKeyPrefix: [0x04, 0x88, 0xB2, 0x1E],
    extPrivKeyPrefix: [0x04, 0x88, 0xAD, 0xE4],
    sidechainPubKeyPrefix: 125,
    sidechainScriptPrefix: 63,
    genesisHash: '000000204da4f2092d957aa155339b91892c9e35de481c0a8efe099986936695',
    messageStart: [0xC3, 0xD8, 0xEF, 0x81],
  );

  static const ChainConfig testnet = ChainConfig(
    network: 'testnet',
    networkId: 'test',
    defaultPort: 18441,
    rpcPort: 18332,
    bech32Hrp: 'bc',
    pubKeyHashPrefix: 0,
    scriptHashPrefix: 5,
    wifPrefix: 128,
    extPubKeyPrefix: [0x04, 0x88, 0xB2, 0x1E],
    extPrivKeyPrefix: [0x04, 0x88, 0xAD, 0xE4],
    sidechainPubKeyPrefix: 125,
    sidechainScriptPrefix: 63,
    genesisHash: '00000005e65ea5a412b10fce8e3e4b740c71ce00552efa492856d923a2e357c0',
    messageStart: [0xD5, 0xA3, 0xE8, 0xF6],
  );
}
