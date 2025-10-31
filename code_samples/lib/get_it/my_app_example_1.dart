import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// get_it manages your business objects

// Provider propagates UI state down the tree
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MaterialApp(
        home: Scaffold(body: Center(child: Text('Hello'))),
      ),
    );
  }
}

void main() {
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));

  runApp(const MyApp());
}
// #endregion example
