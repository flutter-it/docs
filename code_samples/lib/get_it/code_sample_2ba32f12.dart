import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
// Reset so it recreates on next get()
  getIt.resetLazySingleton<UserCache>();

// Next access will call the factory function again
  final cache = getIt<UserCache>();
  print('cache: $cache'); // New instance created
  // #endregion example
}
