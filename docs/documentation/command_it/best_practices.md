# Best Practices

Production-ready patterns, anti-patterns, and guidelines for using command_it effectively.

## When to Use Commands

### ✅ Use Commands For

**Async operations with UI feedback:**
```dart
late final loadDataCommand = Command.createAsyncNoParam<List<Data>>(
  () => api.fetchData(),
  initialValue: [],
);
// Automatic isRunning, error handling, UI integration
```

**Operations that can fail:**
```dart
late final saveCommand = Command.createAsync<Data, void>(
  (data) => api.save(data),
  errorFilter: PredicatesErrorFilter([
    (e, _) => errorFilter<ApiException>(e, ErrorReaction.localHandler),
  ]),
);
```

**User-triggered actions:**
```dart
late final submitCommand = Command.createAsync<FormData, void>(
  (data) => api.submit(data),
  restriction: formValid.map((valid) => !valid),
);
```

**Operations needing state tracking:**
- Button loading states
- Pull-to-refresh
- Form submissions
- Network requests
- File I/O

### ❌️️ Don't Use Commands For

**Simple getters/setters:**
```dart
// ❌️️ Overkill
late final getNameCommand = Command.createSync<void, String>(
  () => _name,
  '',
);

// ✅ Just use a ValueNotifier
final name = ValueNotifier<String>('');
```

**Pure computations without side effects:**
```dart
// ❌️️ Unnecessary
late final calculateCommand = Command.createSync<int, int>(
  (n) => n * 2,
  0,
);

// ✅ Just use a function
int calculate(int n) => n * 2;
```

**Immediate state changes:**
```dart
// ❌️️ Overcomplicated
late final toggleCommand = Command.createSync<void, bool>(
  () => !_enabled,
  false,
);

// ✅ Use ValueNotifier directly
final enabled = ValueNotifier<bool>(false);
enabled.value = !enabled.value;
```

## Organization Patterns

### Pattern 1: Commands in Services/Managers

```dart
class TodoService {
  final ApiClient api;
  final Database db;

  TodoService(this.api, this.db);

  // Group related commands
  late final loadTodosCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
  );

  late final addTodoCommand = Command.createAsync<Todo, void>(
    (todo) async {
      await api.addTodo(todo);
      loadTodosCommand.run(); // Reload after add
    },
  );

  late final deleteTodoCommand = Command.createAsync<String, void>(
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
```

**Benefits:**
- Centralized business logic
- Easy testing
- Reusable across widgets
- Clear ownership

### Pattern 2: Feature-Based Organization

```dart
// features/authentication/auth_service.dart
class AuthService {
  late final loginCommand = Command.createAsync<LoginData, User>(...);
  late final logoutCommand = Command.createAsyncNoParam<void>(...);
  late final refreshTokenCommand = Command.createAsyncNoParam<Token>(...);
}

// features/profile/profile_service.dart
class ProfileService {
  final AuthService auth;

  late final loadProfileCommand = Command.createAsyncNoParam<Profile>(
    ...,
    restriction: auth.loginCommand.map((user) => !user.isLoggedIn),
  );
}
```

### Pattern 3: Layered Architecture

```dart
// Domain layer: Business logic
class UpdateUserUseCase {
  final UserRepository repo;

  late final command = Command.createAsync<User, void>(
    (user) => repo.update(user),
  );
}

// Presentation layer: UI logic
class ProfileViewModel {
  final UpdateUserUseCase updateUser;

  late final saveCommand = Command.createAsync<ProfileFormData, void>(
    (formData) async {
      final user = formData.toUser();
      await updateUser.command(user);
    },
  );
}
```

## Error Handling Best Practices

### Global + Local Error Handling

```dart
// Set up global handler once at app startup
void setupErrorHandling() {
  Command.globalExceptionHandler = (error, stackTrace) {
    // Log to service
    loggingService.logError(error, stackTrace);

    // Report to crash analytics (production only)
    if (kReleaseMode) {
      crashReporter.report(error, stackTrace);
    }
  };

  // Default filter strategy
  Command.errorFilterDefault = const ErrorHandlerGlobalIfNoLocal();
}

// Per-command error handling
class DataService {
  late final loadCommand = Command.createAsyncNoParam<Data>(
    () => api.load(),
    initialValue: Data.empty(),
    errorFilter: PredicatesErrorFilter([
      // User-facing errors: show in UI
      (e, _) => errorFilter<ValidationException>(e, ErrorReaction.localHandler),

      // Network errors: show + log
      (e, _) => errorFilter<NetworkException>(e, ErrorReaction.localAndGlobalHandler),

      // Critical errors: log only
      (e, _) => ErrorReaction.globalHandler,
    ]),
  );
}
```

### User-Friendly Error Messages

