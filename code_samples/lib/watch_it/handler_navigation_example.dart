import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class LoginScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (UserManager m) => m.currentUser,
      handler: (context, user, cancel) {
        if (user != null) {
          // User logged in - navigate away
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      },
    );

    return Container(); // Login form would go here
  }
}
// #endregion example

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Home Screen');
  }
}

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: LoginScreen()));
}
