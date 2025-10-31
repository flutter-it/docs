import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// get_it + watch_it handles BOTH DI and state management

void main() {
  getIt.registerSingleton<AuthService>(AuthService());

  class LoginPage extends WatchingWidget {
    @override
    Widget build(BuildContext context) {
      final auth = watchIt<AuthService>(); // Rebuilds when auth changes
      return /* ... */;
    }
  }
}
// #endregion example