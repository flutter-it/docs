import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final snapshot = watchFuture(
      (DataService s) => s.fetchTodos(),
      initialValue: [],
    );

    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    return Text('Data: ${snapshot.data?.length} items');
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: DataWidget()));
}
