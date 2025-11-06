import 'package:telephony/telephony.dart';
import 'crypto_service.dart';

/// SmsService handles all SMS operations
/// Manages sending and receiving encrypted SMS messages
class SmsService {
  final Telephony _telephony = Telephony.instance;
  final CryptoService _cryptoService = CryptoService.instance;

  // Singleton instance
  static SmsService? _instance;
  static SmsService get instance {
    _instance ??= SmsService._();
    return _instance!;
  }

  SmsService._();

  // Gateway phone number (should be configured by user)
  String? _gatewayPhoneNumber;

  // Callback for incoming decrypted messages
  Function(String message, String sender)? _onMessageReceived;

  /// Initialize SMS service and request permissions
  Future<bool> initialize() async {
    // Request SMS permissions
    final permissionsGranted =
        await _telephony.requestPhoneAndSmsPermissions ?? false;

    if (!permissionsGranted) {
      return false;
    }

    // Set up SMS listener
    _telephony.listenIncomingSms(
      onNewMessage: _handleIncomingSms,
      listenInBackground: false,
    );

    return true;
  }

  /// Set the gateway phone number
  void setGatewayNumber(String phoneNumber) {
    _gatewayPhoneNumber = phoneNumber;
  }

  /// Get the current gateway phone number
  String? get gatewayNumber => _gatewayPhoneNumber;

  /// Set callback for incoming messages
  void setMessageCallback(Function(String message, String sender) callback) {
    _onMessageReceived = callback;
  }

  /// Send an encrypted SMS request to the gateway
  ///
  /// Parameters:
  /// - url: The URL to request from the gateway
  ///
  /// Returns:
  /// - true if sent successfully, false otherwise
  Future<bool> sendRequest(String url) async {
    if (_gatewayPhoneNumber == null) {
      throw Exception('Gateway phone number not set');
    }

    if (!_cryptoService.isReady) {
      throw Exception(
        'Crypto service not ready. Set gateway public key first.',
      );
    }

    try {
      // Encrypt the URL
      final encryptedUrl = await _cryptoService.encrypt(url);

      // Add Linkless prefix
      final message = 'LK:$encryptedUrl';

      // Debug logging
      print('=== SMS SEND DEBUG ===');
      print('Original URL: $url');
      print('Encrypted length: ${encryptedUrl.length}');
      print(
        'Message prefix: ${message.substring(0, message.length > 20 ? 20 : message.length)}...',
      );
      print('Full message length: ${message.length}');
      print('Gateway number: $_gatewayPhoneNumber');
      print('=====================');

      // Send SMS
      await _telephony.sendSms(to: _gatewayPhoneNumber!, message: message);

      return true;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  /// Send an encrypted SMS reply (used by Gateway)
  ///
  /// Parameters:
  /// - recipient: Phone number to send to
  /// - content: Plain text content to encrypt and send
  ///
  /// Returns:
  /// - true if sent successfully, false otherwise
  Future<bool> sendReply(String recipient, String content) async {
    if (!_cryptoService.isReady) {
      throw Exception('Crypto service not ready');
    }

    try {
      // Encrypt the content
      final encryptedContent = await _cryptoService.encrypt(content);

      // Send SMS (no prefix for replies)
      await _telephony.sendSms(to: recipient, message: encryptedContent);

      return true;
    } catch (e) {
      print('Error sending reply SMS: $e');
      return false;
    }
  }

  /// Handle incoming SMS messages
  void _handleIncomingSms(SmsMessage message) async {
    try {
      final sender = message.address ?? 'Unknown';
      final body = message.body ?? '';

      if (body.isEmpty) return;

      String decryptedMessage;

      // Check if it's a Linkless request (has LK: prefix)
      if (body.startsWith('LK:')) {
        // This is a request from a client (Gateway receives this)
        final encryptedData = body.substring(3); // Remove "LK:" prefix
        decryptedMessage = await _cryptoService.decrypt(encryptedData);
      } else {
        // This is a reply from gateway (Client receives this)
        decryptedMessage = await _cryptoService.decrypt(body);
      }

      // Call the callback if set
      if (_onMessageReceived != null) {
        _onMessageReceived!(decryptedMessage, sender);
      }
    } catch (e) {
      print('Error handling incoming SMS: $e');
      // Optionally notify about decryption failure
      if (_onMessageReceived != null) {
        _onMessageReceived!(
          '⚠️ Failed to decrypt message',
          message.address ?? 'Unknown',
        );
      }
    }
  }

  /// Check if SMS permissions are granted
  Future<bool> hasPermissions() async {
    return await _telephony.requestPhoneAndSmsPermissions ?? false;
  }

  /// Get all SMS messages (for debugging/testing)
  Future<List<SmsMessage>> getAllMessages() async {
    return await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
    );
  }
}
