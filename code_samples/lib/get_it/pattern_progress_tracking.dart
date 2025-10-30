import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
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
// #endregion example
