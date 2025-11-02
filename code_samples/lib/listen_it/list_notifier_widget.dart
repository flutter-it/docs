import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class TodoListWidget extends StatelessWidget {
  const TodoListWidget(this.todos, {super.key});

  final ListNotifier<String> todos;

  @override
  Widget build(BuildContext context) {
    // ListNotifier's value type is List<String>, not ListNotifier<String>
    return ValueListenableBuilder<List<String>>(
      valueListenable: todos,
      builder: (context, items, _) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index]),
          ),
        );
      },
    );
  }
}
// #endregion example
