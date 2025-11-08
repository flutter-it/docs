import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// Use WatchingStatefulWidget when you need both:
// - Local widget state (setState)
// - Reactive state management (watchValue, etc.)
class FilteredTodoListPage extends WatchingStatefulWidget {
  const FilteredTodoListPage({super.key});

  @override
  State<FilteredTodoListPage> createState() => _FilteredTodoListPageState();
}

class _FilteredTodoListPageState extends State<FilteredTodoListPage> {
  // Local state managed with setState
  bool _showCompletedOnly = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Reactive state from watch_it
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isExecuting);

    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.execute();
    });

    // Filter todos using local state
    final filteredTodos = todos.where((todo) {
      final matchesCompleted = !_showCompletedOnly || todo.completed;
      final matchesSearch = _searchQuery.isEmpty ||
          todo.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCompleted && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('WatchingStatefulWidget Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Update local state with setState
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          CheckboxListTile(
            title: const Text('Show Completed Only'),
            value: _showCompletedOnly,
            onChanged: (value) {
              // Update local state with setState
              setState(() {
                _showCompletedOnly = value ?? false;
              });
            },
          ),
          const Divider(),
          if (isLoading && todos.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: filteredTodos.isEmpty
                  ? const Center(child: Text('No matching todos'))
                  : ListView.builder(
                      itemCount: filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = filteredTodos[index];
                        return ListTile(
                          title: Text(todo.title),
                          subtitle: Text(todo.description),
                          leading: Checkbox(
                            value: todo.completed,
                            onChanged: (value) {},
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(const MaterialApp(
    home: FilteredTodoListPage(),
  ));
}
