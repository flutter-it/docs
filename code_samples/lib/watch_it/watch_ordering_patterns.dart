// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, unused_element, dead_code
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;

// Helper classes for examples
class Item {
  final String id;
  final String name;
  Item(this.id, this.name);
}

class Manager {
  final items = ValueNotifier<List<Item>>([
    Item('1', 'Apple'),
    Item('2', 'Banana'),
    Item('3', 'Cherry'),
  ]);

  final data = ValueNotifier<String>('Sample data');
  final isLoading = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);
}

// #region watch_inside_loops_wrong
// ❌ WRONG - order changes based on list length
class WatchInsideLoopsWrong extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final items = <Item>[Item('1', 'Apple'), Item('2', 'Banana')];
    final widgets = <Widget>[];

    for (final item in items) {
      // DON'T DO THIS - number of watch calls changes with list length
      final data = watchValue((Manager m) => m.data);
      widgets.add(Text(data));
    }
    return Column(children: widgets);
  }
}
// #endregion watch_inside_loops_wrong

// #region watch_after_early_return_wrong
// ❌ WRONG - some watches skipped
class WatchAfterEarlyReturnWrong extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue((Manager m) => m.isLoading);

    if (isLoading) {
      return CircularProgressIndicator(); // Returns early!
    }

    // This watch only happens sometimes - WRONG!
    final data = watchValue((Manager m) => m.data);
    return Text(data);
  }
}
// #endregion watch_after_early_return_wrong

// #region watch_in_callbacks_wrong
// ❌ WRONG - watch in button callback
class WatchInCallbacksWrong extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // DON'T DO THIS - watch calls must be in build(), not callbacks
        final data = watchValue((Manager m) => m.data); // Error!
        print(data);
      },
      child: Text('Press'),
    );
  }
}
// #endregion watch_in_callbacks_wrong

// #region safe_pattern_conditional
// ✓ CORRECT - All watches before conditionals
class SafePatternConditional extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch everything first
    final data = watchValue((Manager m) => m.data);
    final isLoading = watchValue((Manager m) => m.isLoading);
    final error = watchValue((Manager m) => m.error);

    // Then use conditionals
    if (error != null) {
      return ErrorWidget(error);
    }

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return Text(data);
  }
}
// #endregion safe_pattern_conditional

// #region safe_pattern_list_iteration
// ✓ CORRECT - Watch list, then iterate over values
class SafePatternListIteration extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch the list once
    final items = watchValue((Manager m) => m.items);

    // Iterate over values (not watch calls)
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index]; // No watch here!
        return ListTile(title: Text(item.name));
      },
    );
  }
}
// #endregion safe_pattern_list_iteration

void main() {}
