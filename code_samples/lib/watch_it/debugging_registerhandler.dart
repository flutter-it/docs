// ignore_for_file: unused_local_variable, unused_element
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:command_it/command_it.dart';

// Manager with commands for handler examples
class SaveManager {
  final saveCommand = Command.createAsyncNoParamNoResult(
    () async {
      await Future.delayed(const Duration(milliseconds: 500));
    },
    debugName: 'save',
  );

  final isLoading = ValueNotifier<bool>(false);
}

// #region handler_registered_after_return_bad
// BAD - Handler registered AFTER early return
class HandlerAfterReturnBad extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue((SaveManager m) => m.isLoading);

    if (isLoading) {
      return CircularProgressIndicator(); // Returns early!
    }

    // This handler never gets registered when loading!
    registerHandler(
      select: (SaveManager m) => m.saveCommand,
      handler: (context, result, cancel) {
        Navigator.pop(context);
      },
    );

    return MyForm();
  }
}
// #endregion handler_registered_after_return_bad

// #region handler_registered_before_return_good
// GOOD - Handler registered before conditional logic
class HandlerBeforeReturnGood extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (SaveManager m) => m.saveCommand,
      handler: (context, result, cancel) {
        Navigator.pop(context);
      },
    );

    final isLoading = watchValue((SaveManager m) => m.isLoading);

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return MyForm();
  }
}
// #endregion handler_registered_before_return_good

// Stub widgets
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}
