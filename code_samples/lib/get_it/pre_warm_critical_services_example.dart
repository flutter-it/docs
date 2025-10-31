import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  void preWarmCriticalServices() {
    // Only initialize if not already created
    if (!getIt.checkLazySingletonInstanceExists<DatabaseService>()) {
      getIt<DatabaseService>(); // Trigger creation
    }

    if (!getIt.checkLazySingletonInstanceExists<CacheService>()) {
      getIt<CacheService>(); // Trigger creation
    }
  }
}
// #endregion example
