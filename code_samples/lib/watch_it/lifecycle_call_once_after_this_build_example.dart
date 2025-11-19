import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

// #region example
class InitializationScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final dbReady = isReady<Database>();
    final configReady = isReady<ConfigService>();

    if (dbReady && configReady) {
      // Navigate once when all dependencies are ready
      // callOnceAfterThisBuild executes after the current build completes
      // Safe for navigation, dialogs, and accessing RenderBox
      callOnceAfterThisBuild((context) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainApp()),
        );
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            if (dbReady) Text('✓ Database ready'),
            if (configReady) Text('✓ Configuration loaded'),
            if (!dbReady || !configReady) Text('Initializing...'),
          ],
        ),
      ),
    );
  }
}
// #endregion example

// Stub classes
class Database {}

class ConfigService {}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Main App')),
        body: Center(child: Text('App is ready!')),
      );
}

void main() {
  runApp(MaterialApp(
    home: InitializationScreen(),
  ));
}
