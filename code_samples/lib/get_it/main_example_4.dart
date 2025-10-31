import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  getIt.registerLazySingleton<MyService>(() => MyService());
  runApp(MyApp());

  // Now you can use it
  final service = getIt<MyService>();
  print('service: $service'); // ✅ Works!
  // #endregion example
}
