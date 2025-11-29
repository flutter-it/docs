// ignore_for_file: unused_local_variable, unused_field
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region isrunningsync
late final loadCommand = Command.createAsyncNoParam<List<Data>>(
  () => api.fetchData(),
  initialValue: [],
);

// ✅ Correct: Synchronous restriction
late final saveCommandGood = Command.createAsyncNoResult<Data>(
  (data) => api.save(data),
  restriction: loadCommand.isRunningSync, // Prevents race conditions
);

// ❌ Wrong: Async update can cause races
late final saveCommandBad = Command.createAsyncNoResult<Data>(
  (data) => api.save(data),
  restriction: loadCommand.isRunning, // Race condition possible!
);
// #endregion isrunningsync

// #region inverted
final isLoggedIn = ValueNotifier<bool>(false);

// ❌ Common mistake: Restriction logic backwards
late final commandBad = Command.createAsyncNoParam<Data>(
  () => api.fetchData().then((list) => list.first),
  initialValue: Data.empty(),
  restriction: isLoggedIn, // WRONG: Disabled when logged in!
);

// ✅ Correct: Negate the condition
late final commandGood = Command.createAsyncNoParam<Data>(
  () => api.fetchData().then((list) => list.first),
  initialValue: Data.empty(),
  restriction:
      isLoggedIn.map((logged) => !logged), // Disabled when NOT logged in
);
// #endregion inverted

void main() {
  // Examples compile but don't run
}
