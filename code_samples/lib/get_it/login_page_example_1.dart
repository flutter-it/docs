import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// get_it + watch_it handles BOTH DI and state management

class LoginPage extends WatchingWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = watchIt<AuthService>(); // Rebuilds when auth changes
    return const Scaffold(
      body: Center(child: Text('Login Page')),
    );
  }
}

void main() {
  getIt.registerSingleton<AuthService>(AuthServiceImpl());
  runApp(const MaterialApp(home: LoginPage()));
}
// #endregion example
