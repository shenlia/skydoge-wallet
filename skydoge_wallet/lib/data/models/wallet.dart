import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String mnemonic;
  final String seed;
  final String privateKey;
  final String publicKey;
  final String wif;
  final String receivingAddress;
  final int network;
  final String walletType;
  final String derivationPath;
  final DateTime createdAt;

  const Wallet({
    required this.mnemonic,
    required this.seed,
    required this.privateKey,
    required this.publicKey,
    required this.wif,
    required this.receivingAddress,
    required this.network,
    required this.walletType,
    required this.derivationPath,
    required this.createdAt,
  });

  bool get isTestnet => network == 1;
  bool get isMainnet => network == 0;

  Wallet copyWith({
    String? mnemonic,
    String? seed,
    String? privateKey,
    String? publicKey,
    String? wif,
    String? receivingAddress,
    int? network,
    String? walletType,
    String? derivationPath,
    DateTime? createdAt,
  }) {
    return Wallet(
      mnemonic: mnemonic ?? this.mnemonic,
      seed: seed ?? this.seed,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      wif: wif ?? this.wif,
      receivingAddress: receivingAddress ?? this.receivingAddress,
      network: network ?? this.network,
      walletType: walletType ?? this.walletType,
      derivationPath: derivationPath ?? this.derivationPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mnemonic': mnemonic,
      'seed': seed,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'wif': wif,
      'receivingAddress': receivingAddress,
      'network': network,
      'walletType': walletType,
      'derivationPath': derivationPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      mnemonic: json['mnemonic'] as String,
      seed: json['seed'] as String,
      privateKey: json['privateKey'] as String,
      publicKey: json['publicKey'] as String,
      wif: json['wif'] as String? ?? '',
      receivingAddress: json['receivingAddress'] as String,
      network: json['network'] as int,
      walletType: json['walletType'] as String? ?? 'mnemonic',
      derivationPath: json['derivationPath'] as String? ?? "m/44'/0'/0'/0/0",
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        mnemonic,
        seed,
        privateKey,
        publicKey,
        wif,
        receivingAddress,
        network,
        walletType,
        derivationPath,
        createdAt,
      ];
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
