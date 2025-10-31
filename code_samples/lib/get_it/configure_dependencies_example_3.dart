import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  _registerCoreServices();
  _registerDataServices();
  _registerBusinessLogic();
}

void _registerCoreServices() {
  getIt.registerLazySingleton<Logger>(() => Logger());
  getIt.registerLazySingleton<Analytics>(() => Analytics());
}

void _registerDataServices() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
}

void _registerBusinessLogic() {
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
}

void main() async {
  configureDependencies();
}
// #endregion example
