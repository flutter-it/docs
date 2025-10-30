import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';
import 'package:flutter/material.dart';

final getIt = GetIt.instance;

// #region example
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.allReady(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // All services ready - show main app
          return HomePage();
        } else {
          // Still initializing - show splash screen
          return SplashScreen();
        }
      },
    );
  }
}
// #endregion example
