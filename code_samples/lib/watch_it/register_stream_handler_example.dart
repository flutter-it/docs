import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class EventListenerWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    // registerStreamHandler listens to a stream and executes a handler
    // for each event. Perfect for event buses, web socket messages, etc.
    registerStreamHandler<Stream<TodoCreatedEvent>, TodoCreatedEvent>(
      target: di<EventBus>().on<TodoCreatedEvent>(),
      handler: (context, snapshot, _) {
        if (snapshot.hasData) {
          final event = snapshot.data!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('New todo created: ${event.todo.title}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );

    // Listen to delete events
    registerStreamHandler<Stream<TodoDeletedEvent>, TodoDeletedEvent>(
      target: di<EventBus>().on<TodoDeletedEvent>(),
      handler: (context, snapshot, _) {
        if (snapshot.hasData) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todo deleted'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Event Listener')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This widget listens to todo events via stream handlers',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('No todos'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.description),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Simulate creating a todo and firing an event
                final newTodo = TodoModel(
                  id: DateTime.now().toString(),
                  title: 'Test Todo ${todos.length + 1}',
                  description: 'Created at ${DateTime.now()}',
                );
                di<EventBus>().fire(TodoCreatedEvent(newTodo));
              },
              child: const Text('Fire Create Event'),
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

  runApp(MaterialApp(
    home: EventListenerWidget(),
  ));
}
