// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
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
