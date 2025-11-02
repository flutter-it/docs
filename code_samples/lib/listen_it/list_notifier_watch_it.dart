import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

// #region example
class TodoListWidget extends WatchingWidget {
  const TodoListWidget(this.todos, {super.key});

  final ListNotifier<String> todos;

  @override
  Widget build(BuildContext context) {
    // watch() automatically rebuilds when the list changes
    final items = watch(todos).value;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(items[index]),
      ),
    );
  }
}
// #endregion example
