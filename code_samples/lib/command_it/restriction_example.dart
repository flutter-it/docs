import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
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

class RestrictedWidget extends WatchingWidget {
  const RestrictedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch login status
    final isLoggedIn = watchValue((AuthManager m) => m.isLoggedIn);

    // Watch if command can run
    final canRun = watchValue((AuthManager m) => m.loadDataCommand.canRun);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Show login status
        Text(
          isLoggedIn ? 'Logged In' : 'Not Logged In',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLoggedIn ? Colors.green : Colors.red,
          ),
        ),
        SizedBox(height: 16),

        // Login/Logout buttons
        ElevatedButton(
          onPressed:
              isLoggedIn ? di<AuthManager>().logout : di<AuthManager>().login,
          child: Text(isLoggedIn ? 'Logout' : 'Login'),
        ),
        SizedBox(height: 16),

        // Load data button - automatically disabled when not logged in
        ElevatedButton(
          onPressed: canRun ? di<AuthManager>().loadDataCommand.run : null,
          child: Text('Load Data'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  di.registerSingleton(AuthManager());
  runApp(MaterialApp(home: Scaffold(body: Center(child: RestrictedWidget()))));
}
