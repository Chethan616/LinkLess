import '../../domain/entities/server.dart';
import '../../domain/repositories/server_repository.dart';

/// In-Memory Server Repository Implementation
/// For development and testing without database
class InMemoryServerRepository implements ServerRepository {
  final List<Server> _servers = [];

  @override
  Future<List<Server>> getServers() async {
    return List.unmodifiable(_servers);
  }

  @override
  Future<Server?> getServerById(String id) async {
    try {
      return _servers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Server?> getActiveServer() async {
    try {
      return _servers.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addServer(Server server) async {
    _servers.add(server);
  }

  @override
  Future<void> updateServer(Server server) async {
    final index = _servers.indexWhere((s) => s.id == server.id);
    if (index != -1) {
      _servers[index] = server;
    }
  }

  @override
  Future<void> deleteServer(String id) async {
    _servers.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> setActiveServer(String id) async {
    // Deactivate all servers
    for (var i = 0; i < _servers.length; i++) {
      _servers[i] = _servers[i].copyWith(isActive: false);
    }

    // Activate the selected server
    final index = _servers.indexWhere((s) => s.id == id);
    if (index != -1) {
      _servers[index] = _servers[index].copyWith(isActive: true);
    }
  }
}
