import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
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
    () => UserRepository(getIt<ApiClient>()),
    dependsOn: [ConfigService, ApiClient],
  );
}

void main() async {
  // Wait for all to be ready
  await getIt.allReady();

  // Now safe to access - dependencies are guaranteed ready
  final userRepo = getIt<UserRepository>();
}
// #endregion example
