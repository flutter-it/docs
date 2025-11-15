import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

// Service that saves user data
class UserService {
  final saveUserCommand = Command.createAsyncNoParamNoResult(
    () async {
      await Future.delayed(const Duration(seconds: 1));
      print('User saved successfully');
    },
  );

  // Trigger for reload after save
  final saveCompleted = ValueNotifier<int>(0);

  void dispose() {
    saveUserCommand.dispose();
    saveCompleted.dispose();
  }
}

// Service that loads user list
class UserListService {
  final reloadCommand = Command.createAsyncNoParamNoResult(
    () async {
      await Future.delayed(const Duration(milliseconds: 500));
      print('User list reloaded');
    },
  );

  void dispose() {
    reloadCommand.dispose();
  }
}

// #region example
class UserListWidget extends WatchingWidget {
  const UserListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Handler watches for save completion, then triggers reload
    registerHandler(
      select: (UserService s) => s.saveCompleted,
      handler: (context, count, cancel) {
        if (count > 0) {
          // Chain action: trigger reload on another service
          di<UserListService>().reloadCommand.run();
        }
      },
    );

    // Watch the reload state to show loading indicator
    final isReloading = watchValue(
      (UserListService s) => s.reloadCommand.isRunning,
    );
    final isSaving = watchValue(
      (UserService s) => s.saveUserCommand.isRunning,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isReloading)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Reloading list...'),
            ],
          )
        else
          const Text('User List'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isSaving
              ? null
              : () {
                  di<UserService>().saveUserCommand.run();
                  // Trigger the reload handler
                  di<UserService>().saveCompleted.value++;
                },
          child: isSaving
              ? const Text('Saving...')
              : const Text('Save User (triggers reload)'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  di.registerSingleton<UserService>(UserService());
  di.registerSingleton<UserListService>(UserListService());

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: UserListWidget()),
    ),
  ));
}
