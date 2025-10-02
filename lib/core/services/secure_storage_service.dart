import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// Service for securely storing sensitive data using encryption
class SecureStorageService {
  static const String _credentialsKey = 'encrypted_credentials';
  static const String _apiKeyKey = 'encrypted_api_key';
  static const String _tokenKey = 'encrypted_token';
  static const String _encryptionKey = 'pm_ajay_secure_key_2025'; // In production, use a proper key management system
  
  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;
  
  SecureStorageService() {
    // Generate key and IV from the encryption key
    final keyBytes = sha256.convert(utf8.encode(_encryptionKey)).bytes;
    _key = encrypt.Key(Uint8List.fromList(keyBytes));
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  /// Saves user credentials securely (for biometric re-authentication)
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    final credentials = jsonEncode({
      'email': email,
      'password': password,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    final encrypted = _encrypter.encrypt(credentials, iv: _iv);
    await prefs.setString(_credentialsKey, encrypted.base64);
  }

  /// Retrieves stored credentials
  Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString(_credentialsKey);
    
    if (encryptedData == null) return null;
    
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      final data = jsonDecode(decrypted) as Map<String, dynamic>;
      
      return {
        'email': data['email'] as String,
        'password': data['password'] as String,
      };
    } catch (e) {
      // Decryption failed, return null
      return null;
    }
  }

  /// Deletes stored credentials
  Future<void> deleteCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_credentialsKey);
  }

  /// Saves API key securely
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = _encrypter.encrypt(apiKey, iv: _iv);
    await prefs.setString(_apiKeyKey, encrypted.base64);
  }

  /// Retrieves API key
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString(_apiKeyKey);
    
    if (encryptedData == null) return null;
    
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      return null;
    }
  }

  /// Saves authentication token securely
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = _encrypter.encrypt(token, iv: _iv);
    await prefs.setString(_tokenKey, encrypted.base64);
  }

  /// Retrieves authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString(_tokenKey);
    
    if (encryptedData == null) return null;
    
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      return null;
    }
  }

  /// Deletes authentication token
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Saves any sensitive data securely
  Future<void> saveSecureData(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    await prefs.setString('secure_$key', encrypted.base64);
  }

  /// Retrieves securely stored data
  Future<String?> getSecureData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString('secure_$key');
    
    if (encryptedData == null) return null;
    
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      return null;
    }
  }

  /// Deletes securely stored data
  Future<void> deleteSecureData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('secure_$key');
  }

  /// Clears all secure storage
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => 
      k.startsWith('encrypted_') || k.startsWith('secure_')
    );
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Checks if credentials are stored
  Future<bool> hasStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_credentialsKey);
  }

  /// Validates stored credentials are not expired (optional security measure)
  Future<bool> areCredentialsValid({Duration maxAge = const Duration(days: 30)}) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString(_credentialsKey);
    
    if (encryptedData == null) return false;
    
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      final data = jsonDecode(decrypted) as Map<String, dynamic>;
      
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final age = DateTime.now().difference(timestamp);
      
      return age <= maxAge;
    } catch (e) {
      return false;
    }
  }
}