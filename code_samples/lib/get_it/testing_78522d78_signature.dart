import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
setUp(() {
  getIt.pushNewScope();
  getIt.registerSingleton<ApiClient>(mockApi); // Register FIRST
});

test('test name', () {
  final service = getIt<UserService>(); // Accesses AFTER mock registered
  // ...
});
// #endregion example
