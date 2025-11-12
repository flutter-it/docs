import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class MessageWidget extends WatchingWidget {
  const MessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final snapshot = watchStream(
      (ChatService s) => s.messageStream,
      initialValue: 'Waiting for messages...',
    );

    // No null check needed! snapshot.data always has a value
    // It starts with initialValue and updates with stream events
    return Column(
      children: [
        Text(snapshot.data!), // Safe to use ! because data is never null
        if (snapshot.connectionState == ConnectionState.waiting)
          Text('(connecting...)', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: MessageWidget()));
}
