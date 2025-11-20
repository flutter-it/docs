import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class SearchManager {
  final api = ApiClient();

  // Command for text field changes
  late final searchTextCommand = Command.createSync<String, String>(
    (text) => text,
    initialValue: '',
  );

  // Command for actual search
  late final searchCommand = Command.createAsync<String, List<Todo>>(
    (query) async {
      await simulateDelay();
      // Simulate search
      return fakeTodos
          .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    },
    initialValue: [],
  );

  SearchManager() {
    // Debounce text changes before searching
    searchTextCommand.debounce(Duration(milliseconds: 500)).listen((text, _) {
      if (text.isNotEmpty) {
        searchCommand(text);
      }
    });
  }
}

class SearchWidget extends StatelessWidget {
  SearchWidget({super.key});

  final manager = SearchManager();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
            ),
            // Connect to search text command
            onChanged: manager.searchTextCommand.run,
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: manager.searchCommand.isRunning,
            builder: (context, isRunning, _) {
              if (isRunning) {
                return Center(child: CircularProgressIndicator());
              }

              return ValueListenableBuilder<List<Todo>>(
                valueListenable: manager.searchCommand,
                builder: (context, results, _) {
                  if (results.isEmpty) {
                    return Center(child: Text('No results'));
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final todo = results[index];
                      return ListTile(
                        title: Text(todo.title),
                        leading: Checkbox(
                          value: todo.completed,
                          onChanged: null,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: SearchWidget())));
}
