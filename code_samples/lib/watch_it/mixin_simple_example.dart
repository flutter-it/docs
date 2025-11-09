import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class MyWidget extends StatelessWidget with WatchItMixin {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final data = watchValue((DataManager m) => m.data);
    return Text('$data');
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: MyWidget()));
}
