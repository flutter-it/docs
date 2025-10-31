import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.registerLazySingleton<MyService>(() => MyService());
  final service = getIt<MyService>();
  print('service: $service'); // ✅ Now it works
  runApp(MyApp());
}
// #endregion example
