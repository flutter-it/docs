import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

class UserDataService {
  final currentUser = ValueNotifier<UserModel?>(null);

  Future<void> loadUser() async {
    await Future.delayed(const Duration(seconds: 1));
    currentUser.value = UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
    );
  }

  void dispose() {
    currentUser.dispose();
  }
}

// #region example
class UserWidget extends WatchingWidget {
  const UserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger data loading once on first build
    callOnce((context) => di<UserDataService>().loadUser());

    // Watch and display the loaded data
    final user = watchValue((UserDataService s) => s.currentUser);

    return Text(user?.name ?? 'Loading...');
  }
}
// #endregion example

void main() {
  di.registerSingleton<UserDataService>(UserDataService());

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: UserWidget()),
    ),
  ));
}
