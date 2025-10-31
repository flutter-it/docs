---
title: Async Objects
prev:
  text: 'Object Registration'
  link: '/documentation/get_it/object_registration'
next:
  text: 'Scopes'
  link: '/documentation/get_it/scopes'
---

# Async Objects

## Overview

GetIt provides comprehensive support for asynchronous object creation and initialization. This is essential for objects that need to perform async operations during creation (database connections, network calls, file I/O) or that depend on other async objects being ready first.

**Key capabilities:**
- ✅ **Async Factories** - Create new instances asynchronously on each access
- ✅ **Async Singletons** - Create singletons with async initialization
- ✅ **Dependency Management** - Automatically wait for dependencies before initialization
- ✅ **Startup Orchestration** - Coordinate complex initialization sequences
- ✅ **Manual Signaling** - Fine-grained control over ready state

## Quick Reference

### Async Registration Methods

| Method | When Created | How Many Instances | Lifetime | Best For |
|--------|--------------|-------------------|----------|----------|
| **registerFactoryAsync** | Every `getAsync()` | Many | Per request | Async operations on each access |
| **registerCachedFactoryAsync** | First access + after GC | Reused while in memory | Until garbage collected | Performance optimization for expensive async operations |
| **registerSingletonAsync** | Immediately at registration | One | Permanent | App-level services with async setup |
| **registerLazySingletonAsync** | First `getAsync()` | One | Permanent | Expensive async services not always needed |
| **registerSingletonWithDependencies** | After dependencies ready | One | Permanent | Services depending on other services |

### Accessing Async Objects

<<< ../../../code_samples/lib/get_it/async_quick_reference.dart

## Async Factories

Async factories create a **new instance on each call** to `getAsync()` by executing an asynchronous factory function.

### registerFactoryAsync

Creates a new instance every time you call `getAsync<T>()`.

<<< ../../../code_samples/lib/get_it/async_objects.dart#register-factory-async

**Parameters:**
- `factoryFunc` - Async function that creates and returns the instance
- `instanceName` - Optional name to register multiple factories of the same type

**Example:**

<<< ../../../code_samples/lib/get_it/async_factory_basic.dart

### registerCachedFactoryAsync

Like `registerFactoryAsync`, but caches the instance with a weak reference. Returns the cached instance if it's still in memory; otherwise creates a new one.

<<< ../../../code_samples/lib/get_it/async_objects.dart#register-cached-factory-async

**Example:**

<<< ../../../code_samples/lib/get_it/async_cached_factory_example.dart

### Async Factories with Parameters

Like regular factories, async factories can accept up to two parameters.

<<< ../../../code_samples/lib/get_it/async_factory_param_signatures.dart

**Example:**

<<< ../../../code_samples/lib/get_it/async_factory_param_example.dart

## Async Singletons

Async singletons are created once with async initialization and live for the lifetime of the registration (until unregistered or scope is popped).

### registerSingletonAsync

Registers a singleton with an async factory function that's executed **immediately**. The singleton is marked as ready when the factory function completes (unless `signalsReady` is true).

<<< ../../../code_samples/lib/get_it/async_objects.dart#register-singleton-async

**Parameters:**
- `factoryFunc` - Async function that creates the singleton instance
- `instanceName` - Optional name to register multiple singletons of the same type
- `dependsOn` - List of types this singleton depends on (waits for them to be ready first)
- `signalsReady` - If true, you must manually call `signalReady()` to mark as ready
- `dispose` - Optional cleanup function called when unregistering or resetting
- `onCreated` - Optional callback invoked after the instance is created

**Example:**

<<< ../../../code_samples/lib/get_it/async_singleton_example.dart

### registerLazySingletonAsync

Registers a singleton with an async factory function that's executed **on first access** (when you call `getAsync<T>()` for the first time).

<<< ../../../code_samples/lib/get_it/async_objects.dart#register-lazy-singleton-async

