import 'dart:convert';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:x509/x509.dart';

import './constants.dart';
import './celik_api.dart';

final signingAlgorithm = algorithms.signing.rsa.sha256;

mixin CelikCrypto on CelikDataAPI {
  Future<bool> verifySignature(Uint8List signature, Uint8List data) async {
    final publicKey = await _getPublicKey();

    return publicKey.createVerifier(signingAlgorithm).verify(
          data,
          Signature(signature),
        );
  }

  Future<void> signData(String password) async {
    final docData = await readData(CelikFile.documentFile);
    final id = docData[CelikTag.id]!;
    final xorKey = utf8.encode("ID$id\u0001$password");
    final xorKeyHash = sha1.convert(xorKey).bytes;
    final xorValue = await readBinaryData(CelikFile.encryptionXOR);

    final encryptedData = await readBinaryData(CelikFile.encryptedPinAndSecret);
    final encryptedPIN = encryptedData.sublist(4, 4 + 8);
    final encryptedSecretKey = encryptedData.sublist(17, 17 + 32);

    final pin = _xorDecryptPIN(
      encryptedPIN,
      xorKeyHash,
      xorValue,
    );
    final secretKey = _xorDecryptSecretKey(
      encryptedSecretKey,
      xorKeyHash,
      xorValue,
    );

    await verify(pin);

    final publicKey = await _getPublicKey();

    _reconstructPrivateKey(
      await _getDecryptedPrivateKeyASN1(secretKey),
      publicKey.modulus,
      publicKey.exponent,
    );
  }

  Future<RsaPublicKey> _getPublicKey() async {
    final standardCertificate =
        (await readBinaryData(CelikFile.standardCertificate)).sublist(4);

    final pemIterable = parsePem(utf8.decode(standardCertificate));
    return pemIterable.firstWhere((x) => x is RsaPublicKey) as RsaPublicKey;
  }

  Future<Uint8List> _getDecryptedPrivateKeyASN1(List<int> secretKey) async {
    final encryptedPrivateKey =
        await readBinaryData(CelikFile.encryptedPrivateKey);
    final sha1hash = sha1.convert(secretKey).bytes;
    final iv = sha1hash.sublist(0, 16);

    final crypt = AesCrypt();
    crypt.aesSetParams(
      Uint8List.fromList(secretKey),
      Uint8List.fromList(iv),
      AesMode.cfb,
    );

    final decrypted = crypt.aesDecrypt(Uint8List.fromList(encryptedPrivateKey));
    return decrypted.sublist(4);
  }
}

void _reconstructPrivateKey(
  Uint8List privateKeyASN1,
  BigInt modulus,
  BigInt publicExponent,
) {
  final parser = ASN1Parser(privateKeyASN1);
  List<BigInt> privateKeyParts = [];
  while (parser.hasNext()) {
    privateKeyParts.add(BigInt.parse(
      parser.nextObject().toHexString(),
    ));
  }
  final prime1 = privateKeyParts[0];
  final prime2 = privateKeyParts[1];
  final primeExponent1 = privateKeyParts[2];
  final primeExponent2 = privateKeyParts[3];
  final crtCoeficient = privateKeyParts[4];

  final privateExponent = 0; // WIP! Need to calculate this
}

List<int> _xorDecryptPIN(
  List<int> pin,
  List<int> xorKeyHash,
  List<int> xorValueWhole,
) {
  List<int> xorValue = xorValueWhole.sublist(4, 4 + 8);

  List<int> xoredValue = [];
  for (var i = 0; i < 8; i++) {
    xoredValue.add(xorValue[i] ^ pin[i] ^ xorKeyHash[i]);
  }
  return xoredValue;
}

List<int> _xorDecryptSecretKey(
  List<int> secretKey,
  List<int> xorKeyHash,
  List<int> xorValueWhole,
) {
  List<int> xorValue = xorValueWhole.sublist(4, 4 + 16);

  List<int> xoredValue = [];
  for (var i = 0; i < 32; i++) {
    xoredValue.add(xorValue[i % 16] ^ secretKey[i] ^ xorKeyHash[i % 16]);
  }
  return xoredValue;
}
