// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

Future<List<Data>> fetchData() => ApiClient().fetchData();
final getIt = GetIt.instance;

// #region diagnosis_bad
class ManagerNoDispose {
  late final command = Command.createAsync<String, List<Data>>(
    (query) => fetchData(),
    initialValue: [],
  );

  // ❌️ Missing dispose!
}
// #endregion diagnosis_bad

// #region solution
class ManagerWithDispose with Disposable {
  late final command = Command.createAsync<String, List<Data>>(
    (query) => fetchData(),
    initialValue: [],
  );

  @override
  void onDispose() {
    command.dispose(); // ✅ Clean up
  }
}
// #endregion solution

// #region get_it_dispose
void registerWithDispose() {
  getIt.registerSingleton<ManagerWithDispose>(
    ManagerWithDispose(),
    dispose: (manager) => manager.onDispose(),
  );
}
// #endregion get_it_dispose

void main() {
  registerWithDispose();
}
