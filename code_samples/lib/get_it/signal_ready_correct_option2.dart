// ignore_for_file: unused_local_variable
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
class MyService {
  MyService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
    GetIt.instance.signalReady(this); // ✅ Now it's in GetIt
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

void configure() {
  // ✅ Correct - instance registered immediately
  getIt.registerSingleton<MyService>(
    MyService(),
    signalsReady: true, // Must manually signal
  );
}
// #endregion example

Future<void> main() async {
  configure();
  await getIt.isReady<MyService>();
}
