import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.registerLazySingleton<MyService>(() => MyServiceImpl());
  runApp(MyApp());

  // Now you can use it
  final service = getIt<MyService>();
  print('service: $service'); // ✅ Works!
}
// #endregion example
