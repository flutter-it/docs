import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class DashboardWidget extends WatchingWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch different objects
    final count = watchValue((CounterManager m) => m.count);
    final userName = watchValue((SimpleUserManager m) => m.name);
    final isLoading = watchValue((DataManager m) => m.isLoading);

    return Column(
      children: [
        Text('Welcome, $userName!'),
        Text('Counter: $count'),
        if (isLoading) CircularProgressIndicator(),
      ],
    );
  }
}
// #endregion example

// #region builders
class DashboardWidgetWithBuilders extends StatelessWidget {
  const DashboardWidgetWithBuilders({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = di<CounterManager>();
    final userManager = di<SimpleUserManager>();
    final dataManager = di<DataManager>();

    return ValueListenableBuilder<int>(
      valueListenable: counter.count,
      builder: (context, count, _) {
        return ValueListenableBuilder<String>(
          valueListenable: userManager.name,
          builder: (context, userName, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: dataManager.isLoading,
              builder: (context, isLoading, _) {
                return Column(
                  children: [
                    Text('Welcome, $userName!'),
                    Text('Counter: $count'),
                    if (isLoading) CircularProgressIndicator(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
// #endregion builders

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: DashboardWidget()));
}
