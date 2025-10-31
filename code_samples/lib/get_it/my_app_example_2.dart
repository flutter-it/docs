import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// get_it manages your business objects
getIt.registerLazySingleton<AuthService>(() => AuthService());
getIt.registerLazySingleton<UserRepository>(() => UserRepository());

// Provider propagates UI state down the tree
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MaterialApp(...),
    );
  }
}
// #endregion example