import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class SearchableList extends WatchingStatefulWidget {
  @override
  State createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  String _query = ''; // Local state

  @override
  Widget build(BuildContext context) {
    // Reactive state - automatically rebuilds
    final items = watchValue((TodoManager m) => m.todos);

    // Filter using local state
    final filtered =
        items.where((item) => item.title.contains(_query)).toList();

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => Text(filtered[index].title),
          ),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: SearchableList()));
}
