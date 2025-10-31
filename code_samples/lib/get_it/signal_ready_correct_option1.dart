// ignore_for_file: unused_local_variable
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class MyService {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

// #region example
void configure() {
  // ✅ Correct - no signalsReady needed
  getIt.registerSingletonAsync<MyService>(
    () async {
      final service = MyService();
      await service.initialize();
      return service; // Automatically signals ready
    },
  );
}
// #endregion example

Future<void> main() async {
  configure();
  await getIt.allReady();
}
