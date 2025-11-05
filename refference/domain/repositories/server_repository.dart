import '../entities/server.dart';

/// Server Repository Interface
/// Defines contract for server data operations
abstract class ServerRepository {
  /// Get all servers
  Future<List<Server>> getServers();

  /// Get server by ID
  Future<Server?> getServerById(String id);

  /// Get active server (for sending requests)
  Future<Server?> getActiveServer();

  /// Add a new server
  Future<void> addServer(Server server);

  /// Update existing server
  Future<void> updateServer(Server server);

  /// Delete server
  Future<void> deleteServer(String id);

  /// Set server as active (deactivates others)
  Future<void> setActiveServer(String id);
}
