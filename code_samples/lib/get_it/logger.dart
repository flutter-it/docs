import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // Created immediately at app startup
  getIt.registerSingleton<Logger>(Logger());

  // Only created when first accessed (lazy)
  getIt.registerLazySingleton<HeavyDatabase>(() => HeavyDatabase());
}
// #endregion example