**Parameters:**
- `factoryFunc` - Async function that creates the singleton instance
- `instanceName` - Optional name to register multiple singletons of the same type
- `dispose` - Optional cleanup function called when unregistering or resetting
- `onCreated` - Optional callback invoked after the instance is created
- `useWeakReference` - If true, uses weak reference (allows garbage collection if not used)

**Example:**
```dart
void configureDependencies() {
  // Lazy async singleton - created on first access
  getIt.registerLazySingletonAsync<CacheService>(
    () async {
      final cache = CacheService();
      await cache.loadFromDisk();
      return cache;
    },
  );

  // With weak reference - allows GC when not in use
  getIt.registerLazySingletonAsync<ImageCache>(
    () async => ImageCache.load(),
    useWeakReference: true,
  );
}

// First access - triggers creation
final cache = await getIt.getAsync<CacheService>();

// Subsequent access - returns existing instance
final cache2 = await getIt.getAsync<CacheService>(); // Same instance
```

::: warning Lazy Async Singletons and allReady()
`registerLazySingletonAsync` does **not** block `allReady()` because the factory function is not called until first access. However, once accessed, you can use `isReady()` to wait for its completion.
:::

## Sync Singletons with Dependencies

Sometimes you have a regular (sync) singleton that depends on other async singletons being ready first. Use `registerSingletonWithDependencies` for this pattern.

```dart
void registerSingletonWithDependencies<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
  required Iterable<Type>? dependsOn,
  bool? signalsReady,
  DisposingFunc<T>? dispose,
})
```

**Parameters:**
- `factoryFunc` - **Sync** function that creates the singleton instance (called after dependencies are ready)
- `instanceName` - Optional name to register multiple singletons of the same type
- `dependsOn` - List of types this singleton depends on (waits for them to be ready first)
- `signalsReady` - If true, you must manually call `signalReady()` to mark as ready
- `dispose` - Optional cleanup function called when unregistering or resetting

**Example:**
```dart
void configureDependencies() {
  // Async singletons
  getIt.registerSingletonAsync<ConfigService>(
    () async => ConfigService.load(),
  );

  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient.create(),
  );

  // Sync singleton that depends on async singletons
  getIt.registerSingletonWithDependencies<UserRepository>(
    () => UserRepository(
      config: getIt<ConfigService>(),
      api: getIt<ApiClient>(),
    ),
    dependsOn: [ConfigService, ApiClient],
  );
}

// Wait for all to be ready
await getIt.allReady();

// Now safe to access - dependencies are guaranteed ready
final userRepo = getIt<UserRepository>();
```

## Dependency Management

### Using dependsOn

The `dependsOn` parameter ensures initialization order. When you register a singleton with `dependsOn`, its factory function won't execute until all listed dependencies have signaled ready.

**Example - Sequential initialization:**
```dart
void configureDependencies() {
  // 1. Config loads first (no dependencies)
  getIt.registerSingletonAsync<ConfigService>(
    () async {
      final config = ConfigService();
      await config.loadFromFile();
      return config;
    },
  );

  // 2. API client waits for config
  getIt.registerSingletonAsync<ApiClient>(
    () async {
      final apiUrl = getIt<ConfigService>().apiUrl;
      final client = ApiClient(apiUrl);
      await client.authenticate();
      return client;
    },
    dependsOn: [ConfigService],
  );

  // 3. Database waits for config
  getIt.registerSingletonAsync<Database>(
    () async {
      final dbPath = getIt<ConfigService>().databasePath;
      final db = Database(dbPath);
      await db.initialize();
      return db;
    },
    dependsOn: [ConfigService],
  );

  // 4. App model waits for everything
  getIt.registerSingletonWithDependencies<AppModel>(
    () => AppModel(
      api: getIt<ApiClient>(),
      db: getIt<Database>(),
      config: getIt<ConfigService>(),
    ),
    dependsOn: [ConfigService, ApiClient, Database],
  );
}
```

### Named Dependencies with InitDependency

If you have named registrations, use `InitDependency` to specify both type and instance name.

