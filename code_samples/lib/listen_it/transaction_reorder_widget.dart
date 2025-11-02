import '_shared/stubs.dart';

// #region example
class TodoListWidget extends StatefulWidget {
  final ListNotifier<Todo> todos;

  const TodoListWidget(this.todos, {super.key});

  @override
  State<TodoListWidget> createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {
  void _onReorder(int oldIndex, int newIndex) {
    widget.todos.startTransAction();

    final todo = widget.todos.removeAt(oldIndex);
    widget.todos.insert(newIndex, todo);

    widget.todos.endTransAction(); // Single notification for the reorder
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: _onReorder,
      children: <Widget>[
        for (var todo in widget.todos) TodoTile(todo),
      ],
    );
  }
}
// #endregion example
