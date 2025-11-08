import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue((DataManager m) => m.isLoading);
    final data = watchValue((DataManager m) => m.data);

    // Initialize data on first build
    callOnce((_) {
      di<DataManager>().fetchData();
    });

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return Text('Data: $data');
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: DataWidget()));
}
