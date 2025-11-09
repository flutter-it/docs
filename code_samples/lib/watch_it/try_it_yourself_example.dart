import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region manager
class MyManager {
  final message = ValueNotifier<String>('Hello');
}
// #endregion manager

// #region register
void setupMyManager() {
  di.registerSingleton<MyManager>(MyManager());
}
// #endregion register

// #region watch
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final message = watchValue((MyManager m) => m.message);
    return Text(message);
  }
}
// #endregion watch

// #region change
void changeMessage() {
  di<MyManager>().message.value = 'World!'; // Widget rebuilds!
}
// #endregion change

void main() {
  setupMyManager();
  runApp(MaterialApp(home: MyWidget()));
}
