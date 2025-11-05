import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CryptoService handles all encryption/decryption operations
/// Uses AES-GCM 256-bit for symmetric encryption
/// Uses X25519 for key exchange
class CryptoService {
  static final _algorithm = AesGcm.with256bits();
  static final _keyExchange = X25519();

  // Storage keys
  static const String _clientPrivateKeyKey = 'client_private_key';
  static const String _clientPublicKeyKey = 'client_public_key';
  static const String _gatewayPublicKeyKey = 'gateway_public_key';
  static const String _sharedSecretKey = 'shared_secret_key';

  // Singleton instance
  static CryptoService? _instance;
  static CryptoService get instance {
    _instance ??= CryptoService._();
    return _instance!;
  }

  CryptoService._();

  // Cached keys
  SimpleKeyPair? _clientKeyPair;
  SimplePublicKey? _gatewayPublicKey;
  SecretKey? _sharedSecret;
  bool _isInitialized = false;

  /// Initialize the crypto service
  /// Generates or loads existing keys
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Try to load existing keys
    final privateKeyBytes = prefs.getString(_clientPrivateKeyKey);
    final publicKeyBytes = prefs.getString(_clientPublicKeyKey);

    if (privateKeyBytes != null && publicKeyBytes != null) {
      // Load existing key pair
      _clientKeyPair = await _loadKeyPair(privateKeyBytes, publicKeyBytes);
    } else {
      // Generate new key pair
      _clientKeyPair = await _keyExchange.newKeyPair();
      await _saveKeyPair(_clientKeyPair!);
    }

    // Try to load gateway public key
    final gatewayKeyBytes = prefs.getString(_gatewayPublicKeyKey);
    if (gatewayKeyBytes != null) {
      _gatewayPublicKey = SimplePublicKey(
        base64Decode(gatewayKeyBytes),
        type: KeyPairType.x25519,
      );

      // Derive shared secret
      await _deriveSharedSecret();
    }

    _isInitialized = true;
  }

  /// Set the gateway's public key (must be done before encryption/decryption)
  Future<void> setGatewayPublicKey(String base64EncodedKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gatewayPublicKeyKey, base64EncodedKey);

    _gatewayPublicKey = SimplePublicKey(
      base64Decode(base64EncodedKey),
      type: KeyPairType.x25519,
    );

    await _deriveSharedSecret();
  }

  /// Get the client's public key (to share with gateway)
  Future<String> getClientPublicKey() async {
    if (!_isInitialized) await initialize();

    final publicKey = await _clientKeyPair!.extractPublicKey();
    return base64Encode(publicKey.bytes);
  }

  /// Derive shared secret from client private key and gateway public key
  Future<void> _deriveSharedSecret() async {
    if (_clientKeyPair == null || _gatewayPublicKey == null) {
      throw Exception('Keys not initialized');
    }

    _sharedSecret = await _keyExchange.sharedSecretKey(
      keyPair: _clientKeyPair!,
      remotePublicKey: _gatewayPublicKey!,
    );

    // Optionally cache the shared secret
    final prefs = await SharedPreferences.getInstance();
    final secretBytes = await _sharedSecret!.extractBytes();
    await prefs.setString(_sharedSecretKey, base64Encode(secretBytes));
  }

  /// Encrypt a message using AES-GCM
  /// Returns base64 encoded encrypted data (nonce + ciphertext + MAC)
  Future<String> encrypt(String plaintext) async {
    if (!_isInitialized) await initialize();

    if (_sharedSecret == null) {
      throw Exception(
        'Shared secret not established. Set gateway public key first.',
      );
    }

    // Generate a random nonce
    final nonce = _algorithm.newNonce();

    // Encrypt the message
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: _sharedSecret!,
      nonce: nonce,
    );

    // Return base64 encoded concatenation (nonce + ciphertext + MAC)
    return base64Encode(secretBox.concatenation());
  }

  /// Decrypt a message using AES-GCM
  /// Takes base64 encoded encrypted data (nonce + ciphertext + MAC)
  /// Returns decrypted plaintext
  Future<String> decrypt(String base64Encrypted) async {
    if (!_isInitialized) await initialize();

    if (_sharedSecret == null) {
      throw Exception(
        'Shared secret not established. Set gateway public key first.',
      );
    }

    try {
      // Decode from base64
      final bytes = base64Decode(base64Encrypted);

      // Extract nonce, ciphertext, and MAC
      final secretBox = SecretBox.fromConcatenation(
        bytes,
        nonceLength: 12,
        macLength: 16,
      );

      // Decrypt
      final decryptedBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: _sharedSecret!,
      );

      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Save key pair to secure storage
  Future<void> _saveKeyPair(SimpleKeyPair keyPair) async {
    final prefs = await SharedPreferences.getInstance();

    // Extract and save private key
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    await prefs.setString(_clientPrivateKeyKey, base64Encode(privateKeyBytes));

    // Extract and save public key
    final publicKey = await keyPair.extractPublicKey();
    await prefs.setString(_clientPublicKeyKey, base64Encode(publicKey.bytes));
  }

  /// Load key pair from secure storage
  Future<SimpleKeyPair> _loadKeyPair(
    String privateKeyBase64,
    String publicKeyBase64,
  ) async {
    final privateKeyBytes = base64Decode(privateKeyBase64);
    final publicKeyBytes = base64Decode(publicKeyBase64);

    return SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );
  }

  /// Clear all stored keys (for testing or reset)
  Future<void> clearKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientPrivateKeyKey);
    await prefs.remove(_clientPublicKeyKey);
    await prefs.remove(_gatewayPublicKeyKey);
    await prefs.remove(_sharedSecretKey);

    _clientKeyPair = null;
    _gatewayPublicKey = null;
    _sharedSecret = null;
    _isInitialized = false;
  }

  /// Check if gateway public key is set
  bool get hasGatewayKey => _gatewayPublicKey != null;

  /// Check if service is ready for encryption/decryption
  bool get isReady => _isInitialized && _sharedSecret != null;
}
