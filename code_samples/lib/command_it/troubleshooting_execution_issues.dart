// ignore_for_file: unused_local_variable, avoid_print
import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region restriction_diagnosis
final someValueNotifier = ValueNotifier(true);

final restrictedCommand = Command.createAsync<String, List<Data>>(
  (query) => api.fetchData(),
  initialValue: [],
  restriction: someValueNotifier, // Is this true?
);
// #endregion restriction_diagnosis

// #region restriction_debug
void debugRestriction() {
  final restriction = ValueNotifier(true);
  final command = Command.createAsync<String, List<Data>>(
    (query) => api.fetchData(),
    initialValue: [],
    restriction: restriction,
  );

  // Debug: print restriction state
  print('Can run: ${command.canRun.value}');
  print('Is restricted: ${restriction.value}'); // Should be false to run
}
// #endregion restriction_debug

// #region restriction_handler
final isLoggedOut = ValueNotifier(false);

final commandWithHandler = Command.createAsync<String, List<Data>>(
  (query) => api.fetchData(),
  initialValue: [],
  restriction: isLoggedOut,
  ifRestrictedRunInstead: (param) {
    // Show login dialog
    showLoginDialog();
  },
);

void showLoginDialog() {
  // Implementation
}
// #endregion restriction_handler

// #region stuck_diagnosis
final Future<void> neverCompletingFuture = Completer<void>().future;

final stuckCommand = Command.createAsync<String, void>((param) async {
  await api.fetchData(); // Does this ever complete?
  // Missing return statement?
}, initialValue: null);
// #endregion stuck_diagnosis

// #region stuck_cause
final neverCompletes = Command.createAsync<String, void>((param) async {
  // ❌️ Waiting for something that never happens
  await Completer<void>().future;
}, initialValue: null);
// #endregion stuck_cause

// #region stuck_solution
Future<List<Data>> fetchData() => api.fetchData();

final commandWithTimeout =
    Command.createAsync<String, List<Data>>((param) async {
  return await fetchData().timeout(Duration(seconds: 30));
}, initialValue: []);
// #endregion stuck_solution

void main() {
  debugRestriction();
}
