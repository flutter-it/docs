import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<UserRepository>(UserRepository());
}

// Access directly
final api = getIt<ApiClient>();
// #endregion example
