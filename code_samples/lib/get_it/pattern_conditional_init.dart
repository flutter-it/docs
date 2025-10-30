import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
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
// #endregion example
