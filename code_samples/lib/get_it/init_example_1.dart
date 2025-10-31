// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'dart:async';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class MyService implements Disposable {
  final Stream<dynamic> stream = Stream.empty();
  StreamSubscription? _subscription;

  void init() {
    _subscription = stream.listen((data) {});
  }

  @override
  Future<void> onDispose() async {
    await _subscription?.cancel();
    // Cleanup resources
  }
}

// Automatically calls onDispose when scope pops or object is unregistered

void main() {
  getIt.registerSingleton<MyService>(MyService()..init());
}
// #endregion example
