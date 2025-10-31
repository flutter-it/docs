import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Register lazy singletons
  getIt.registerLazySingleton<CacheService>(() => CacheService());
  getIt.registerLazySingleton<UserPreferences>(() => UserPreferences());

  // Access them (creates instances)
  final cache = getIt<CacheService>();
  print('cache: $cache');
  final prefs = getIt<UserPreferences>();
  print('prefs: $prefs');

  // Reset all lazy singletons in current scope
  await getIt.resetLazySingletons();

  // Next access creates fresh instances
  final newCache = getIt<CacheService>();
  print('newCache: $newCache'); // New instance
}
// #endregion example
