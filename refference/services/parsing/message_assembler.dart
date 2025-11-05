import '../../domain/entities/sms_message.dart';
import '../../core/constants/encoding_tables.dart';

/// SMS Chunk
class SmsChunk {
  final String sessionId;
  final int index;
  final int total;
  final String content;

  const SmsChunk({
    required this.sessionId,
    required this.index,
    required this.total,
    required this.content,
  });
}

/// Message Assembler
/// Handles reassembly of chunked SMS messages
class MessageAssembler {
  final Map<String, List<SmsChunk>> _sessions = {};

  /// Parse chunk metadata from SMS message
  SmsChunk? parseChunk(SmsMessage message) {
    var content = message.content;

    // Twilio trial account prefix
    const twilioPrefix = 'Sent from your Twilio trial account - ';
    if (content.startsWith(twilioPrefix)) {
      content = content.substring(twilioPrefix.length);
    }

    // Check if message has chunk markers
    if (!content.startsWith(EncodingTables.chunkStartMarker)) {
      return null;
    }

    try {
      // Extract metadata
      final endMarkerIndex = content.indexOf(EncodingTables.chunkEndMarker);
      if (endMarkerIndex == -1) return null;

      final metadata = content.substring(
        EncodingTables.chunkStartMarker.length,
        endMarkerIndex,
      );

      final parts = metadata.split(EncodingTables.chunkSeparator);
      if (parts.length != 3) return null;

      final sessionId = parts[0];
      final index = int.parse(parts[1]);
      final total = int.parse(parts[2]);

      final chunkContent = content.substring(
        endMarkerIndex + EncodingTables.chunkEndMarker.length,
      );

      return SmsChunk(
        sessionId: sessionId,
        index: index,
        total: total,
        content: chunkContent,
      );
    } catch (e) {
      print('Error parsing chunk: $e');
      return null;
    }
  }

  /// Add chunk to session
  void addChunk(SmsChunk chunk) {
    if (!_sessions.containsKey(chunk.sessionId)) {
      _sessions[chunk.sessionId] = [];
    }
    _sessions[chunk.sessionId]!.add(chunk);
  }

  /// Check if session is complete
  bool isSessionComplete(String sessionId) {
    final chunks = _sessions[sessionId];
    if (chunks == null || chunks.isEmpty) return false;

    final total = chunks.first.total;
    if (chunks.length != total) return false;

    // Verify all indices are present
    final indices = chunks.map((c) => c.index).toSet();
    for (var i = 0; i < total; i++) {
      if (!indices.contains(i)) return false;
    }

    return true;
  }

  /// Assemble complete message from chunks
  String? assembleMessage(String sessionId) {
    if (!isSessionComplete(sessionId)) return null;

    final chunks = _sessions[sessionId]!;

    // Sort by index
    chunks.sort((a, b) => a.index.compareTo(b.index));

    // Concatenate content
    final buffer = StringBuffer();
    for (var chunk in chunks) {
      buffer.write(chunk.content);
    }

    // Clean up session
    _sessions.remove(sessionId);

    return buffer.toString();
  }

  /// Get session progress
  double getSessionProgress(String sessionId) {
    final chunks = _sessions[sessionId];
    if (chunks == null || chunks.isEmpty) return 0.0;

    final total = chunks.first.total;
    return chunks.length / total;
  }

  /// Clear old sessions (call periodically)
  void clearOldSessions({Duration maxAge = const Duration(hours: 1)}) {
    // In a real implementation, track timestamps and clear old ones
    // For now, just clear all completed sessions
    _sessions.clear();
  }
}