```dart
void configureDependencies() {
  // Register multiple API clients
  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient.create('https://api-v1.example.com'),
    instanceName: 'api-v1',
  );

  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient.create('https://api-v2.example.com'),
    instanceName: 'api-v2',
  );

  // Depend on specific named instance
  getIt.registerSingletonWithDependencies<DataSync>(
    () => DataSync(getIt<ApiClient>(instanceName: 'api-v2')),
    dependsOn: [InitDependency(ApiClient, instanceName: 'api-v2')],
  );
}
```

## Startup Orchestration

GetIt provides several functions to coordinate async initialization and wait for services to be ready.

### allReady()

Returns a `Future<void>` that completes when **all** async singletons and singletons with `signalsReady` have completed their initialization.

```dart
Future<void> allReady({
  Duration? timeout,
  bool ignorePendingAsyncCreation = false,
})
```

**Parameters:**
- `timeout` - Optional timeout; throws `WaitingTimeOutException` if not ready in time
- `ignorePendingAsyncCreation` - If true, only waits for manual signals, ignores async singletons

**Example with FutureBuilder:**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.allReady(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // All services ready - show main app
          return HomePage();
        } else {
          // Still initializing - show splash screen
          return SplashScreen();
        }
      },
    );
  }
}
```

**Example with timeout:**
```dart
void main() async {
  setupDependencies();

  try {
    await getIt.allReady(timeout: Duration(seconds: 10));
    runApp(MyApp());
  } on WaitingTimeOutException catch (e) {
    print('Initialization timeout!');
    print('Not ready: ${e.notReadyYet}');
    print('Already ready: ${e.areReady}');
    print('Waiting chain: ${e.areWaitedBy}');
  }
}
```

**Calling allReady() multiple times:**

You can call `allReady()` multiple times. After the first `allReady()` completes, if you register new async singletons, you can await `allReady()` again to wait for the new ones.

```dart
void main() async {
  // Register first batch of services
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());
  getIt.registerSingletonAsync<Logger>(() async => Logger.initialize());

  // Wait for first batch
  await getIt.allReady();
  print('Core services ready');

  // Register second batch based on config
  final config = getIt<ConfigService>();
  if (config.enableFeatureX) {
    getIt.registerSingletonAsync<FeatureX>(() async => FeatureX.initialize());
  }

  // Wait for second batch
  await getIt.allReady();
  print('All services ready');

  runApp(MyApp());
}
```

This pattern is especially useful with scopes where each scope needs its own initialization:

```dart
// Initialize base scope
await getIt.allReady();

// Push new scope with its own async services
getIt.pushNewScope(scopeName: 'user-session');
getIt.registerSingletonAsync<UserService>(() async => UserService.load());

// Wait for new scope to be ready
await getIt.allReady();
```

### isReady()

Returns a `Future<void>` that completes when a **specific** singleton is ready.

```dart
Future<void> isReady<T>({
  Object? instance,
  String? instanceName,
  Duration? timeout,
  Object? callee,
})
```

**Parameters:**
- `T` - Type of the singleton to wait for
- `instance` - Alternatively, wait for a specific instance object
- `instanceName` - Wait for named registration
- `timeout` - Optional timeout; throws `WaitingTimeOutException` if not ready in time
- `callee` - Optional parameter for debugging (helps identify who's waiting)

**Example:**
```dart
void main() async {
  setupDependencies();

  // Wait for specific service
  await getIt.isReady<Database>();

  // Now safe to use
  final db = getIt<Database>();

  // Wait for named instance
  await getIt.isReady<ApiClient>(instanceName: 'production');
}
```

### isReadySync()

Checks if a singleton is ready **without waiting** (returns immediately).

```dart
bool isReadySync<T>({
  Object? instance,
  String? instanceName,
})
```

**Example:**
```dart
void checkStatus() {
  if (getIt.isReadySync<Database>()) {
    print('Database is ready');
  } else {
    print('Database still initializing...');
  }
}
```

### allReadySync()

Checks if **all** async singletons are ready without waiting.

```dart
bool allReadySync([bool ignorePendingAsyncCreation = false])
```

**Example:**
```dart
void showUI() {
  if (getIt.allReadySync()) {
    // Show main UI
  } else {
    // Show loading indicator
  }
}
```

## Manual Ready Signaling

Sometimes you need more control over when a singleton signals it's ready. This is useful when initialization involves multiple steps or callbacks.

### Using signalsReady Parameter

When you set `signalsReady: true` during registration, GetIt won't automatically mark the singleton as ready. You must manually call `signalReady()`.

**Example:**
```dart
class ConfigService {
  bool isReady = false;

