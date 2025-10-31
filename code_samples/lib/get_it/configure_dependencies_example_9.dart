import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));
  getIt.registerFactory<LoginViewModel>(() => LoginViewModel(getIt()));
}

void main() {
  configureDependencies();
  runApp(MyApp());
}
// #endregion example
