import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';
import 'package:flutter/material.dart';

final getIt = GetIt.instance;

// #region example
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: getIt.allReady(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorScreen(snapshot.error!);
          }

          if (snapshot.hasData) {
            return HomePage();
          }

          return SplashScreen();
        },
      ),
    );
  }
}
// #endregion example