  ConfigService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Complex async initialization
    await loadRemoteConfig();
    await validateConfig();
    await setupConnections();

    isReady = true;
    // Signal that we're ready
    GetIt.instance.signalReady(this);
  }
}

void configureDependencies() {
  getIt.registerSingleton<ConfigService>(
    ConfigService(),
    signalsReady: true, // Must manually signal ready
  );
}

// Wait for ready signal
await getIt.isReady<ConfigService>();
```

### Using WillSignalReady Interface

Instead of passing `signalsReady: true`, implement the `WillSignalReady` interface. GetIt automatically detects this and waits for manual signaling.

```dart
class ConfigService implements WillSignalReady {
  bool isReady = false;

  ConfigService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadConfig();
    isReady = true;
    GetIt.instance.signalReady(this);
  }
}

void configureDependencies() {
  // No signalsReady parameter needed - interface handles it
  getIt.registerSingleton<ConfigService>(ConfigService());
}
```

### signalReady()

Manually signals that a singleton is ready.

```dart
void signalReady(Object? instance)
```

**Parameters:**
- `instance` - The instance that's ready (passing `null` is legacy and not recommended)

**Example:**
```dart
class DatabaseService {
  DatabaseService() {
    _init();
  }

  Future<void> _init() async {
    await connectToDatabase();
    await runMigrations();

    // Signal this instance is ready
    GetIt.instance.signalReady(this);
  }
}
```

::: tip Legacy Feature
`signalReady(null)` (global ready signal without an instance) is a legacy feature from earlier versions of GetIt. It's recommended to use async registrations (`registerSingletonAsync`, etc.) or instance-specific signaling instead. The global signal approach is less clear about what's being initialized and doesn't integrate well with dependency management.

**Note:** The global `signalReady(null)` will throw an error if you have any async registrations or instances with `signalsReady: true` that haven't signaled yet. Instance-specific signaling works fine alongside async registrations.
:::

## Accessing Async Objects

### getAsync()

Retrieves an instance created by an async factory or waits for an async singleton to complete initialization.

```dart
Future<T> getAsync<T>({
  String? instanceName,
  dynamic param1,
  dynamic param2,
  Type? type,
})
```

**Example:**
```dart
// Get async factory instance
final conn = await getIt.getAsync<DatabaseConnection>();

// Get async singleton (waits if still initializing)
final api = await getIt.getAsync<ApiClient>();

// Get named instance
final cache = await getIt.getAsync<CacheService>(instanceName: 'user-cache');

// Get with parameters (async factory param)
final report = await getIt.getAsync<Report>(
  param1: 'user-123',
  param2: DateTime.now(),
);
```

::: tip Getting Multiple Async Instances
If you need to retrieve multiple async registrations of the same type, see the [Multiple Registrations](/documentation/get_it/multiple_registrations#async-version) chapter for `getAllAsync()` documentation.
:::

## Best Practices

### 1. Prefer registerSingletonAsync for App Initialization

For services needed at app startup, use `registerSingletonAsync` (not lazy) so they start initializing immediately.

```dart
void configureDependencies() {
  // Good - starts initializing immediately
  getIt.registerSingletonAsync<Database>(() async => Database.connect());

  // Less ideal - won't initialize until first access
  getIt.registerLazySingletonAsync<Database>(() async => Database.connect());
}
```

### 2. Use dependsOn to Express Dependencies

Let GetIt manage initialization order instead of manually orchestrating with `isReady()`.

```dart
// Good - clear dependency chain
void configureDependencies() {
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());

  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient(getIt<ConfigService>().apiUrl),
    dependsOn: [ConfigService],
  );
}

