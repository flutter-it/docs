import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  getIt.registerLazySingleton<MyService>(
      () => MyService()); // ✅ Register as MyService
  final service = getIt<MyService>();
  print('service: $service'); // ✅ Works!
  // #endregion example
}
