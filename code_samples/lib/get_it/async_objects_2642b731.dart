import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // Lazy async singleton - created on first access
  getIt.registerLazySingletonAsync<CacheService>(
    () async {
      final cache = CacheService();
      await cache.loadFromDisk();
      return cache;
    },
  );

  // With weak reference - allows GC when not in use
  getIt.registerLazySingletonAsync<ImageCache>(
    () async => ImageCache.load(),
    useWeakReference: true,
  );
}

Future<void> main() async {
  configureDependencies();

  // First access - triggers creation
  final cache = await getIt.getAsync<CacheService>();

  // Subsequent access - returns existing instance
  final cache2 = await getIt.getAsync<CacheService>(); // Same instance
}
// #endregion example
