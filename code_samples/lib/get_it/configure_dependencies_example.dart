import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
final getIt = GetIt.instance;

void configureDependencies() {
  // Register your services
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<Database>(Database());
  getIt.registerSingleton<AuthService>(AuthService());
}
// #endregion example
