import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  // Register lazy singleton
  getIt.registerLazySingleton<HeavyService>(() => HeavyService());

  // Check if it's been created yet
  if (getIt.checkLazySingletonInstanceExists<HeavyService>()) {
    print('HeavyService already created');
  } else {
    print('HeavyService not created yet - will be lazy loaded');
  }

  // Access triggers creation
  final service = getIt<HeavyService>();
  print('service: $service');

  // Now it exists
  assert(getIt.checkLazySingletonInstanceExists<HeavyService>() == true);
  // #endregion example
}
