import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // Simple registration
  getIt.registerSingleton<Logger>(Logger());

  // With disposal
  getIt.registerSingleton<Database>(
    Database(),
    dispose: (db) => db.close(),
  );
}
// #endregion example
