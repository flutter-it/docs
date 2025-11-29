// ignore_for_file: unused_field
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();
final db = Database();

// #region managers_managers
class TodoManager {
  final ApiClient api;
  final Database db;

  TodoManager(this.api, this.db);

  // Group related commands
  late final loadTodosCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
  );

  late final addTodoCommand = Command.createAsyncNoResult<Todo>(
    (todo) async {
      await api.saveTodo(todo);
      loadTodosCommand.run(); // Reload after add
    },
  );

  late final deleteTodoCommand = Command.createAsyncNoResult<String>(
    (id) async {
      await api.deleteTodo(id);
      loadTodosCommand.run(); // Reload after delete
    },
    restriction: loadTodosCommand.isRunningSync, // Can't delete while loading
  );

  void dispose() {
    loadTodosCommand.dispose();
    addTodoCommand.dispose();
    deleteTodoCommand.dispose();
  }
}
// #endregion managers_managers

// #region feature_based
// features/authentication/auth_manager.dart
class AuthManager {
  final ApiClient _api = ApiClient();

  // Expose login state as a simple ValueNotifier for restrictions
  final isLoggedIn = ValueNotifier<bool>(false);

  late final loginCommand = Command.createAsync<LoginCredentials, User>(
    (data) async {
      final user = await _api.login(data.username, data.password);
      isLoggedIn.value = true;
      return user;
    },
    initialValue: User.empty(),
  );

  late final logoutCommand = Command.createAsyncNoParamNoResult(
    () async {
      await _api.logout();
      isLoggedIn.value = false;
    },
  );
}

// features/profile/profile_manager.dart
class ProfileManager {
  final AuthManager auth;
  final ApiClient _api = ApiClient();

  ProfileManager(this.auth);

  late final loadProfileCommand = Command.createAsyncNoParam<Profile>(
    () => _api.loadProfile(),
    initialValue: Profile.empty(),
    // restriction: true = disabled, so negate isLoggedIn
    restriction: auth.isLoggedIn.map((logged) => !logged),
  );
}
// #endregion feature_based

// #region proxy_pattern
/// Data proxy that owns commands for lazy loading.
/// Each instance manages its own async operations.
class PodcastProxy {
  PodcastProxy({required this.feedUrl, required PodcastService podcastService})
      : _podcastService = podcastService {
    // Each proxy owns its fetch command
    fetchEpisodesCommand = Command.createAsyncNoParam<List<Episode>>(
      () async {
        if (_episodes != null) return _episodes!;
        _episodes = await _podcastService.fetchEpisodes(feedUrl);
        return _episodes!;
      },
      initialValue: [],
    );
  }

  final String feedUrl;
  final PodcastService _podcastService;
  List<Episode>? _episodes;

  late final Command<void, List<Episode>> fetchEpisodesCommand;

  /// Fetches episodes if not cached, then starts playback.
  late final playEpisodesCommand = Command.createAsyncNoResult<int>((
    startIndex,
  ) async {
    if (_episodes == null) {
      await fetchEpisodesCommand.runAsync();
    }
    if (_episodes != null && _episodes!.isNotEmpty) {
      // Start playback at index...
    }
  });

  List<Episode> get episodes => _episodes ?? [];
}

/// Manager creates and caches proxies
class PodcastManager {
  PodcastManager(this._podcastService);

  final PodcastService _podcastService;
  final _proxyCache = <String, PodcastProxy>{};

  PodcastProxy getOrCreateProxy(String feedUrl) {
    return _proxyCache.putIfAbsent(
      feedUrl,
      () => PodcastProxy(feedUrl: feedUrl, podcastService: _podcastService),
    );
  }
}
// #endregion proxy_pattern

// Stubs for proxy pattern
class PodcastService {
  Future<List<Episode>> fetchEpisodes(String feedUrl) async => [];
}

class Episode {
  final String title;
  Episode(this.title);
}

void main() {
  // Examples compile but don't run
}
