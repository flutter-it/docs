import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class MessageWidget extends WatchingWidget {
  const MessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream<String> - non-nullable type
    final snapshot = watchStream(
      (ChatService s) => s.messageStream,
      initialValue: 'Waiting for messages...',
    );

    // Safe to use ! because:
    // 1. We provided a non-null initialValue
    // 2. Stream type is non-nullable (String, not String?)
    return Column(
      children: [
        Text(snapshot.data!),
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
