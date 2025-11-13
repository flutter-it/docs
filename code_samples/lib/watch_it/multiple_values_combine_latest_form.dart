import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

// #region manager
class FormManager {
  final email = ValueNotifier<String>('');
  final password = ValueNotifier<String>('');

  // Combine email and password validation in the DATA LAYER
  late final isValid = email.combineLatest(
    password,
    (emailValue, passwordValue) {
      final emailValid = emailValue.contains('@') && emailValue.length > 3;
      final passwordValid = passwordValue.length >= 8;
      return emailValid && passwordValid;
    },
  );
}
// #endregion manager

// #region widget
class FormWidget extends WatchingWidget {
  const FormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = di<FormManager>();

    // Watch the COMBINED result - rebuilds only when validation state changes
    final isValid = watchValue((FormManager m) => m.isValid);

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (value) => manager.email.value = value,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          onChanged: (value) => manager.password.value = value,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isValid ? () {} : null,
          child: Text(isValid ? 'Submit' : 'Fill form correctly'),
        ),
      ],
    );
  }
}
// #endregion widget

void main() {
  di.registerSingleton<FormManager>(FormManager());
  runApp(MaterialApp(
      home: Scaffold(
          body: Padding(padding: EdgeInsets.all(16), child: FormWidget()))));
}
