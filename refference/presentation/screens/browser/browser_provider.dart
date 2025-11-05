import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/sms/sms_manager.dart';
import '../../../services/sms/mock_sms_manager.dart';
import '../../../services/parsing/message_assembler.dart';
import '../../../services/encoding/base114_decoder.dart';
import '../../../services/encoding/base114_encoder.dart';
import '../../../services/encoding/brotli_service.dart';
import '../../../domain/entities/sms_message.dart';
import '../servers/server_provider.dart';

/// SMS Manager Provider
final smsManagerProvider = Provider<SmsManager>((ref) {
  return MockSmsManager();
});

/// Message Assembler Provider
final messageAssemblerProvider = Provider<MessageAssembler>((ref) {
  return MessageAssembler();
});

/// Browser State
enum BrowserStatus {
  idle,
  sendingRequest,
  receivingSms,
  assemblingChunks,
  decodingData,
  complete,
  error,
}

class BrowserState {
  final BrowserStatus status;
  final String? currentUrl;
  final String? htmlContent;
  final String? errorMessage;
  final double progress;
  final int receivedChunks;
  final int totalChunks;

  const BrowserState({
    this.status = BrowserStatus.idle,
    this.currentUrl,
    this.htmlContent,
    this.errorMessage,
    this.progress = 0.0,
    this.receivedChunks = 0,
    this.totalChunks = 0,
  });

  BrowserState copyWith({
    BrowserStatus? status,
    String? currentUrl,
    String? htmlContent,
    String? errorMessage,
    double? progress,
    int? receivedChunks,
    int? totalChunks,
  }) {
    return BrowserState(
      status: status ?? this.status,
      currentUrl: currentUrl ?? this.currentUrl,
      htmlContent: htmlContent ?? this.htmlContent,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
      receivedChunks: receivedChunks ?? this.receivedChunks,
      totalChunks: totalChunks ?? this.totalChunks,
    );
  }
}

/// Browser State Notifier
class BrowserNotifier extends StateNotifier<BrowserState> {
  final SmsManager _smsManager;
  final MessageAssembler _messageAssembler;
  final Ref _ref;

  BrowserNotifier(this._smsManager, this._messageAssembler, this._ref)
      : super(const BrowserState()) {
    _listenToIncomingSms();
  }

  void _listenToIncomingSms() {
    _smsManager.incomingSmsStream.listen((smsMessage) {
      _handleIncomingSms(smsMessage);
    });
  }

  Future<void> requestUrl(String url) async {
    // Get active server
    final activeServer = await _ref.read(activeServerProvider.future);
    if (activeServer == null) {
      state = state.copyWith(
        status: BrowserStatus.error,
        errorMessage: 'No active server configured',
      );
      return;
    }

    try {
      // Update state
      state = state.copyWith(
        status: BrowserStatus.sendingRequest,
        currentUrl: url,
        htmlContent: null,
        errorMessage: null,
        progress: 0.0,
      );

      // Encode URL with Base-114
      final encodedUrl = Base114Encoder.encodeString(url);

      print('🌐 Requesting URL: $url');
      print('📤 Encoded: $encodedUrl');

      // Send SMS request
      await _smsManager.sendSms(
        phoneNumber: activeServer.phoneNumber,
        message: encodedUrl,
      );

      // Update state
      state = state.copyWith(
        status: BrowserStatus.receivingSms,
        progress: 0.1,
      );

      print('✅ Request sent to ${activeServer.name}');
    } catch (e) {
      state = state.copyWith(
        status: BrowserStatus.error,
        errorMessage: 'Failed to send request: $e',
      );
    }
  }

  void _handleIncomingSms(SmsMessage smsMessage) {
    if (state.status != BrowserStatus.receivingSms &&
        state.status != BrowserStatus.assemblingChunks) {
      return;
    }

    try {
      // Try to parse as a chunk first
      final chunk = _messageAssembler.parseChunk(smsMessage);

      if (chunk != null) {
        // It's a valid chunk, process it
        print('📥 Received chunk ${chunk.index + 1}/${chunk.total}');

        // Add chunk to assembler
        _messageAssembler.addChunk(chunk);

        // Update progress
        final progress = _messageAssembler.getSessionProgress(chunk.sessionId);
        state = state.copyWith(
          status: BrowserStatus.assemblingChunks,
          progress: 0.1 + (progress * 0.4), // 10% to 50%
          receivedChunks: (progress * chunk.total).round(),
          totalChunks: chunk.total,
        );

        // Check if complete
        if (_messageAssembler.isSessionComplete(chunk.sessionId)) {
          final assembledMessage =
              _messageAssembler.assembleMessage(chunk.sessionId);
          if (assembledMessage != null) {
            print('✅ Message assembled');
            _decodeMessage(assembledMessage);
          }
        }
      } else {
        // Not a valid chunk, could be a single-part message or an error
        // Let's try to decode it directly, but only if we haven't started chunking
        if (state.status == BrowserStatus.receivingSms &&
            state.receivedChunks == 0) {
          _decodeMessage(smsMessage.content);
        }
      }
    } catch (e) {
      state = state.copyWith(
        status: BrowserStatus.error,
        errorMessage: 'Failed to process SMS: $e',
      );
    }
  }

  void _decodeMessage(String encodedMessage) {
    try {
      state = state.copyWith(
        status: BrowserStatus.decodingData,
        progress: 0.6,
      );

      print('🔓 Decoding Base-114...');

      // Decode Base-114
      final compressedData = Base114Decoder.decode(encodedMessage);

      state = state.copyWith(progress: 0.75);

      print('📦 Decompressing Brotli...');

      // Decompress Brotli
      final htmlContent = BrotliService.decompressString(compressedData);

      print('✅ Decoding complete!');

      // Update state with decoded content
      state = state.copyWith(
        status: BrowserStatus.complete,
        htmlContent: htmlContent,
        progress: 1.0,
      );
    } catch (e) {
      print('❌ Decode error: $e');
      state = state.copyWith(
        status: BrowserStatus.error,
        errorMessage: 'Failed to decode response: $e',
      );
    }
  }

  void reset() {
    state = const BrowserState();
  }
}

/// Browser State Provider
final browserProvider =
    StateNotifierProvider<BrowserNotifier, BrowserState>((ref) {
  final smsManager = ref.watch(smsManagerProvider);
  final messageAssembler = ref.watch(messageAssemblerProvider);
  return BrowserNotifier(smsManager, messageAssembler, ref);
});
