// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, unused_element, dead_code, invalid_use_of_visible_for_testing_member, unused_field, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

final di = GetIt.instance;

// Mock class for examples
class Todo {
  final String id;
  final String title;
  final bool completed;
  final int priority;
  Todo(
      {required this.id,
      required this.title,
      this.completed = false,
      this.priority = 1});
}

class Item {
  final String name;
  Item(this.name);
}

// #region logic_in_widget_bad
// ❌ Bad - Logic in widget
class LogicInWidgetBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Using the local Todo class which has priority field
    final todos = <Todo>[
      Todo(id: '1', title: 'Task 1', priority: 3),
      Todo(id: '2', title: 'Task 2', priority: 1),
    ];

    // BAD: Business logic in widget
    final filteredTodos = todos.where((todo) {
      if (DateTime.now().hour > 17) {
        return todo.priority > 2;
      }
      return true;
    }).toList();

    return ListView.builder(
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) => Text(filteredTodos[index].title),
    );
  }
}
// #endregion logic_in_widget_bad

// #region logic_in_manager_good_manager
// In TodoManager
class TodoManagerWithFiltering {
  final todos = ValueNotifier<List<Todo>>([]);

  // Business logic HERE
  ValueListenable<List<Todo>> get filteredTodos => todos.map((list) => list
      .where((todo) => DateTime.now().hour > 17 ? todo.priority > 2 : true)
      .toList());
}
// #endregion logic_in_manager_good_manager

// #region logic_in_manager_good_widget
// In widget - just display
class LogicInManagerGoodWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue<TodoManagerWithFiltering, List<Todo>>(
        (m) => m.filteredTodos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion logic_in_manager_good_widget

// #region passing_managers_bad
// ❌ Bad - Passing managers as parameters
class PassingManagersBad extends WatchingWidget {
  PassingManagersBad({required this.manager}); // DON'T DO THIS
  final TodoManager manager;

  @override
  Widget build(BuildContext context) {
    final todos = watch(manager.todos).value;
    return ListView(children: todos.map((t) => Text(t.title)).toList());
  }
}
// #endregion passing_managers_bad

// #region access_directly_good
// ✅ Good - Access directly
class AccessDirectlyGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView(children: todos.map((t) => Text(t.title)).toList());
  }
}
// #endregion access_directly_good

// #region local_ui_state
// Local UI state
class ExpandableCard extends WatchingStatefulWidget {
  State createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _expanded = false; // Local UI state

  @override
  Widget build(BuildContext context) {
    // Business state from watch_it
    final data = watchValue((DataManager m) => m.data);

    return ExpansionTile(
      initiallyExpanded: _expanded,
      onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
      title: Text(data),
      children: [Text('Details')],
    );
  }
}
// #endregion local_ui_state

// #region business_state
// In manager - registered in get_it
class DataManagerExample {
  final data = ValueNotifier<List<Item>>([]);

  void fetchData() async {
    // Simulated API call
    await Future.delayed(Duration(milliseconds: 100));
    data.value = [Item('Example 1'), Item('Example 2')];
  }
}
// #endregion business_state

// #region watching_too_much_bad
// ❌ Bad - Watching too much
class WatchingTooMuchBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final manager = watchIt<CounterModel>(); // Rebuilds on ANY change
    final count = manager.count;
    return Container();
  }
}
// #endregion watching_too_much_bad

// #region watch_specific_good
// ✅ Good - Watch specific property
class WatchSpecificGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue(
        (TodoManager m) => m.todos); // Only rebuilds when todos change
    return Container();
  }
}
// #endregion watch_specific_good

// #region rebuilds_on_every_settings_bad
// ❌ Bad - Rebuilds on every settings change
class RebuildsOnEverySettingsBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final settings = watchIt<SettingsModel>();
    final darkMode =
        settings.darkMode; // Rebuilds even when other settings change
    return Container();
  }
}
// #endregion rebuilds_on_every_settings_bad

// #region rebuilds_only_darkmode_good
// ✅ Good - Rebuilds only when darkMode changes
class RebuildsOnlyDarkModeGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final darkMode = watchPropertyValue((SettingsModel s) => s.darkMode);
    return Container();
  }
}
// #endregion rebuilds_only_darkmode_good

// #region one_widget_watches_everything_bad
// ❌ Bad - One widget watches everything
class OneWidgetWatchesEverythingBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final user = watchValue((UserManager m) => m.currentUser);
    final todos = watchValue((TodoManager m) => m.todos);
    final settings = watchPropertyValue((SettingsModel m) => m.darkMode);

    return Column(
      children: [
        // When ANYTHING changes, ENTIRE dashboard rebuilds
        Text(user?.name ?? ''),
        Text('${todos.length} todos'),
        Text('Dark mode: $settings'),
      ],
    );
  }
}
// #endregion one_widget_watches_everything_bad

