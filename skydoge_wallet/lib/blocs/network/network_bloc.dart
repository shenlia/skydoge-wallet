import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/node_repository.dart';
import '../../services/explorer_api_service.dart';
import '../../services/rpc_service.dart';
import '../../core/constants/network_constants.dart';

abstract class NetworkEvent extends Equatable {
  const NetworkEvent();
  @override
  List<Object?> get props => [];
}

class InitNetworkEvent extends NetworkEvent {
  final bool isTestnet;
  const InitNetworkEvent({this.isTestnet = false});
  @override
  List<Object?> get props => [isTestnet];
}

class SwitchNetworkEvent extends NetworkEvent {
  final bool isTestnet;
  const SwitchNetworkEvent({required this.isTestnet});
  @override
  List<Object?> get props => [isTestnet];
}

class ConnectNodeEvent extends NetworkEvent {
  final String host;
  final int port;
  final String user;
  final String password;
  const ConnectNodeEvent({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
  });
  @override
  List<Object?> get props => [host, port, user, password];
}

class ResetToDefaultNodeEvent extends NetworkEvent {
  const ResetToDefaultNodeEvent();
}

abstract class NetworkState extends Equatable {
  const NetworkState();
  @override
  List<Object?> get props => [];
}

class NetworkInitial extends NetworkState {
  const NetworkInitial();
}

class NetworkLoading extends NetworkState {
  const NetworkLoading();
}

class NetworkReady extends NetworkState {
  final bool isTestnet;
  final bool isUsingCustomNode;
  final String nodeHost;
  final int nodePort;
  final ExplorerApiService explorerApi;
  final RpcService rpcService;

  const NetworkReady({
    required this.isTestnet,
    required this.isUsingCustomNode,
    required this.nodeHost,
    required this.nodePort,
    required this.explorerApi,
    required this.rpcService,
  });

  @override
  List<Object?> get props => [isTestnet, isUsingCustomNode, nodeHost, nodePort];
}

class NetworkError extends NetworkState {
  final String message;
  const NetworkError({required this.message});
  @override
  List<Object?> get props => [message];
}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NodeRepository _nodeRepository = NodeRepository();

  NetworkBloc() : super(const NetworkInitial()) {
    on<InitNetworkEvent>(_onInit);
    on<SwitchNetworkEvent>(_onSwitch);
    on<ConnectNodeEvent>(_onConnect);
    on<ResetToDefaultNodeEvent>(_onReset);
  }

  Future<void> _onInit(InitNetworkEvent event, Emitter<NetworkState> emit) async {
    emit(const NetworkLoading());

    try {
      final nodeRepository = NodeRepository();
      final useCustom = await nodeRepository.isUsingCustomNode();

      String host;
      int port;
      String user;
      String password;

      if (useCustom) {
        final config = await nodeRepository.getCustomNodeConfig();
        if (config != null) {
          host = config.host;
          port = config.port;
          user = config.user;
          password = config.password;
        } else {
          host = NetworkConstants.mainnetRpcHost;
          port = NetworkConstants.mainnetRpcPort;
          user = NetworkConstants.mainnetRpcUser;
          password = NetworkConstants.mainnetRpcPassword;
        }
      } else {
        host = NetworkConstants.mainnetRpcHost;
        port = NetworkConstants.mainnetRpcPort;
        user = NetworkConstants.mainnetRpcUser;
        password = NetworkConstants.mainnetRpcPassword;
      }

      final explorerApi = event.isTestnet
          ? ExplorerApiService.testnet()
          : ExplorerApiService.mainnet();

      final networkConfig = NetworkConfig(
        host: host,
        port: port,
        user: user,
        password: password,
        isTestnet: event.isTestnet,
      );

      final rpcService = RpcService(config: networkConfig);

      emit(NetworkReady(
        isTestnet: event.isTestnet,
        isUsingCustomNode: useCustom,
        nodeHost: host,
        nodePort: port,
        explorerApi: explorerApi,
        rpcService: rpcService,
      ));
    } catch (e) {
      emit(NetworkError(message: 'Failed to initialize network: $e'));
    }
  }

  Future<void> _onSwitch(SwitchNetworkEvent event, Emitter<NetworkState> emit) async {
    add(InitNetworkEvent(isTestnet: event.isTestnet));
  }

  Future<void> _onConnect(ConnectNodeEvent event, Emitter<NetworkState> emit) async {
    emit(const NetworkLoading());

    try {
      await _nodeRepository.saveCustomNodeConfig(NodeConfig(
        host: event.host,
        port: event.port,
        user: event.user,
        password: event.password,
      ));

      final explorerApi = ExplorerApiService.mainnet();
      final networkConfig = NetworkConfig(
        host: event.host,
        port: event.port,
        user: event.user,
        password: event.password,
        isTestnet: false,
      );

      final rpcService = RpcService(config: networkConfig);

      emit(NetworkReady(
        isTestnet: false,
        isUsingCustomNode: true,
        nodeHost: event.host,
        nodePort: event.port,
        explorerApi: explorerApi,
        rpcService: rpcService,
      ));
    } catch (e) {
      emit(NetworkError(message: 'Failed to connect: $e'));
    }
  }

  Future<void> _onReset(ResetToDefaultNodeEvent event, Emitter<NetworkState> emit) async {
    await _nodeRepository.resetToDefault();
    add(const InitNetworkEvent());
  }
}
