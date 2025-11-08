import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class DataLoaderWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watchFuture returns an AsyncSnapshot similar to FutureBuilder
    // Widget rebuilds when the future completes
    final snapshot = watchFuture(
      (_) async {
        final dataService = DataService(ApiClient());
        return await dataService.fetchTodos();
      },
      initialValue: const <TodoModel>[],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Future Example',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        if (snapshot.connectionState == ConnectionState.waiting)
          const CircularProgressIndicator()
        else if (snapshot.hasError)
          Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          )
        else if (snapshot.hasData)
          Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final todo = snapshot.data![index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                );
              },
            ),
          )
        else
          const Text('No data'),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: DataLoaderWidget(),
    ),
  ));
}
