import '../../domain/entities/sms_message.dart';

/// SMS Manager Interface
/// Handles SMS sending and receiving operations
abstract class SmsManager {
  /// Send SMS to a phone number
  Future<void> sendSms({
    required String phoneNumber,
    required String message,
  });

  /// Send SMS in chunks (for large messages)
  Future<void> sendSmsInChunks({
    required String phoneNumber,
    required String message,
    required String sessionId,
  });

  /// Listen to incoming SMS messages
  Stream<SmsMessage> get incomingSmsStream;

  /// Request SMS permissions
  Future<bool> requestPermissions();

  /// Check if SMS permissions are granted
  Future<bool> hasPermissions();
}