// #region split_widgets_good_dashboard
class SplitWidgetsGoodDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserHeader(), // Only rebuilds when user changes
        TodoListHeader(), // Only rebuilds when todos change
        SettingsPanelHeader(), // Only rebuilds when settings change
      ],
    );
  }
}
// #endregion split_widgets_good_dashboard

// #region split_widgets_good_user_header
class UserHeader extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final user = watchValue((UserManager m) => m.currentUser);
    return Text(user?.name ?? 'Not logged in');
  }
}
// #endregion split_widgets_good_user_header

// #region split_widgets_good_todo_list
class TodoListHeader extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return Text('${todos.length} todos');
  }
}
// #endregion split_widgets_good_todo_list

// #region split_widgets_good_settings_panel
class SettingsPanelHeader extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);
    return Text('Dark mode: $darkMode');
  }
}
// #endregion split_widgets_good_settings_panel

// #region const_constructors
// Const constructors
class TodoCard extends StatelessWidget with WatchItMixin {
  const TodoCard({super.key, required this.todoId}); // const!
  final String todoId;

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    final todo = todos.firstWhere((t) => t.id == todoId);
    return Card(child: Text(todo.title));
  }
}
// #endregion const_constructors

// #region computing_in_widget_bad
// ❌ Bad - Computing in widget
class ComputingInWidgetBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    // Recomputes on EVERY rebuild
    final completedCount = todos.where((t) => t.completed).length;
    final pendingCount = todos.length - completedCount;

    return Text('$completedCount / $pendingCount');
  }
}
// #endregion computing_in_widget_bad

// #region computed_in_manager_good_manager
// ✅ Good - Computed in manager
class TodoManagerWithComputed {
  final todos = ValueNotifier<List<Todo>>([]);

  // Cached computation
  ValueListenable<int> get completedCount =>
      todos.map((list) => list.where((t) => t.completed).length);

  ValueListenable<int> get pendingCount => todos.map((list) => list.length);
}
// #endregion computed_in_manager_good_manager

// #region computed_in_manager_good_widget
class ComputedInManagerGoodWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final manager = di<TodoManagerWithComputed>();
    final completed = watch(manager.completedCount).value;
    final pending = watch(manager.pendingCount).value;

    return Text('$completed / $pending');
  }
}
// #endregion computed_in_manager_good_widget

// NOTE: Test examples are not extracted - they belong in test files

// #region manager_service_structure
// Manager/Service structure
class TodoManagerStructure {
  // ValueNotifiers for reactive state
  final todos = ValueNotifier<List<Todo>>([]);
  final isLoading = ValueNotifier<bool>(false);

  // Commands for async operations
  late final fetchCommand = Command.createAsyncNoParam(
    _fetchTodos,
    initialValue: <Todo>[],
  );

  late final createCommand = Command.createAsync<String, Todo?>(
    _createTodo,
    initialValue: null,
  );

  // Private implementation
  Future<List<Todo>> _fetchTodos() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(milliseconds: 100));
      final result = <Todo>[];
      todos.value = result;
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Todo?> _createTodo(String title) async {
    await Future.delayed(Duration(milliseconds: 100));
    final todo = Todo(id: '1', title: title);
    todos.value = [...todos.value, todo];
    return todo;
  }

  // Cleanup
  void dispose() {
    todos.dispose();
    isLoading.dispose();
  }
}
// #endregion manager_service_structure

// #region widget_structure
// Widget structure
class TodoListStructure extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // 1. One-time initialization
    callOnce((_) {
      di<TodoManagerStructure>().fetchCommand.run();
    });

    // 2. Register handlers
    registerHandler(
      select: (TodoManagerStructure m) => m.createCommand,
      handler: _onTodoCreated,
    );

    // 3. Watch reactive state
    final todos = watchValue((TodoManagerStructure m) => m.todos);
    final isLoading = watchValue((TodoManagerStructure m) => m.isLoading);

    // 4. Build UI
    if (isLoading) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }

  void _onTodoCreated(
      BuildContext context, Todo? value, void Function() cancel) {
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo created!')),
      );
    }
  }
}
// #endregion widget_structure

