import '../chain/chain_config.dart';

class NetworkConstants {
  static const Duration rpcTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const int coin = 100000000;
  static const int maxFee = 100000000;

  static ChainConfig chainFor(bool isTestnet) {
    return isTestnet ? ChainConfig.testnet : ChainConfig.mainnet;
  }
}

class NetworkConfig {
  final ChainConfig chain;

  const NetworkConfig({required this.chain});

  factory NetworkConfig.mainnet() {
    return const NetworkConfig(chain: ChainConfig.mainnet);
  }

  factory NetworkConfig.testnet() {
    return const NetworkConfig(chain: ChainConfig.testnet);
  }

  factory NetworkConfig.custom({
    required ChainConfig baseChain,
    required String host,
    required int port,
    required String user,
    required String password,
  }) {
    return NetworkConfig(
      chain: baseChain.copyWith(
        rpcHost: host,
        rpcPort: port,
        rpcUser: user,
        rpcPassword: password,
      ),
    );
  }

  bool get isTestnet => chain.isTestnet;
  String get rpcUrl => chain.rpcUrl;
  String get authHeader => chain.authorizationHeader;
  String get host => chain.rpcHost;
  int get port => chain.rpcPort;
  String get user => chain.rpcUser;
  String get password => chain.rpcPassword;
}
