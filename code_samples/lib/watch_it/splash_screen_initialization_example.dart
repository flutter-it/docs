import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class SplashScreen extends WatchingWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Selector function called once - starts initialization automatically
    final snapshot = watchFuture(
      (AppService s) => s.initialize(),
      initialValue: false,
    );

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Column(
        children: [
          CircularProgressIndicator(),
          Text('Initializing...'),
        ],
      );
    }

    if (snapshot.hasError) {
      return ErrorScreen(error: snapshot.error);
    }

    // Initialization complete - navigate
    callOnce((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });

    return Container(); // Brief moment before navigation
  }
}
// #endregion example

class ErrorScreen extends StatelessWidget {
  final Object? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Text('Error: $error');
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Home');
  }
}

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: SplashScreen()));
}
