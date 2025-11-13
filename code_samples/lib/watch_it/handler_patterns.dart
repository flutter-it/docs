// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, undefined_identifier, unused_element
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

// #region watch_vs_handler_watch
class WatchVsHandlerWatch extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion watch_vs_handler_watch

// #region watch_vs_handler_handler
class WatchVsHandlerHandler extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand,
      handler: (context, result, cancel) {
        // Navigate to detail page (no rebuild needed)
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Scaffold()),
        );
      },
    );
    return Container();
  }
}
// #endregion watch_vs_handler_handler

// #region logging_analytics
class LoggingAnalytics extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (UserManager m) => m.currentUser,
      handler: (context, user, cancel) {
        if (user != null) {
          // analytics.logEvent('user_logged_in', {'userId': user.id});
          print('User logged in: ${user.id}');
        }
      },
    );
    return Container();
  }
}
// #endregion logging_analytics

// #region register_handler_generic
class RegisterHandlerGeneric extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (DataManager m) => m.data,
      handler: (context, value, cancel) {
        print('Data changed: $value');
      },
    );
    return Container();
  }
}
// #endregion register_handler_generic

// #region cancel_parameter
class CancelParameter extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (DataManager m) => m.data,
      handler: (context, value, cancel) {
        if (value == 'STOP') {
          cancel(); // Stop listening to future changes
        }
      },
    );
    return Container();
  }
}
// #endregion cancel_parameter

// #region pattern1_conditional_navigation
class Pattern1ConditionalNavigation extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (UserManager m) => m.currentUser,
      handler: (context, user, cancel) {
        if (user == null) {
          // User logged out - navigate to login
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
    );
    return Container();
  }
}
// #endregion pattern1_conditional_navigation

// #region pattern2_loading_dialog
class Pattern2LoadingDialog extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand.isExecuting,
      handler: (context, isExecuting, cancel) {
        if (isExecuting) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Processing...'),
                ],
              ),
            ),
          );
        } else {
          Navigator.of(context).pop(); // Close dialog
        }
      },
    );
    return Container();
  }
}
// #endregion pattern2_loading_dialog

// #region pattern4_debounced_actions
class Pattern4DebouncedActions extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (SimpleUserManager m) =>
          m.name.debounce(Duration(milliseconds: 300)),
      handler: (context, query, cancel) {
        // Handler only fires after 300ms of no changes
        print('Searching for: $query');
      },
    );
    return Container();
  }
}
// #endregion pattern4_debounced_actions

// #region decision_tree_watch
class DecisionTreeWatch extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView(
      children: todos.map((t) => Text(t.title)).toList(),
    );
  }
}
// #endregion decision_tree_watch

// #region decision_tree_handler
class DecisionTreeHandler extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand,
      handler: (context, result, cancel) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Scaffold()),
        );
      },
    );
    return Container();
  }
}
// #endregion decision_tree_handler

// #region mistake_bad
class MistakeBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // BAD - rebuilds entire widget just to navigate
    final user = watchValue((UserManager m) => m.currentUser);
    if (user != null) {
      // Navigator.push(...);  // Triggers unnecessary rebuild
    }
    return Container();
  }
}
// #endregion mistake_bad

// #region mistake_good
class MistakeGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // GOOD - navigate without rebuild
    registerHandler(
      select: (UserManager m) => m.currentUser,
      handler: (context, user, cancel) {
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Scaffold()),
          );
        }
      },
    );
    return Container();
  }
}
// #endregion mistake_good

void main() {}
