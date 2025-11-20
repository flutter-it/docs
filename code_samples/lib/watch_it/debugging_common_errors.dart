// ignore_for_file: unused_local_variable, unused_element, unreachable_from_main
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

final di = GetIt.instance;

// Simple classes for debugging examples
class Manager {
  final data = ValueNotifier<String>('');
}

typedef Todo = TodoModel;

// #region watch_outside_build_bad
// BAD
class WatchOutsideBuildBad extends WatchingWidget {
  WatchOutsideBuildBad() {
    final data = watchValue((Manager m) => m.data); // Wrong context!
  }

  void onPressed() {
    final data = watchValue((Manager m) => m.data); // Wrong!
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
// #endregion watch_outside_build_bad

// #region watch_outside_build_good
// GOOD
class WatchOutsideBuildGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Manager m) => m.data); // Correct!

    return ElevatedButton(
      onPressed: () {
        doSomething(data); // Use the value
      },
      child: Text('$data'),
    );
  }
}

void doSomething(String data) {}
// #endregion watch_outside_build_good

// #region not_listenable_bad
// BAD
class TodoManagerNotListenable {
  // Not a Listenable!
  final todos = ValueNotifier<List<Todo>>([]);
}

class NotListenableBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: type_argument_not_matching_bounds
    final manager = watchIt<TodoManagerNotListenable>(); // ERROR!
    return Container();
  }
}
// #endregion not_listenable_bad

// #region not_listenable_good_watch_value
// GOOD
class NotListenableGoodWatchValue extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManagerNotListenable m) => m.todos);
    return Container();
  }
}
// #endregion not_listenable_good_watch_value

// #region not_listenable_good_change_notifier
// Also GOOD
class TodoManagerListenable extends ChangeNotifier {
  List<Todo> _todos = [];

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners(); // Now it's a Listenable
  }
}

class NotListenableGoodChangeNotifier extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final manager = watchIt<TodoManagerListenable>(); // Works now!
    return Container();
  }
}
// #endregion not_listenable_good_change_notifier

// #region not_registered_solution
void main() {
  // Register BEFORE runApp
  di.registerSingleton<TodoManager>(TodoManager(DataService(ApiClient())));

  runApp(MyApp());
}
// #endregion not_registered_solution

// #region not_watching_bad
class NotWatchingBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // BAD - Not watching, just accessing
    final manager = di<TodoManager>();
    final todos = manager.todos.value; // No watch!
    return Container();
  }
}
// #endregion not_watching_bad

// #region not_watching_good
class NotWatchingGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // GOOD - Actually watching
    final todos = watchValue((TodoManager m) => m.todos);
    return Container();
  }
}
// #endregion not_watching_good

// #region not_notifying_bad
// BAD - Changing value without notifying
class TodoManagerNotNotifying {
  final todos = ValueNotifier<List<Todo>>([]);

  void addTodo(Todo todo) {
    todos.value.add(todo); // Modifies list but doesn't notify!
  }
}
// #endregion not_notifying_bad

// #region not_notifying_good_list_notifier
// GOOD - ListNotifier automatically notifies on mutations
class TodoManagerListNotifier {
  final todos = ListNotifier<Todo>(data: []);

  void addTodo(Todo todo) {
    todos.add(todo); // Automatically notifies listeners!
  }
}
// #endregion not_notifying_good_list_notifier

// #region not_notifying_good_custom_notifier
// GOOD - Extend ValueNotifier and call notifyListeners
class TodoManagerCustomNotifier extends ValueNotifier<List<Todo>> {
  TodoManagerCustomNotifier() : super([]);

  void addTodo(Todo todo) {
    value.add(todo);
    notifyListeners(); // Manually trigger notification
  }
}
// #endregion not_notifying_good_custom_notifier

// #region memory_leak_bad
// BAD - Manual subscriptions leak
class MemoryLeakBad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final manager = di<Manager>();
    manager.data.addListener(() {
      // This leaks! No cleanup
    });
    return Container();
  }
}
// #endregion memory_leak_bad

// #region memory_leak_good
// GOOD - Automatic cleanup
class MemoryLeakGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Manager m) => m.data);
    return Text('$data');
  }
}
// #endregion memory_leak_good

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}
