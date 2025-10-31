import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
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
// #endregion example
