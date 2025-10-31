// ignore_for_file: unused_local_variable
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
class MyService implements WillSignalReady {
  MyService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
    GetIt.instance.signalReady(this);
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

void configure() {
  // ✅ Correct - interface-based signaling
  getIt.registerSingleton<MyService>(MyService());
  // No signalsReady parameter needed - interface detected
}
// #endregion example

Future<void> main() async {
  configure();
  await getIt.isReady<MyService>();
}
