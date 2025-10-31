import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureCoreDependencies() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
}

void configureAuthDependencies() {
  getIt.pushNewScope(
    scopeName: 'authenticated',
    init: (scope) {
      scope.registerLazySingleton<AuthService>(() => AuthService(getIt()));
      scope
          .registerLazySingleton<UserRepository>(() => UserRepository(getIt()));
    },
  );
}

void configureShopDependencies() {
  getIt.pushNewScope(
    scopeName: 'shopping',
    init: (scope) {
      scope.registerLazySingleton<CartService>(() => CartService(getIt()));
      scope.registerLazySingleton<OrderRepository>(
          () => OrderRepository(getIt()));
    },
  );
}

void main() {
  configureCoreDependencies();
  runApp(MyApp());
}

// Later, when user logs in
void onLogin() {
  configureAuthDependencies(); // Pushes scope and registers services
}

// When user opens shop feature
void openShop() {
  configureShopDependencies(); // Pushes scope and registers services
}

// When user logs out
void onLogout() async {
  await getIt.popScope(); // Removes auth scope and disposes services
}
// #endregion example
