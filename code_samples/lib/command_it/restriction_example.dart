import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class AuthManager {
  // Control whether commands can run
  final isLoggedIn = ValueNotifier<bool>(false);

  final api = ApiClient();

  late final loadDataCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
    // Restrict when NOT logged in (restriction: true = disabled)
    restriction: isLoggedIn.map((loggedIn) => !loggedIn),
  );

  void login() {
    isLoggedIn.value = true;
  }

  void logout() {
    isLoggedIn.value = false;
  }
}

class RestrictedWidget extends StatelessWidget {
  RestrictedWidget({super.key});

  final manager = AuthManager();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Show login status
        ValueListenableBuilder<bool>(
          valueListenable: manager.isLoggedIn,
          builder: (context, isLoggedIn, _) {
            return Text(
              isLoggedIn ? 'Logged In' : 'Not Logged In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLoggedIn ? Colors.green : Colors.red,
              ),
            );
          },
        ),
        SizedBox(height: 16),

        // Login/Logout buttons
        ValueListenableBuilder<bool>(
          valueListenable: manager.isLoggedIn,
          builder: (context, isLoggedIn, _) {
            return ElevatedButton(
              onPressed: isLoggedIn ? manager.logout : manager.login,
              child: Text(isLoggedIn ? 'Logout' : 'Login'),
            );
          },
        ),
        SizedBox(height: 16),

        // Load data button - disabled when not logged in
        ValueListenableBuilder<bool>(
          valueListenable: manager.loadDataCommand.canRun,
          builder: (context, canRun, _) {
            return ElevatedButton(
              onPressed: canRun ? manager.loadDataCommand.run : null,
              child: Text('Load Data'),
            );
          },
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: Center(child: RestrictedWidget()))));
}
