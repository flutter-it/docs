import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    getIt.registerSingleton<MyService>(MyService()); // Called on every hot reload!
    return MaterialApp(...);
  }
}
// #endregion example