```dart
class DataService {
  late final loadCommand = Command.createAsyncNoParam<Data>(
    () => api.load(),
    initialValue: Data.empty(),
  );

  // Listen to errors and translate to user-friendly messages
  void setupErrorHandling() {
    loadCommand.errors.where((e) => e != null).listen((error, _) {
      final message = _getUserFriendlyMessage(error!.error);
      showUserError(message);
    });
  }

  String _getUserFriendlyMessage(Object error) {
    if (error is NetworkException) {
      return 'Network error. Please check your connection.';
    }
    if (error is ApiException) {
      if (error.statusCode == 401) return 'Please log in again.';
      if (error.statusCode == 403) return 'You don\'t have permission.';
      if (error.statusCode == 404) return 'Data not found.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
```

## Performance Best Practices

### Use Appropriate Initial Values

```dart
// ❌️️ Wasteful: Large initial value that will be replaced
late final loadCommand = Command.createAsyncNoParam<List<HeavyObject>>(
  () => api.load(),
  initialValue: List.generate(1000, (_) => HeavyObject()), // Immediately discarded!
);

// ✅ Lightweight initial value
late final loadCommand = Command.createAsyncNoParam<List<HeavyObject>>(
  () => api.load(),
  initialValue: [], // Empty list is cheap
);
```

### Debounce Text Input

```dart
class SearchService {
  late final searchTextCommand = Command.createSync<String, String>(
    (text) => text,
    initialValue: '',
  );

  late final searchCommand = Command.createAsync<String, List<Result>>(
    (query) => api.search(query),
    initialValue: [],
  );

  SearchService() {
    // Debounce text changes
    searchTextCommand.debounce(Duration(milliseconds: 300)).listen((text, _) {
      if (text.isNotEmpty) {
        searchCommand(text);
      }
    });
  }
}
```

### Dispose Commands Properly

```dart
class DataManager {
  late final command = Command.createAsyncNoParam<Data>(...);

  // ✅ Always dispose in cleanup
  void dispose() {
    command.dispose();
  }
}

// With StatefulWidget
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final manager = DataManager();

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }
}

// With get_it scopes
getIt.registerLazySingleton<DataManager>(
  () => DataManager(),
  dispose: (manager) => manager.dispose(),
);
```

### Avoid Unnecessary Rebuilds

```dart
// ❌️️ Rebuilds on every command property change
ValueListenableBuilder(
  valueListenable: command.results,
  builder: (context, result, _) => Text(result.data?.toString() ?? ''),
)

// ✅ Only rebuilds when value changes
ValueListenableBuilder(
  valueListenable: command,
  builder: (context, data, _) => Text(data.toString()),
)
```

## Restriction Best Practices

### Use isRunningSync for Command Dependencies

```dart
// ✅ Correct: Synchronous restriction
late final saveCommand = Command.createAsync<Data, void>(
  (data) => api.save(data),
  restriction: loadCommand.isRunningSync, // Prevents race conditions
);

// ❌️️ Wrong: Async update can cause races
late final saveCommand = Command.createAsync<Data, void>(
  (data) => api.save(data),
  restriction: loadCommand.isRunning, // Race condition possible!
);
```

### Restriction Logic is Inverted

```dart
// ❌️️ Common mistake: Restriction logic backwards
final isLoggedIn = ValueNotifier<bool>(false);
late final command = Command.createAsyncNoParam<Data>(
  () => api.load(),
  initialValue: Data.empty(),
  restriction: isLoggedIn, // WRONG: Disabled when logged in!
);

// ✅ Correct: Negate the condition
late final command = Command.createAsyncNoParam<Data>(
  () => api.load(),
  initialValue: Data.empty(),
  restriction: isLoggedIn.map((logged) => !logged), // Disabled when NOT logged in
);
```

## Testing Best Practices

### Mock at the Service Level

```dart
// Service with injected dependency
class DataService {
  final ApiClient api;

  DataService(this.api);

  late final loadCommand = Command.createAsyncNoParam<Data>(
    () => api.load(),
    initialValue: Data.empty(),
  );
}

// Test with mock
test('loadCommand handles errors', () async {
  final mockApi = MockApiClient();
  when(mockApi.load()).thenThrow(Exception('Error'));

  final service = DataService(mockApi);

  expect(
    () => service.loadCommand.runAsync(),
    throwsA(isA<Exception>()),
  );
});
```

### Use Collector Pattern

```dart
test('Command state transitions', () async {
  final collector = Collector<bool>();

  final command = Command.createAsyncNoParam<String>(
    () async {
      await Future.delayed(Duration(milliseconds: 50));
      return 'result';
    },
    initialValue: '',
  );

  command.isRunning.listen((running, _) => collector(running));

  await command.runAsync();

  expect(collector.values, [false, true, false]);
});
```

### Test All States

```dart
test('Verify complete command flow', () async {
  final states = <String>[];

  command.results.listen((result, _) {
    if (result.isRunning) states.add('running');
    else if (result.hasError) states.add('error');
    else if (result.hasData) states.add('success');
  });

  await command.runAsync();

  expect(states, ['success', 'running', 'success']);
});
```

