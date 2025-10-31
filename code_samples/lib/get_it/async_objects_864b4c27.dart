import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<void> main() async {
  setupDependencies();

  try {
    await getIt.allReady(timeout: Duration(seconds: 10));
    runApp(MyApp());
  } on WaitingTimeOutException catch (e) {
    print('Initialization timeout!');
    print('Not ready: ${e.notReadyYet}');
    print('Already ready: ${e.areReady}');
    print('Waiting chain: ${e.areWaitedBy}');
  }
}
// #endregion example
