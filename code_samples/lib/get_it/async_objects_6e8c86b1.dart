import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // Good - starts initializing immediately
  getIt.registerSingletonAsync<Database>(() async => Database.connect());

  // Less ideal - won't initialize until first access
  getIt.registerLazySingletonAsync<Database>(() async => Database.connect());
}
// #endregion example
