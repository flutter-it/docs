import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  final client1 = getIt<ApiClient>();
  print('client1: $client1'); // Instance created
  final client2 = getIt<ApiClient>();
  print('client2: $client2'); // Same instance returned
  // #endregion example
}
