import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.registerLazySingleton(
      () => MyServiceImpl()); // Registers as MyServiceImpl
  final service = getIt<MyService>();
  print('service: $service'); // ❌ Looking for MyService
}
// #endregion example
