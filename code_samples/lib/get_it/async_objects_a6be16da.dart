import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<void> main() async {
  try {
    await getIt.allReady(timeout: Duration(seconds: 30));
    runApp(MyApp());
  } on WaitingTimeOutException catch (e) {
    // Handle timeout - log error, show error screen, etc.
    runApp(ErrorApp(error: e));
  }
}
// #endregion example
