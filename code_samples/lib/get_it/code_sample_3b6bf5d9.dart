import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.registerLazySingleton<MyService>(
      () => MyService()); // ✅ Register as MyService
  final service = getIt<MyService>();
  print('service: $service'); // ✅ Works!
}
// #endregion example
