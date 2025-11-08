import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// watch_it works perfectly with generic widgets
// You can create reusable reactive components with type parameters

class DataDisplay<T> extends StatelessWidget with WatchItMixin {
  const DataDisplay({
    super.key,
    required this.select,
    required this.builder,
  });

  final T Function(BuildContext) select;
  final Widget Function(BuildContext, T) builder;

  @override
  Widget build(BuildContext context) {
    final data = select(context);
    return builder(context, data);
  }
}

// Generic reactive list widget
class ReactiveList<TItem> extends StatelessWidget with WatchItMixin {
  const ReactiveList({
    super.key,
    required this.items,
    required this.itemBuilder,
  });

  final List<TItem> items;
  final Widget Function(BuildContext, TItem, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No items'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}

class GenericWidgetExample extends StatelessWidget with WatchItMixin {
  const GenericWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Generic Widget Integration')),
      body: Column(
        children: [
          // Generic DataDisplay widget
          DataDisplay<bool>(
            select: (_) =>
                watchValue((TodoManager m) => m.fetchTodosCommand.isExecuting),
            builder: (context, isLoading) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: isLoading ? Colors.blue.shade100 : Colors.transparent,
                child: isLoading
                    ? const Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Loading...'),
                        ],
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
          // Generic ReactiveList widget
          Expanded(
            child: ReactiveList<TodoModel>(
              items: watchValue((TodoManager m) => m.todos),
              itemBuilder: (context, todo, index) {
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  trailing: Checkbox(
                    value: todo.completed,
                    onChanged: (value) {
                      final updated = todo.copyWith(completed: value ?? false);
                      di<TodoManager>().updateTodoCommand.execute(updated);
                    },
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
    home: GenericWidgetExample(),
  ));
}
