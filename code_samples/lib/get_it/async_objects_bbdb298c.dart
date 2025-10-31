import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
