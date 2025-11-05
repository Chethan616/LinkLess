import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/sms_message.dart';
import '../../core/constants/encoding_tables.dart';
import 'sms_manager.dart';

/// Mock SMS Manager Implementation
/// For testing and development without real SMS functionality
class MockSmsManager implements SmsManager {
  final StreamController<SmsMessage> _incomingController =
      StreamController.broadcast();

  @override
  Stream<SmsMessage> get incomingSmsStream => _incomingController.stream;

  @override
  Future<void> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    // Simulate sending delay
    await Future.delayed(const Duration(milliseconds: 500));

    print('📤 MockSMS: Sending to $phoneNumber');
    print(
        '   Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

    // Simulate receiving a response after a delay
    _simulateResponse(phoneNumber, message);
  }

  @override
  Future<void> sendSmsInChunks({
    required String phoneNumber,
    required String message,
    required String sessionId,
  }) async {
    final chunkSize = EncodingTables.safeChunkSize;
    final chunks = <String>[];

    // Split message into chunks
    for (var i = 0; i < message.length; i += chunkSize) {
      final end =
          (i + chunkSize < message.length) ? i + chunkSize : message.length;
      chunks.add(message.substring(i, end));
    }

    print('📤 MockSMS: Sending ${chunks.length} chunks to $phoneNumber');

    // Send each chunk
    for (var i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      final chunkMessage =
          '${EncodingTables.chunkStartMarker}$sessionId${EncodingTables.chunkSeparator}$i${EncodingTables.chunkSeparator}${chunks.length}${EncodingTables.chunkEndMarker}$chunk';

      await sendSms(
        phoneNumber: phoneNumber,
        message: chunkMessage,
      );

      // Small delay between chunks
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _simulateResponse(String phoneNumber, String message) async {
    // Simulate server processing by calling the actual backend
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 MockSMS: Calling backend server...');

        // Call the backend server via ngrok (works on mobile data + WiFi)
        final response = await http.post(
          Uri.parse('https://834e48920360.ngrok-free.app/receive_sms'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'From': '+919030257617', // Use a mock user phone number
            'To': '+12765288111', // Server phone number
            'Body': message, // Base-114 encoded URL
          }),
        );

        if (response.statusCode == 200) {
          print('✅ MockSMS: Backend processed request successfully');

          // The backend should have sent SMS chunks back
          // For mock, we'll simulate receiving them
          final responseData = json.decode(response.body);

          if (responseData['success'] == true) {
            // Get the chunks from the response
            final chunks = responseData['chunks'] as List<dynamic>?;

            if (chunks != null && chunks.isNotEmpty) {
              print('📥 MockSMS: Simulating ${chunks.length} response chunks');

              // Simulate receiving each chunk
              for (var i = 0; i < chunks.length; i++) {
                await Future.delayed(Duration(milliseconds: 300 * (i + 1)));

                final responseMessage = SmsMessage(
                  id: '${DateTime.now().millisecondsSinceEpoch}_$i',
                  phoneNumber: phoneNumber,
                  content: chunks[i] as String,
                  timestamp: DateTime.now(),
                  direction: SmsDirection.incoming,
                  status: SmsStatus.received,
                );

                _incomingController.add(responseMessage);
                print(
                    '📥 MockSMS: Received chunk ${i + 1}/${chunks.length} from $phoneNumber');
              }
            }
          }
        } else {
          print('❌ MockSMS: Backend error: ${response.statusCode}');
          // Fallback to mock response on error
          _sendFallbackResponse(phoneNumber);
        }
      } catch (e) {
        print('❌ MockSMS: Failed to call backend: $e');
        print(
            '💡 Make sure backend server is running: cd backend && npm start');
        // Fallback to mock response on error
        _sendFallbackResponse(phoneNumber);
      }
    });
  }

  void _sendFallbackResponse(String phoneNumber) {
    final responseMessage = SmsMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phoneNumber: phoneNumber,
      content:
          '<html><body><h1>Backend Offline</h1><p>Start backend: cd backend && npm start</p></body></html>',
      timestamp: DateTime.now(),
      direction: SmsDirection.incoming,
      status: SmsStatus.received,
    );

    _incomingController.add(responseMessage);
    print('📥 MockSMS: Sent fallback response');
  }

  @override
  Future<bool> requestPermissions() async {
    // Mock: always return true for development
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> hasPermissions() async {
    // Mock: always return true for development
    return true;
  }

  void dispose() {
    _incomingController.close();
  }
}
