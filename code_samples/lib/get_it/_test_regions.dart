import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  getIt.registerSingleton<ConfigService>(ConfigService());
  getIt.registerFactory<ApiClient>(() => ApiClient());
}
// #endregion

void main() {
  configureDependencies();
}
