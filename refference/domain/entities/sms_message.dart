import 'package:equatable/equatable.dart';

/// SMS Message Entity
/// Represents a single SMS message in the system
class SmsMessage extends Equatable {
  final String id;
  final String phoneNumber;
  final String content;
  final DateTime timestamp;
  final SmsDirection direction;
  final SmsStatus status;
  final int? chunkIndex;
  final int? totalChunks;
  final String? sessionId;

  const SmsMessage({
    required this.id,
    required this.phoneNumber,
    required this.content,
    required this.timestamp,
    required this.direction,
    required this.status,
    this.chunkIndex,
    this.totalChunks,
    this.sessionId,
  });

  SmsMessage copyWith({
    String? id,
    String? phoneNumber,
    String? content,
    DateTime? timestamp,
    SmsDirection? direction,
    SmsStatus? status,
    int? chunkIndex,
    int? totalChunks,
    String? sessionId,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      totalChunks: totalChunks ?? this.totalChunks,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        content,
        timestamp,
        direction,
        status,
        chunkIndex,
        totalChunks,
        sessionId,
      ];
}

/// SMS Direction
enum SmsDirection {
  incoming,
  outgoing,
}

/// SMS Status
enum SmsStatus {
  pending,
  sent,
  delivered,
  failed,
  received,
}
