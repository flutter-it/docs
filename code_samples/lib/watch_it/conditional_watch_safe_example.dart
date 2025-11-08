import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// ✓ SAFE: How to handle conditional logic while maintaining watch order

class SafeConditionalWatchWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final showDetails = createOnce(() => ValueNotifier(false));
    final show = watch(showDetails).value;

    // ✓ CORRECT: ALWAYS call all watch functions regardless of conditions
    // The ORDER stays the same every build!
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isExecuting);

    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.execute();
    });

    // Now use conditional logic AFTER all watch calls
    return Scaffold(
      appBar: AppBar(
        title: Text(show ? '✓ Details View' : '✓ Simple View'),
      ),
      body: show
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade100,
                  child: const Text(
                    '✓ SAFE: All watch calls happen in same order,\n'
                    'only UI changes conditionally',
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(todos[index].title),
                        subtitle: Text(todos[index].description),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    color: Colors.green.shade100,
                    child: const Text(
                      '✓ SAFE: Same watch calls every build',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  Text('Total Todos: ${todos.length}'),
                  const SizedBox(height: 8),
                  if (isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDetails.value = !show,
        child: Icon(show ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: SafeConditionalWatchWidget(),
  ));
}