// Less ideal - manual orchestration
void configureDependencies() {
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());

  getIt.registerSingletonAsync<ApiClient>(() async {
    await getIt.isReady<ConfigService>(); // Manual waiting
    return ApiClient(getIt<ConfigService>().apiUrl);
  });
}
```

### 3. Use FutureBuilder for Splash Screens

Display a loading screen while services initialize.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: getIt.allReady(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorScreen(error: snapshot.error);
          }

          if (snapshot.hasData) {
            return HomePage();
          }

          return SplashScreen();
        },
      ),
    );
  }
}
```

### 4. Always Set Timeouts for allReady()

Prevent your app from hanging indefinitely if initialization fails.

```dart
void main() async {
  setupDependencies();

  try {
    await getIt.allReady(timeout: Duration(seconds: 30));
    runApp(MyApp());
  } on WaitingTimeOutException catch (e) {
    // Handle timeout - log error, show error screen, etc.
    runApp(ErrorApp(error: e));
  }
}
```

## Common Patterns

### Pattern 1: Layered Initialization

```dart
void configureDependencies() {
  // Layer 1: Core infrastructure
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());
  getIt.registerSingletonAsync<Logger>(() async => Logger.initialize());

  // Layer 2: Network and data access
  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient(getIt<ConfigService>().apiUrl),
    dependsOn: [ConfigService],
  );

  getIt.registerSingletonAsync<Database>(
    () async => Database(getIt<ConfigService>().dbPath),
    dependsOn: [ConfigService],
  );

  // Layer 3: Business logic
  getIt.registerSingletonWithDependencies<UserRepository>(
    () => UserRepository(getIt<ApiClient>(), getIt<Database>()),
    dependsOn: [ApiClient, Database],
  );

  // Layer 4: Application state
  getIt.registerSingletonWithDependencies<AppModel>(
    () => AppModel(getIt<UserRepository>()),
    dependsOn: [UserRepository],
  );
}
```

### Pattern 2: Conditional Initialization

```dart
void configureDependencies({required bool isProduction}) {
  getIt.registerSingletonAsync<ConfigService>(
    () async => ConfigService.load(),
  );

  if (isProduction) {
    getIt.registerSingletonAsync<ApiClient>(
      () async => ApiClient(getIt<ConfigService>().prodUrl),
      dependsOn: [ConfigService],
    );
  } else {
    getIt.registerSingletonAsync<ApiClient>(
      () async => MockApiClient(),
      dependsOn: [ConfigService],
    );
  }
}
```

### Pattern 3: Progress Tracking

```dart
class InitializationProgress extends ChangeNotifier {
  final Map<String, bool> _progress = {};

  void markReady(String serviceName) {
    _progress[serviceName] = true;
    notifyListeners();
  }

  double get percentComplete =>
      _progress.values.where((ready) => ready).length / _progress.length;
}

void configureDependencies(InitializationProgress progress) {
  getIt.registerSingletonAsync<ConfigService>(
    () async => ConfigService.load(),
    onCreated: (_) => progress.markReady('Config'),
  );

  getIt.registerSingletonAsync<Database>(
    () async => Database.connect(),
    dependsOn: [ConfigService],
    onCreated: (_) => progress.markReady('Database'),
  );

  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient.create(),
    dependsOn: [ConfigService],
    onCreated: (_) => progress.markReady('API'),
  );
}
```

### Pattern 4: Retry on Failure

```dart
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: attempt));
    }
  }
  throw StateError('Should never reach here');
}

void configureDependencies() {
  getIt.registerSingletonAsync<ApiClient>(
    () => withRetry(() async => ApiClient.connect()),
  );
}
```

## Further Reading

- [Detailed blog post on async factories and startup orchestration](https://blog.burkharts.net/lets-get-this-party-started-startup-orchestration-with-getit)
- [Scopes Documentation](/documentation/get_it/scopes) - Async initialization within scopes
- [Testing Documentation](/documentation/get_it/testing) - Mocking async services in tests
