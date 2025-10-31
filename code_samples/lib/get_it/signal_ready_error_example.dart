// ignore_for_file: unused_local_variable, unreachable_from_main
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
class MyService {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

void configureIncorrect() {
  // ❌ This will throw: "This instance is not available in GetIt"
  getIt.registerSingletonAsync<MyService>(
    () async {
      final service = MyService();
      await service.initialize();

      // ❌ ERROR: Instance not in GetIt yet!
      // The factory hasn't returned, so GetIt doesn't know about this instance
      getIt.signalReady(service);

      return service;
    },
    signalsReady: true,
  );
}
// #endregion example

// This file is intentionally broken to show the anti-pattern
// It should not be run
void main() {
  // Do not run - this is an anti-pattern example
}
