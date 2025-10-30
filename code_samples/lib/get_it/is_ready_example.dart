import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingletonAsync<Database>(() async => Database.connect());
  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient.create(),
    instanceName: 'production',
  );
}

// #region example
void main() async {
  setupDependencies();

  // Wait for specific service
  await getIt.isReady<Database>();

  // Now safe to use
  final db = getIt<Database>();

  // Wait for named instance
  await getIt.isReady<ApiClient>(instanceName: 'production');
}
// #endregion example
