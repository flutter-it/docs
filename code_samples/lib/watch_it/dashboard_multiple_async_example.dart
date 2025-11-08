import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class Dashboard extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final messages = watchStream(
      (MessageService s) => s.messageStream,
      initialValue: <Message>[],
    );

    final notifications = watchStream(
      (NotificationService s) => s.notificationStream,
      initialValue: 0,
    );

    return Column(
      children: [
        Text('Messages: ${messages.data?.length ?? 0}'),
        Text('Notifications: ${notifications.data}'),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: Dashboard()));
}
