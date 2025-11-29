// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region diagnosis1_bad
class ManagerNoErrorHandling {
  // ❌️ No error handling - failures are invisible
  late final loadCommand = Command.createAsyncNoParam<Data>(
    () => api.fetchData().then((list) => list.first),
    initialValue: Data.empty(),
  );
}
// #endregion diagnosis1_bad

// #region diagnosis1_good
class ManagerWithErrorHandling {
  // ✅ Option 1: Listen to errors on command definition
  late final loadCommand = Command.createAsyncNoParam<Data>(
    () => api.fetchData().then((list) => list.first),
    initialValue: Data.empty(),
  )..errors.listen((error, _) {
      if (error != null) debugPrint('Load failed: ${error.error}');
    });
}

class WidgetWatchingResults extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Option 2: Watch .results in UI to see all states
    final result =
        watchValue((ManagerWithErrorHandling m) => m.loadCommand.results);
    if (result.hasError) return ErrorWidget(result.error!);
    return Text(result.data.toString());
  }
}
// #endregion diagnosis1_good

// #region diagnosis2_bad
class BadStaticRead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌️ Reading value once - won't update when command completes
    final data = di<ManagerWithErrorHandling>()
        .loadCommand
        .value; // Static read, no subscription!
    return Text('$data');
  }
}
// #endregion diagnosis2_bad

// #region diagnosis2_good
// ✅ Option 1: ValueListenableBuilder
class GoodValueListenableBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: di<ManagerWithErrorHandling>().loadCommand,
      builder: (context, data, _) => Text('$data'),
    );
  }
}

// ✅ Option 2: watch_it (requires WatchingWidget)
class GoodWatchIt extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((ManagerWithErrorHandling m) => m.loadCommand);
    return Text('$data');
  }
}
// #endregion diagnosis2_good

void main() {}
