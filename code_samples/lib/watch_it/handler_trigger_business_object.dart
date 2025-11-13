import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

// Business object with command
class UserService {
  final saveUserCommand = Command.createAsyncNoParamNoResult(
    () async {
      await Future.delayed(const Duration(seconds: 1));
      print('User saved successfully');
    },
  );

  void dispose() {
    saveUserCommand.dispose();
  }
}

// Form manager that triggers save
class FormManager {
  final isValid = ValueNotifier<bool>(false);
  final onSubmitted = ValueNotifier<int>(0);

  void submit() {
    onSubmitted.value++; // Increment to trigger
  }

  void dispose() {
    isValid.dispose();
    onSubmitted.dispose();
  }
}

// #region example
class UserFormWidget extends WatchingWidget {
  const UserFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Handler triggers the save command on the business object
    registerHandler(
      select: (FormManager m) => m.onSubmitted,
      handler: (context, _, cancel) {
        // Call command on business object whenever triggered
        di<UserService>().saveUserCommand.execute();
      },
    );

    // Optionally watch the command state to show loading indicator
    final isSaving = watchValue(
      (UserService s) => s.saveUserCommand.isExecuting,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Your form fields here...
        const TextField(decoration: InputDecoration(labelText: 'Name')),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: isSaving
              ? null
              : () => di<FormManager>().submit(), // Trigger via manager
          child:
              isSaving ? const CircularProgressIndicator() : const Text('Save'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  di.registerSingleton<UserService>(UserService());
  di.registerSingleton<FormManager>(FormManager());

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: UserFormWidget()),
    ),
  ));
}
