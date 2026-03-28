import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/network_constants.dart';
import '../../data/repositories/node_repository.dart';
import '../../services/explorer_api_service.dart';
import '../../services/rpc_service.dart';

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
  final bool isTestnet;

  const ConnectNodeEvent({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.isTestnet,
  });

  @override
  List<Object?> get props => [host, port, user, password, isTestnet];
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

  Future<void> _onInit(
    InitNetworkEvent event,
    Emitter<NetworkState> emit,
  ) async {
    emit(const NetworkLoading());

    try {
      final useCustom = await _nodeRepository.isUsingCustomNode();
      final baseConfig = event.isTestnet ? NetworkConfig.testnet() : NetworkConfig.mainnet();

      late final NetworkConfig networkConfig;
      if (useCustom) {
        final custom = await _nodeRepository.getCustomNodeConfig();
        if (custom != null) {
          networkConfig = NetworkConfig.custom(
            baseChain: baseConfig.chain,
            host: custom.host,
            port: custom.port,
            user: custom.user,
            password: custom.password,
          );
        } else {
          networkConfig = baseConfig;
        }
      } else {
        networkConfig = baseConfig;
      }

      final explorerApi =
          event.isTestnet ? ExplorerApiService.testnet() : ExplorerApiService.mainnet();

      emit(
        NetworkReady(
          isTestnet: event.isTestnet,
          isUsingCustomNode: useCustom,
          nodeHost: networkConfig.host,
          nodePort: networkConfig.port,
          explorerApi: explorerApi,
          rpcService: RpcService(config: networkConfig),
        ),
      );
    } catch (error) {
      emit(NetworkError(message: 'Failed to initialize network: $error'));
    }
  }

  Future<void> _onSwitch(
    SwitchNetworkEvent event,
    Emitter<NetworkState> emit,
  ) async {
    add(InitNetworkEvent(isTestnet: event.isTestnet));
  }

  Future<void> _onConnect(
    ConnectNodeEvent event,
    Emitter<NetworkState> emit,
  ) async {
    emit(const NetworkLoading());

    try {
      await _nodeRepository.saveCustomNodeConfig(
        NodeConfig(
          host: event.host,
          port: event.port,
          user: event.user,
          password: event.password,
        ),
      );

      add(InitNetworkEvent(isTestnet: event.isTestnet));
    } catch (error) {
      emit(NetworkError(message: 'Failed to connect: $error'));
    }
  }

  Future<void> _onReset(
    ResetToDefaultNodeEvent event,
    Emitter<NetworkState> emit,
  ) async {
    await _nodeRepository.resetToDefault();
    add(const InitNetworkEvent());
  }
}
