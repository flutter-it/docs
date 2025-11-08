import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class ChatWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // One line instead of StreamBuilder!
    final snapshot = watchStream(
      (ChatService s) => s.messageStream,
      initialValue: 'Waiting for messages...',
    );

    return Text(snapshot.data ?? 'No data');
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: ChatWidget()));
}
