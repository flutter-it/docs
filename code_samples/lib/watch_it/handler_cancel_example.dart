import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class WelcomeWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (DataManager m) => m.data,
      handler: (context, data, cancel) {
        if (data.isNotEmpty) {
          // Show welcome dialog once
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Welcome!'),
              content: Text('Data loaded: $data'),
            ),
          );
          cancel(); // Only show once
        }
      },
    );

    return Container();
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: WelcomeWidget()));
}
