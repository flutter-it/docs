import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  final client1 = getIt<ApiClient>(); // Instance created
  final client2 = getIt<ApiClient>(); // Same instance returned
}
// #endregion example
