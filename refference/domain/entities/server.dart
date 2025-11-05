import 'package:equatable/equatable.dart';

/// Server Entity
/// Represents an SMS server that can handle web requests
class Server extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const Server({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isActive = true,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Create a copy with updated fields
  Server copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        isActive,
        createdAt,
        lastUsedAt,
      ];
}
