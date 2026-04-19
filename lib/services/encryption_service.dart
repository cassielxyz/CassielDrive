import 'dart:convert';


import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Derive a 256-bit key from password using SHA-256
  encrypt.Key _deriveKey(String password) {
    final hash = sha256.convert(utf8.encode(password));
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }

  /// Encrypt data using AES-256-CBC
  Future<Uint8List> encryptData(Uint8List data, String password) async {
    try {
      final key = _deriveKey(password);
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      final encrypted = encrypter.encryptBytes(data, iv: iv);

      // Prepend IV to encrypted data for later extraction
      final result = Uint8List(16 + encrypted.bytes.length);
      result.setRange(0, 16, iv.bytes);
      result.setRange(16, result.length, encrypted.bytes);

      return result;
    } catch (e) {
      debugPrint('Encryption error: $e');
      rethrow;
    }
  }

  /// Decrypt data using AES-256-CBC
  Future<Uint8List> decryptData(Uint8List encryptedData, String password) async {
    try {
      final key = _deriveKey(password);

      // Extract IV from first 16 bytes
      final iv = encrypt.IV(Uint8List.fromList(encryptedData.sublist(0, 16)));
      final cipherBytes = encryptedData.sublist(16);

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(Uint8List.fromList(cipherBytes)),
        iv: iv,
      );

      return Uint8List.fromList(decrypted);
    } catch (e) {
      debugPrint('Decryption error: $e');
      rethrow;
    }
  }

  /// Generate SHA-256 hash for integrity check
  String generateHash(Uint8List data) {
    return sha256.convert(data).toString();
  }

  /// Verify data integrity
  bool verifyHash(Uint8List data, String expectedHash) {
    final actualHash = generateHash(data);
    return actualHash == expectedHash;
  }

  /// Store vault password hash securely
  Future<void> storeVaultPasswordHash(String password) async {
    final hash = sha256.convert(utf8.encode(password)).toString();
    await _secureStorage.write(key: 'vault_password_hash', value: hash);
  }

  /// Verify vault password
  Future<bool> verifyVaultPassword(String password) async {
    final storedHash = await _secureStorage.read(key: 'vault_password_hash');
    if (storedHash == null) return false;
    final inputHash = sha256.convert(utf8.encode(password)).toString();
    return storedHash == inputHash;
  }

  /// Check if vault has been set up
  Future<bool> isVaultConfigured() async {
    final hash = await _secureStorage.read(key: 'vault_password_hash');
    return hash != null;
  }
}
