import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class UserActivity extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final snapshot = watchStream(
      (UserService s) => s.activityStream,
      initialValue: 'No activity',
    );

    // Check state like StreamBuilder
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    return Text('Activity: ${snapshot.data}');
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: UserActivity()));
}
