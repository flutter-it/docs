// ignore_for_file: unused_local_variable, unused_field
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region not_listening_errors
// ❌ BAD: Errors go nowhere
late final commandNoListener = Command.createAsyncNoParam<Data>(
  () => api.fetchData().then((list) => list.first),
  initialValue: Data.empty(),
  errorFilter: const LocalErrorFilter(),
);
// No error listener! Assertions in debug mode

// ✅ GOOD: Always listen to errors when using localHandler
void setupGoodErrorListener() {
  commandNoListener.errors.listen((error, _) {
    if (error != null) showError(error.error);
  });
}

void showError(Object error) {
  debugPrint('Error: $error');
}
// #endregion not_listening_errors

// #region try_catch_inside
// ❌ BAD: try/catch inside command function
class DataManagerBad {
  late final loadCommand = Command.createAsyncNoParam<Data>(
    () async {
      try {
        final list = await api.fetchData();
        return list.first;
      } catch (e) {
        // Manual error handling defeats command_it's error system
        debugPrint('Error: $e');
        rethrow;
      }
    },
    initialValue: Data.empty(),
  );
}

// ✅ GOOD: Let command handle errors, use ..errors.listen()
class DataManagerGood {
  late final loadCommand = Command.createAsyncNoParam<Data>(
    () async {
      final list = await api.fetchData();
      return list.first;
    },
    initialValue: Data.empty(),
  )..errors.listen((error, _) {
      if (error != null) {
        debugPrint('Error: ${error.error}');
      }
    });
}
// #endregion try_catch_inside

// #region excessive_results
class ExcessiveResultsExample extends StatelessWidget {
  final Command<void, String> command;

  const ExcessiveResultsExample({super.key, required this.command});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ❌ BAD: Always using .results when not needed
        ValueListenableBuilder(
          valueListenable: command.results,
          builder: (context, result, _) {
            return Text(result.data?.toString() ?? '');
          },
        ),
        // Rebuilds on running, error, success

        // ✅ GOOD: Use .value for data-only updates
        ValueListenableBuilder(
          valueListenable: command,
          builder: (context, data, _) {
            return Text(data.toString());
          },
        ),
        // Only rebuilds on successful completion
      ],
    );
  }
}
// #endregion excessive_results

// #region forgetting_initial
// ❌ WRONG: Missing initialValue would be compile error
// late final commandMissing = Command.createAsyncNoParam<String>(
//   () => api.load(),
//   // Missing initialValue!
// );

// ✅ CORRECT: Always provide initialValue
late final commandWithInitial = Command.createAsyncNoParam<String>(
  () async => 'loaded',
  initialValue: '', // Required for non-void results
);
// #endregion forgetting_initial

// #region sync_isrunning
// ❌ WRONG: Sync commands don't have meaningful isRunning
final syncCommand = Command.createSyncNoParam<String>(
  () => 'result',
  initialValue: '',
);

// Accessing isRunning on sync command - always false
// ValueListenableBuilder(
//   valueListenable: syncCommand.isRunning, // Not useful!
//   builder: ...,
// );

// ✅ CORRECT: Use async command if you need isRunning
final asyncCommand = Command.createAsyncNoParam<String>(
  () async => 'result',
  initialValue: '',
);
// #endregion sync_isrunning

void main() {
  setupGoodErrorListener();
}
