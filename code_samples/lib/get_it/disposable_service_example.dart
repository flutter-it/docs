// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'dart:async';

import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class DisposableService implements Disposable {
  bool disposed = false;

  @override
  FutureOr onDispose() {
    disposed = true;
  }
}

// #endregion example

void main() async {
  // #region example
  getIt.pushNewScope();

  final service = DisposableService();
  getIt.registerSingleton<DisposableService>(service);

  print('Before pop: ${service.disposed}'); // false

  await getIt.popScope();

  print('After pop: ${service.disposed}'); // true
  // #endregion example
}
