import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

class BackendService {
  Future<String> fetchUserData() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'User: John Doe';
  }
}

// #region example
class UserDataWidget extends WatchingWidget {
  const UserDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch data once on first build
    final snapshot = createOnceAsync(
      () => di<BackendService>().fetchUserData(),
      initialValue: '',
    );

    // Display based on AsyncSnapshot state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    return Text(snapshot.data ?? 'No data');
  }
}
// #endregion example

void main() {
  di.registerSingleton<BackendService>(BackendService());

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: UserDataWidget()),
    ),
  ));
}
