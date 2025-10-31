import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Singleton
getIt.registerSingleton<Logger>(
  FileLogger(),
  instanceName: 'fileLogger',
);

// Lazy Singleton
getIt.registerLazySingleton<Cache>(
  () => MemoryCache(),
  instanceName: 'memory',
);

// Factory
getIt.registerFactory<Report>(
  () => DailyReport(),
  instanceName: 'daily',
);

// Async Singleton
getIt.registerSingletonAsync<Database>(
  () async => Database.connect('prod'),
  instanceName: 'production',
);
// #endregion example