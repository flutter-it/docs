import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Good - clear dependency chain
void configureDependencies() {
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());

  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient(getIt<ConfigService>().apiUrl),
    dependsOn: [ConfigService],
  );
}

// Less ideal - manual orchestration
void configureDependenciesManual() {
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());

  getIt.registerSingletonAsync<ApiClient>(() async {
    await getIt.isReady<ConfigService>(); // Manual waiting
    return ApiClient(getIt<ConfigService>().apiUrl);
  });
}
// #endregion example
