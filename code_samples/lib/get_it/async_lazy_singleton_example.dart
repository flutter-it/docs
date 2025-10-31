import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
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

// First access - triggers creation

// Subsequent access - returns existing instance

  void main() async {
    final cache = await getIt.getAsync<CacheService>();
    final cache2 = await getIt.getAsync<CacheService>(); // Same instance
  }
}
// #endregion example
