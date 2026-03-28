import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String mnemonic;
  final String seed;
  final String privateKey;
  final String publicKey;
  final String receivingAddress;
  final int network;
  final DateTime createdAt;
  final String walletType;

  const Wallet({
    required this.mnemonic,
    required this.seed,
    required this.privateKey,
    required this.publicKey,
    required this.receivingAddress,
    required this.network,
    required this.createdAt,
    this.walletType = 'mnemonic',
  });

  bool get isTestnet => network == 1;
  bool get isMainnet => network == 0;
  bool get isFromMnemonic => walletType == 'mnemonic';
  bool get isFromWif => walletType == 'wif';

  Wallet copyWith({
    String? mnemonic,
    String? seed,
    String? privateKey,
    String? publicKey,
    String? receivingAddress,
    int? network,
    DateTime? createdAt,
    String? walletType,
  }) {
    return Wallet(
      mnemonic: mnemonic ?? this.mnemonic,
      seed: seed ?? this.seed,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      receivingAddress: receivingAddress ?? this.receivingAddress,
      network: network ?? this.network,
      createdAt: createdAt ?? this.createdAt,
      walletType: walletType ?? this.walletType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mnemonic': mnemonic,
      'seed': seed,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'receivingAddress': receivingAddress,
      'network': network,
      'createdAt': createdAt.toIso8601String(),
      'walletType': walletType,
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      mnemonic: json['mnemonic'] as String? ?? '',
      seed: json['seed'] as String? ?? '',
      privateKey: json['privateKey'] as String,
      publicKey: json['publicKey'] as String,
      receivingAddress: json['receivingAddress'] as String,
      network: json['network'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      walletType: json['walletType'] as String? ?? 'mnemonic',
    );
  }

  @override
  List<Object?> get props => [mnemonic, seed, privateKey, publicKey, receivingAddress, network, createdAt, walletType];
}

class WalletBalance extends Equatable {
  final int confirmed;
  final int unconfirmed;
  final int immature;
  final int sidechain;

  const WalletBalance({
    required this.confirmed,
    required this.unconfirmed,
    required this.immature,
    required this.sidechain,
  });

  int get total => confirmed + unconfirmed + immature;
  int get spendable => confirmed;

  @override
  List<Object?> get props => [confirmed, unconfirmed, immature, sidechain];
}
