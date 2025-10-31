import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  final service = getIt<MyService>();
  print('service: $service'); // ❌ ERROR! Not registered yet
  getIt.registerLazySingleton<MyService>(() => MyServiceImpl());
  runApp(MyApp());
}
// #endregion example
