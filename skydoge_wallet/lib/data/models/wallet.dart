import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final String name;
  final String type;
  final String mnemonic;
  final String seed;
  final String privateKey;
  final String publicKey;
  final String receivingAddress;
  final int network;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.mnemonic,
    required this.seed,
    required this.privateKey,
    required this.publicKey,
    required this.receivingAddress,
    required this.network,
    required this.createdAt,
  });

  bool get isTestnet => network == 1;
  bool get isMainnet => network == 0;

  Wallet copyWith({
    String? id,
    String? name,
    String? type,
    String? mnemonic,
    String? seed,
    String? privateKey,
    String? publicKey,
    String? receivingAddress,
    int? network,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      mnemonic: mnemonic ?? this.mnemonic,
      seed: seed ?? this.seed,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      receivingAddress: receivingAddress ?? this.receivingAddress,
      network: network ?? this.network,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'mnemonic': mnemonic,
      'seed': seed,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'receivingAddress': receivingAddress,
      'network': network,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String? ?? 'default-wallet',
      name: json['name'] as String? ?? 'Skydoge Wallet',
      type: json['type'] as String? ?? 'mnemonic',
      mnemonic: json['mnemonic'] as String,
      seed: json['seed'] as String,
      privateKey: json['privateKey'] as String,
      publicKey: json['publicKey'] as String,
      receivingAddress: json['receivingAddress'] as String,
      network: json['network'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, type, mnemonic, seed, privateKey, publicKey, receivingAddress, network, createdAt];
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
