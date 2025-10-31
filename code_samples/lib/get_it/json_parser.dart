import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  // Factory - always new, immediate cleanup
  getIt.registerFactory<JsonParser>(() => JsonParser());
  final p1 = getIt<JsonParser>();
  print('p1: $p1'); // Creates instance 1
  final p2 = getIt<JsonParser>();
  print('p2: $p2'); // Creates instance 2 (different)

  // Cached Factory - reuses if possible
  getIt.registerCachedFactory<JsonParser>(() => JsonParser());
  final p3 = getIt<JsonParser>();
  print('p3: $p3'); // Creates instance 3
  final p4 = getIt<JsonParser>();
  print('p4: $p4'); // Returns instance 3 (if not GC'd)

  // Lazy Singleton - reuses forever
  getIt.registerLazySingleton<JsonParser>(() => JsonParser());
  final p5 = getIt<JsonParser>();
  print('p5: $p5'); // Creates instance 4
  final p6 = getIt<JsonParser>();
  print('p6: $p6'); // Returns instance 4 (always)
  // #endregion example
}
