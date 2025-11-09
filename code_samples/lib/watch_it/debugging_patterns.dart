// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, unused_element, dead_code
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

final di = GetIt.instance;

// NOTE: This file contains GOOD debugging examples only.
// BAD examples that demonstrate errors are left inline in the documentation.

// #region track_rebuild_frequency
class TrackRebuildFrequency extends WatchingWidget {
  static int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    print('TodoList rebuild #${++_buildCount} at ${DateTime.now()}');

    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion track_rebuild_frequency

// #region isolate_problem
// Minimal test widget
class IsolateProblemDebugWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    print('DebugWidget.build()');

    final data = watchValue((DataManager m) => m.data);
    print('Data value: $data');

    return Text('Data: $data');
  }
}
// #endregion isolate_problem

// #region measure_rebuild_cost
class MeasureRebuildCost extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();

    final data = watchValue((DataManager m) => m.data);
    // ... build UI

    stopwatch.stop();
    print('ExpensiveWidget.build() took ${stopwatch.elapsedMicroseconds}μs');

    return Text(data);
  }
}
// #endregion measure_rebuild_cost

// #region profile_memory
class MemoryProfiler {
  static void logCurrentUsage(String label) {
    // In real app, use dart:developer
    print('[$label] Memory check');
  }
}

class ProfileMemoryWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    MemoryProfiler.logCurrentUsage('TodoList.build');

    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion profile_memory

// #region find_excessive_watch_calls
class FindExcessiveWatchCalls extends WatchingWidget {
  static final _watchCalls = <String, int>{};

  T _profiledWatch<T>(String label, T Function() fn) {
    _watchCalls[label] = (_watchCalls[label] ?? 0) + 1;
    if (_watchCalls[label]! % 100 == 0) {
      print('$label called ${_watchCalls[label]} times');
    }
    return fn();
  }

  @override
  Widget build(BuildContext context) {
    final todos = _profiledWatch(
      'todos',
      () => watchValue((TodoManager m) => m.todos),
    );

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion find_excessive_watch_calls

// #region custom_watch_wrapper_logging
extension WatchDebug on WatchingWidget {
  T debugWatch<T>(
    String label,
    T Function() watchFn,
  ) {
    print('[WATCH] $label - subscribing');
    final result = watchFn();
    print('[WATCH] $label - value: $result');
    return result;
  }
}

class CustomWatchWrapperWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = debugWatch(
      'todos',
      () => watchValue((TodoManager m) => m.todos),
    );

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion custom_watch_wrapper_logging

// #region conditional_tracing
class ConditionalTracingWidget extends WatchingWidget {
  final bool enableTracing;

  ConditionalTracingWidget({this.enableTracing = false});

  @override
  Widget build(BuildContext context) {
    if (enableTracing) {
      print('Building $runtimeType');
    }

    final data = watchValue((DataManager m) => m.data);

    if (enableTracing) {
      print('Data value: $data');
    }

    return Text('$data');
  }
}
// #endregion conditional_tracing

// #region detect_watch_ordering_violations
class StrictWatchingWidget extends WatchingWidget {
  final _watchLabels = <String>[];

  T _strictWatch<T>(String label, T Function() fn) {
    if (_watchLabels.contains(label)) {
      throw StateError('Duplicate watch call: $label');
    }
    _watchLabels.add(label);
    return fn();
  }

  // Use in subclasses:
  // final todos = _strictWatch('todos', () => watchValue(...));
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
// #endregion detect_watch_ordering_violations

void main() {}