## Common Anti-Patterns

### ❌️️ Commands in Widgets

```dart
// ❌️️ BAD: Command created in widget
class MyWidget extends StatelessWidget {
  late final command = Command.createAsyncNoParam<Data>(
    () => api.load(),
    initialValue: Data.empty(),
  );
  // Memory leak! Never disposed
}

// ✅ GOOD: Command in service
class DataService {
  late final loadCommand = Command.createAsyncNoParam<Data>(...);
  void dispose() => loadCommand.dispose();
}
```

### ❌️️ Not Listening to Errors

```dart
// ❌️️ BAD: Errors go nowhere
late final command = Command.createAsyncNoParam<Data>(
  () => api.load(),
  initialValue: Data.empty(),
  errorFilter: const ErrorHandlerLocal(),
);
// No error listener! Assertions in debug mode

// ✅ GOOD: Always listen to errors when using localHandler
command.errors.listen((error, _) {
  if (error != null) showError(error.error);
});
```

### ❌️️ Excessive State in CommandResult

```dart
// ❌️️ BAD: Always using .results when not needed
ValueListenableBuilder(
  valueListenable: command.results,
  builder: (context, result, _) {
    return Text(result.data?.toString() ?? '');
  },
)
// Rebuilds on running, error, success

// ✅ GOOD: Use .value for data-only updates
ValueListenableBuilder(
  valueListenable: command,
  builder: (context, data, _) {
    return Text(data.toString());
  },
)
// Only rebuilds on successful completion
```

### ❌️️ Forgetting initialValue

```dart
// ❌️️ WRONG: Compile error
late final command = Command.createAsyncNoParam<String>(
  () => api.load(),
  // Missing initialValue!
);

// ✅ CORRECT: Always provide initialValue
late final command = Command.createAsyncNoParam<String>(
  () => api.load(),
  initialValue: '', // Required for non-void results
);
```

### ❌️️ Sync Commands with isRunning

```dart
// ❌️️ WRONG: Sync commands don't have isRunning
final command = Command.createSyncNoParam<String>(...);

ValueListenableBuilder(
  valueListenable: command.isRunning, // AssertionError!
  builder: ...,
);

// ✅ CORRECT: Use async command if you need isRunning
final command = Command.createAsyncNoParam<String>(...);
```

## Production Patterns

### Pattern 1: Retry Logic

```dart
class DataService {
  int retryCount = 0;
  final maxRetries = 3;

  late final loadCommand = Command.createAsyncNoParam<Data>(
    () async {
      try {
        final data = await api.load();
        retryCount = 0; // Reset on success
        return data;
      } catch (e) {
        if (retryCount < maxRetries && e is NetworkException) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
          return loadCommand.runAsync(); // Retry
        }
        rethrow;
      }
    },
    initialValue: Data.empty(),
  );
}
```

### Pattern 2: Optimistic Updates

```dart
class TodoService {
  final todos = ValueNotifier<List<Todo>>([]);

  late final deleteTodoCommand = Command.createAsync<String, void>(
    (id) async {
      // Optimistic update
      final oldTodos = todos.value;
      todos.value = todos.value.where((t) => t.id != id).toList();

      try {
        await api.deleteTodo(id);
      } catch (e) {
        // Rollback on error
        todos.value = oldTodos;
        rethrow;
      }
    },
  );
}
```

### Pattern 3: Dependent Loading

```dart
class ProfileService {
  late final loadUserCommand = Command.createAsyncNoParam<User>(
    () => api.loadUser(),
    initialValue: User.empty(),
  );

  late final loadSettingsCommand = Command.createAsyncNoParam<Settings>(
    () async {
      final userId = loadUserCommand.value.id;
      return await api.loadSettings(userId);
    },
    initialValue: Settings.empty(),
    restriction: loadUserCommand.map((user) => !user.isLoggedIn),
  );

  void init() {
    // Load user first
    loadUserCommand.run();

    // Load settings after user loads
    loadUserCommand.where((user) => user.isLoggedIn).listen((_, __) {
      loadSettingsCommand.run();
    });
  }
}
```

### Pattern 4: Cancellation Tokens

```dart
class SearchService {
  CancellationToken? _currentSearch;

  late final searchCommand = Command.createAsync<String, List<Result>>(
    (query) async {
      // Cancel previous search
      _currentSearch?.cancel();

      // Create new token
      final token = CancellationToken();
      _currentSearch = token;

      try {
        final results = await api.search(query, token);

        if (token.isCancelled) {
          throw CancelledException();
        }

        return results;
      } finally {
        if (_currentSearch == token) {
          _currentSearch = null;
        }
      }
    },
    initialValue: [],
  );
}
```

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Getting started
- [Error Handling](/documentation/command_it/error_handling) — Error management
- [Testing](/documentation/command_it/testing) — Testing patterns
- [Integration with watch_it](/documentation/command_it/watch_it_integration) — Reactive UI patterns
