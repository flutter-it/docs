import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Access service from anywhere - no BuildContext needed!
        await getIt<AuthService>().login('user@example.com', 'password');
      },
      child: Text('Login'),
    );
  }
}

void main() {
  const username = "user@example.com";
  const password = "password123";
}
// #endregion example