// #region master_detail_navigation
// Master-detail navigation
class MasterDetailNavigation extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    registerHandler(
      select: (TodoManager m) => m.selectedTodo,
      handler: (context, todo, cancel) {
        if (todo != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(body: Text(todo.title)),
            ),
          );
        }
      },
    );

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          onTap: () {
            di<TodoManager>().selectTodo(todo);
          },
        );
      },
    );
  }
}
// #endregion master_detail_navigation

// #region pull_to_refresh_pattern
// Pull-to-refresh
class PullToRefreshPattern extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    return RefreshIndicator(
      onRefresh: () async {
        final manager = di<TodoManager>();
        manager.fetchTodosCommand.run();
        await manager.fetchTodosCommand.runAsync();
      },
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) => Text(todos[index].title),
      ),
    );
  }
}
// #endregion pull_to_refresh_pattern

// #region search_filter_pattern
// Search/filter
class SearchFilterPattern extends WatchingStatefulWidget {
  State createState() => _SearchFilterPatternState();
}

class _SearchFilterPatternState extends State<SearchFilterPattern> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = watchValue((DataManagerExample m) => m.data);

    final filtered = items
        .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(hintText: 'Search...'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => Text(filtered[index].name),
          ),
        ),
      ],
    );
  }
}
// #endregion search_filter_pattern

// Mock command for pagination
class Manager {
  final items = ValueNotifier<List<Item>>([]);
  late final loadMoreCommand = Command.createAsyncNoParam(
    () async {},
    initialValue: null,
  );
}

// #region pagination_pattern
// Pagination
class PaginationPattern extends WatchingStatefulWidget {
  State createState() => _PaginationPatternState();
}

class _PaginationPatternState extends State<PaginationPattern> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      di<Manager>().loadMoreCommand.run();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = watchValue((Manager m) => m.items);
    final isLoadingMore =
        watchValue((Manager m) => m.loadMoreCommand.isRunning);

    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Center(child: CircularProgressIndicator());
        }
        return ListTile(title: Text(items[index].name));
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
// #endregion pagination_pattern

// #region dont_access_getit_constructors_bad
// ❌ BAD - Accessing get_it in constructor
class DontAccessGetItConstructorsBad extends WatchingWidget {
  DontAccessGetItConstructorsBad() {
    // DON'T DO THIS - constructor runs before widget is attached to tree
    di<Manager>().loadMoreCommand.run(); // Will fail or cause issues
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
// #endregion dont_access_getit_constructors_bad

// #region dont_access_getit_constructors_good
// ✅ GOOD - Use callOnce
class DontAccessGetItConstructorsGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((_) {
      di<Manager>().loadMoreCommand.run(); // Do this instead
    });
    return Container();
  }
}
// #endregion dont_access_getit_constructors_good

// #region dont_violate_ordering_bad
// ❌ Don't violate watch ordering rules
class DontViolateOrderingBad extends WatchingWidget {
  final bool showDetails;
  DontViolateOrderingBad(this.showDetails);

  @override
  Widget build(BuildContext context) {
    // BAD - conditional watch calls
    if (showDetails) {
      final details = watchValue((DataManager m) => m.data); // Order changes!
    }
    return Container();
  }
}
// #endregion dont_violate_ordering_bad

// #region dont_await_execute_bad_anti
// ❌ Don't await commands - BAD
class DontAwaitExecuteBadAnti extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await di<TodoManager>().createTodoCommand.runAsync(
            CreateTodoParams(title: 'New', description: '')); // Blocks UI!
      },
      child: Text('Submit'),
    );
  }
}
// #endregion dont_await_execute_bad_anti

// #region dont_await_execute_good_anti
// ✅ Don't await commands - GOOD
class DontAwaitExecuteGoodAnti extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => di<TodoManager>().createTodoCommand.run(CreateTodoParams(
          title: 'New', description: '')), // Returns immediately
      child: Text('Submit'),
    );
  }
}
// #endregion dont_await_execute_good_anti

// #region enable_tracing
// Enable watch_it tracing
// Note: Tracing configuration is done via GetIt configuration
// See watch_it documentation for current tracing options
void enableTracingExample() {
  // Tracing can be enabled through GetIt configuration
  // Example placeholder - actual API may vary
}
// #endregion enable_tracing

// #region log_watch_calls
// Log watch calls with manual logging
class LogWatchCalls extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    // You can add manual logging for debugging
    // print('Watching TodoList.todos: ${todos.length} items');
    return Container();
  }
}
// #endregion log_watch_calls

// #region check_rebuild_frequency
// Check rebuild frequency
class CheckRebuildFrequency extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    print('TodoList rebuild at ${DateTime.now()}'); // Track rebuilds

    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion check_rebuild_frequency

void main() {}
