import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/server.dart';
import '../../../domain/repositories/server_repository.dart';
import '../../../data/repositories/in_memory_server_repository.dart';

/// Server Repository Provider
final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  return InMemoryServerRepository();
});

/// Server List Provider
final serverListProvider = StreamProvider<List<Server>>((ref) async* {
  final repository = ref.watch(serverRepositoryProvider);

  // Initial load
  yield await repository.getServers();

  // Poll for changes (in real app, would use streams from DB)
  await for (var _ in Stream.periodic(const Duration(seconds: 1))) {
    yield await repository.getServers();
  }
});

/// Active Server Provider
final activeServerProvider = FutureProvider<Server?>((ref) async {
  final repository = ref.watch(serverRepositoryProvider);
  return repository.getActiveServer();
});

/// Server Actions Provider
final serverActionsProvider = Provider((ref) {
  final repository = ref.watch(serverRepositoryProvider);
  return ServerActions(repository, ref);
});

/// Server Actions
class ServerActions {
  final ServerRepository _repository;
  final Ref _ref;

  ServerActions(this._repository, this._ref);

  Future<void> addServer({
    required String name,
    required String phoneNumber,
  }) async {
    // Check if this will be the first server
    final existingServers = await _repository.getServers();
    final isFirstServer = existingServers.isEmpty;

    final server = Server(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phoneNumber: phoneNumber,
      isActive: isFirstServer, // Make first server active automatically
      createdAt: DateTime.now(),
    );

    await _repository.addServer(server);
    _ref.invalidate(serverListProvider);
    _ref.invalidate(activeServerProvider);
  }

  Future<void> updateServer(Server server) async {
    await _repository.updateServer(server);
    _ref.invalidate(serverListProvider);
  }

  Future<void> deleteServer(String id) async {
    await _repository.deleteServer(id);
    _ref.invalidate(serverListProvider);
  }

  Future<void> setActiveServer(String id) async {
    await _repository.setActiveServer(id);
    _ref.invalidate(serverListProvider);
    _ref.invalidate(activeServerProvider);
  }
}
