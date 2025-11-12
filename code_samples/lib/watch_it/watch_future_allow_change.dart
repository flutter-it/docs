import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class DataWidget extends WatchingWidget {
  const DataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Create retry counter
    final retryCount = createOnce(() => ValueNotifier<int>(0));

    // Watch the future - future changes when retryCount changes
    final snapshot = watchFuture(
      (DataService s) => s.fetchTodos(),
      initialValue: null,
      allowFutureChange: true, // Allow new future on retry
    );

    return Column(
      children: [
        if (snapshot.data == null && !snapshot.hasError)
          CircularProgressIndicator()
        else if (snapshot.hasError)
          Column(
            children: [
              Text('Error: ${snapshot.error}'),
              ElevatedButton(
                // Trigger new future by changing retryCount
                onPressed: () => retryCount.value++,
                child: Text('Retry'),
              ),
            ],
          )
        else
          Text('Loaded ${snapshot.data!.length} items'),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: DataWidget()));
}
