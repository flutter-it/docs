import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class TodoListWidget extends StatelessWidget {
  final todos = ListNotifier<String>(data: []);

  TodoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: todos,
      builder: (context, items, _) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => todos.removeAt(index),
            ),
          ),
        );
      },
    );
  }
}
// #endregion example
