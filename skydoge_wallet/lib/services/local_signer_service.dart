import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';

import '../data/models/transaction.dart';

class LocalSignerService {
  SignatureArtifact signAuthorization({
    required UnsignedTransaction transaction,
    required String privateKeyHex,
    required String publicKeyHex,
  }) {
    final digest = SHA256Digest();
    final payloadBytes = Uint8List.fromList(
      transaction.rawHex.codeUnits,
    );
    final payloadHash = digest.process(payloadBytes);

    final signer = ECDSASigner(null, HMac(SHA256Digest(), 64));
    final domain = ECDomainParameters('secp256k1');
    final privateKey = ECPrivateKey(
      BigInt.parse(privateKeyHex, radix: 16),
      domain,
    );

    signer.init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));
    final signature = signer.generateSignature(payloadHash) as ECSignature;

    final signatureHex =
        '${_encodeBigInt(signature.r)}:${_encodeBigInt(signature.s)}';

    return SignatureArtifact(
      algorithm: 'ECDSA-secp256k1-sha256',
      payloadHash: HEX.encode(payloadHash),
      signatureHex: signatureHex,
      publicKeyHex: publicKeyHex,
    );
  }

  bool verifyAuthorization({
    required UnsignedTransaction transaction,
    required SignatureArtifact signature,
  }) {
    final digest = SHA256Digest();
    final payloadHash = digest.process(Uint8List.fromList(transaction.rawHex.codeUnits));
    if (HEX.encode(payloadHash) != signature.payloadHash) {
      return false;
    }

    final domain = ECDomainParameters('secp256k1');
    final publicKeyPoint = domain.curve.decodePoint(HEX.decode(signature.publicKeyHex));
    if (publicKeyPoint == null) {
      return false;
    }

    final verifier = ECDSASigner(null, HMac(SHA256Digest(), 64));
    verifier.init(false, PublicKeyParameter(ECPublicKey(publicKeyPoint, domain)));

    final parts = signature.signatureHex.split(':');
    if (parts.length != 2) {
      return false;
    }

    final ecSignature = ECSignature(
      BigInt.parse(parts[0], radix: 16),
      BigInt.parse(parts[1], radix: 16),
    );

    return verifier.verifySignature(payloadHash, ecSignature);
  }

  String _encodeBigInt(BigInt value) {
    return value.toRadixString(16).padLeft(64, '0');
  }
}
