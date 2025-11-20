// ignore_for_file: unused_local_variable, unused_element, avoid_print
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

final di = GetIt.instance;

// #region track_rebuild_frequency
class TrackRebuildFrequency extends WatchingWidget {
  static int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    _buildCount++;
    print('MyWidget rebuilt $_buildCount times');

    return Text('Todo count: ${todos.length}');
  }
}
// #endregion track_rebuild_frequency

// #region isolate_problem
class IsolateProblem extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Minimal example - just the watch and rebuild
    final value = watchValue((CounterManager m) => m.count);

    print('Rebuild with value: $value');

    return Text('Value: $value');
  }
}
// #endregion isolate_problem

// #region measure_rebuild_cost
class MeasureRebuildCost extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final start = DateTime.now();

    final todos = watchValue((TodoManager m) => m.todos);
    final user = watchValue((UserManager m) => m.currentUser);
    final settings = watchIt<SettingsModel>();

    // ... expensive widget tree ...

    final elapsed = DateTime.now().difference(start);
    print('Build took: ${elapsed.inMilliseconds}ms');

    return Column(
      children: [
        Text('Todos: ${todos.length}'),
        Text('User: ${user?.name ?? "None"}'),
        Text('Dark mode: ${settings.darkMode}'),
      ],
    );
  }
}
// #endregion measure_rebuild_cost
