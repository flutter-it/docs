import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CreateOnceAsyncWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // createOnceAsync creates an object asynchronously on first build
    // Returns an AsyncSnapshot similar to FutureBuilder
    // Perfect for loading resources, initializing async objects, etc.
    final dataServiceSnapshot = createOnceAsync(
      () async {
        // Simulate async initialization
        await Future.delayed(const Duration(seconds: 1));
        return DataService(ApiClient());
      },
      initialValue: null,
    );

    Widget child;
    if (dataServiceSnapshot.hasData) {
      final dataService = dataServiceSnapshot.data!;
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text('DataService initialized!'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final todos = await dataService.fetchTodos();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fetched ${todos.length} todos')),
                );
              }
            },
            child: const Text('Fetch Todos'),
          ),
        ],
      );
    } else if (dataServiceSnapshot.hasError) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${dataServiceSnapshot.error.toString()}'),
        ],
      );
    } else {
      child = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing DataService...'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('createOnceAsync Example')),
      body: Center(child: child),
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: CreateOnceAsyncWidget(),
  ));
}
