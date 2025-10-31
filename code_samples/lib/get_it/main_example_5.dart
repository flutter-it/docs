import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  final service = getIt<MyService>();
  print('service: $service'); // ❌ ERROR! Not registered yet
  getIt.registerLazySingleton<MyService>(() => MyService());
  runApp(MyApp());
  // #endregion example
}
