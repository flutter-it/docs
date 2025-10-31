import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.registerSingleton<MyService>(MyService());
  runApp(MyApp());
}
// #endregion example
