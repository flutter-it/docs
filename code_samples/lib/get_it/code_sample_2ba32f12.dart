import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Reset so it recreates on next get()
  getIt.resetLazySingleton<UserCache>();

// Next access will call the factory function again
  final cache = getIt<UserCache>();
  print('cache: $cache'); // New instance created
}
// #endregion example
