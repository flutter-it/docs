// Async objects examples for get_it
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// Sample classes for examples
class DatabaseConnection {
  Future<void> connect() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  static Future<ApiClient> create(String url) async {
    await Future.delayed(Duration(milliseconds: 100));
    return ApiClient(url);
  }

  Future<void> authenticate() async {
    await Future.delayed(Duration(milliseconds: 50));
  }

  void close() {}
}

class HeavyResource {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class ConfigService {
  String apiUrl = 'https://api.example.com';
  String databasePath = '/data/db';

  static Future<ConfigService> load() async {
    await Future.delayed(Duration(milliseconds: 100));
    return ConfigService();
  }

  Future<void> loadFromFile() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class Database {
  final String path;
  Database(this.path);

  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  static Future<void> connect() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class UserRepository {
  final ConfigService config;
  final ApiClient api;
  final Database? db;

  UserRepository({
    required this.config,
    required this.api,
    this.db,
  });
}

class Logger {
  static Future<Logger> initialize() async {
    await Future.delayed(Duration(milliseconds: 50));
    return Logger();
  }
}

// #region register-factory-async
void registerFactoryAsyncExample() {
  // Register async factory
  getIt.registerFactoryAsync<DatabaseConnection>(
    () async {
      final conn = DatabaseConnection();
      await conn.connect();
      return conn;
    },
  );

  // Register with instance name
  getIt.registerFactoryAsync<ApiClient>(
    () async => ApiClient.create('https://api-v2.example.com'),
    instanceName: 'api-v2',
  );
}

Future<void> useFactoryAsync() async {
  // Usage - creates new instance each time
  final db1 = await getIt.getAsync<DatabaseConnection>();
  final db2 = await getIt.getAsync<DatabaseConnection>(); // New instance
}
// #endregion

// #region register-cached-factory-async
void registerCachedFactoryAsyncExample() {
  // Cached async factory
  getIt.registerCachedFactoryAsync<HeavyResource>(
    () async {
      final resource = HeavyResource();
      await resource.initialize();
      return resource;
    },
  );
}

Future<void> useCachedFactoryAsync() async {
  // First access - creates new instance
  final resource1 = await getIt.getAsync<HeavyResource>();

  // While still in memory - returns cached instance
  final resource2 = await getIt.getAsync<HeavyResource>(); // Same instance
}
// #endregion

// #region register-singleton-async
void registerSingletonAsyncExample() {
  // Simple async singleton
  getIt.registerSingletonAsync<Database>(
    () async {
      final db = Database('/data/db');
      await db.initialize();
      return db;
    },
  );

  // With disposal
  getIt.registerSingletonAsync<ApiClient>(
    () async {
      final client = ApiClient('https://api.example.com');
      await client.authenticate();
      return client;
    },
    dispose: (client) => client.close(),
  );

  // With onCreated callback
  getIt.registerSingletonAsync<Logger>(
    () async => Logger.initialize(),
    onCreated: (logger) => print('Logger initialized'),
  );
}

Future<void> useSingletonAsync() async {
  // Wait for singleton to be ready
  await getIt.isReady<Database>();

  // Or wait for all async singletons
  await getIt.allReady();

  // Then access normally
  final db = getIt<Database>();
}
// #endregion

// #region register-lazy-singleton-async
void registerLazySingletonAsyncExample() {
  // Lazy async singleton - created on first access
  getIt.registerLazySingletonAsync<ConfigService>(
    () async {
      final config = ConfigService();
      await config.loadFromFile();
      return config;
    },
  );
}

Future<void> useLazySingletonAsync() async {
  // First access - triggers creation
  final config = await getIt.getAsync<ConfigService>();

  // Subsequent access - returns existing instance
  final config2 = await getIt.getAsync<ConfigService>(); // Same instance
}
// #endregion

// #region dependencies
void dependenciesExample() {
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

  // 4. Repository waits for everything (sync singleton with dependencies)
  getIt.registerSingletonWithDependencies<UserRepository>(
    () => UserRepository(
      api: getIt<ApiClient>(),
      db: getIt<Database>(),
      config: getIt<ConfigService>(),
    ),
    dependsOn: [ConfigService, ApiClient, Database],
  );
}
// #endregion

// #region all-ready
Future<void> allReadyExample() async {
  // Wait for all async singletons
  await getIt.allReady();
  print('All services ready');

  // With timeout
  try {
    await getIt.allReady(timeout: Duration(seconds: 10));
  } on WaitingTimeOutException catch (e) {
    print('Initialization timeout!');
    print('Not ready: ${e.notReadyYet}');
  }
}
// #endregion

// #region is-ready
Future<void> isReadyExample() async {
  // Wait for specific service
  await getIt.isReady<Database>();

  // Now safe to use
  final db = getIt<Database>();

  // Check without waiting
  if (getIt.isReadySync<Database>()) {
    print('Database is ready');
  }
}
// #endregion

// #region best-practice-prefer-singleton-async
void bestPracticePreferSingletonAsync() {
  // Good - starts initializing immediately
  getIt.registerSingletonAsync<Database>(() async {
    final db = Database('/data/db');
    await db.initialize();
    return db;
  });

  // Less ideal - won't initialize until first access
  getIt.registerLazySingletonAsync<Database>(() async {
    final db = Database('/data/db');
    await db.initialize();
    return db;
  });
}
// #endregion

// #region best-practice-use-depends-on
void bestPracticeUseDependsOn() {
  // Good - clear dependency chain
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());

  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient(getIt<ConfigService>().apiUrl),
    dependsOn: [ConfigService],
  );

  // Less ideal - manual orchestration
  getIt.registerSingletonAsync<ApiClient>(() async {
    await getIt.isReady<ConfigService>(); // Manual waiting
    return ApiClient(getIt<ConfigService>().apiUrl);
  });
}
// #endregion
