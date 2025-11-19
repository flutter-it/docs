// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, unused_element, dead_code, invalid_use_of_visible_for_testing_member
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

final di = GetIt.instance;

// #region dont_await_execute_good
// ✓ GOOD - Non-blocking, UI stays responsive
class DontAwaitExecuteGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => di<TodoManager>().createTodoCommand.run(
            CreateTodoParams(title: 'New todo', description: 'Description'),
          ),
      child: Text('Submit'),
    );
  }
}
// #endregion dont_await_execute_good

// #region dont_await_execute_bad
// ❌ BAD - Blocks UI thread
class DontAwaitExecuteBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await di<TodoManager>().createTodoCommand.runAsync(
              CreateTodoParams(title: 'New todo', description: 'Description'),
            );
      },
      child: Text('Submit'),
    );
  }
}
// #endregion dont_await_execute_bad

// Helper command for examples
class Command {
  final isRunning = ValueNotifier<bool>(false);
  final errors = ValueNotifier<String?>(null);
  final value = ValueNotifier<String?>(null);

  void run() {}
  Future<void> runAsync() async {}
}

// #region watch_execution_state_good
// ✓ GOOD - Watch isRunning
class WatchExecutionStateGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final command = createOnce(() => Command());
    final isLoading = watch(command.isRunning).value;

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return Container();
  }
}
// #endregion watch_execution_state_good

// #region handle_errors_good_watch
// ✓ GOOD - Watch errors and display them
class HandleErrorsGoodWatch extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final command = createOnce(() => Command());
    final error = watch(command.errors).value;

    if (error != null) {
      return Text('Error: $error');
    }

    return Container();
  }
}
// #endregion handle_errors_good_watch

// #region handle_errors_good_handler
// ✓ ALSO GOOD - Use handler for error dialog
class HandleErrorsGoodHandler extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand.errors,
      handler: (context, error, _) {
        if (error != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Error'),
              content: Text('$error'),
            ),
          );
        }
      },
    );
    return Container();
  }
}
// #endregion handle_errors_good_handler

// #region initial_load_pattern
// Show spinner only when no data yet
class InitialLoadPattern extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isRunning);
    final data = watchValue((TodoManager m) => m.fetchTodosCommand);

    // Show spinner only when no data yet
    if (isLoading && data.isEmpty) {
      return const CircularProgressIndicator();
    }

    // Show data even while refreshing
    return ListView(
      children: [
        if (isLoading) const LinearProgressIndicator(), // Subtle indicator
        ...data.map((item) => ListTile(title: Text(item.title))),
      ],
    );
  }
}
// #endregion initial_load_pattern

// Helper class for form example
class FormData {
  final String title;
  FormData(this.title);
}

class Manager {
  final submitCommand = Command();
}

// Form submission pattern
class FormSubmissionPattern extends WatchingWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final formData = FormData('Example');

  // #region form_submission_pattern
  @override
  Widget build(BuildContext context) {
    final isSubmitting = watchValue((Manager m) => m.submitCommand.isRunning);
    final canSubmit = formKey.currentState?.validate() ?? false;

    return ElevatedButton(
      onPressed: canSubmit && !isSubmitting
          ? () => di<Manager>().submitCommand.run()
          : null,
      child: isSubmitting
          ? const CircularProgressIndicator()
          : const Text('Submit'),
    );
  }
  // #endregion form_submission_pattern
}

// #region pull_to_refresh_pattern
// Pull to refresh pattern
class PullToRefreshPattern extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.fetchTodosCommand);

    return RefreshIndicator(
      onRefresh: di<TodoManager>().fetchTodosCommand.runAsync,
      child: todos.isEmpty
          ? ListView(
              children: const [
                Center(child: Text('No todos - pull to refresh')),
              ],
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(todos[index].title),
              ),
            ),
    );
  }
}
// #endregion pull_to_refresh_pattern

// #region retry_on_error_pattern
// Retry on error pattern
class RetryOnErrorPattern extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final command = createOnce(() => Command());
    final error = watch(command.errors).value;

    if (error != null) {
      return Column(
        children: [
          Text('Error: $error'),
          ElevatedButton(
            onPressed: () => command.run(),
            child: Text('Retry'),
          ),
        ],
      );
    }

    return Container();
  }
}
// #endregion retry_on_error_pattern

void main() {}
