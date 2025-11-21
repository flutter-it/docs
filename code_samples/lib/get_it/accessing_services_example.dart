// ignore_for_file: unused_local_variable

import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void setupServices() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<Database>(Database());
}

// #region example
void accessServices() {
  // Shorthand syntax (recommended)
  final api = getIt<ApiClient>();

  // Full syntax (same result)
  final db = getIt.get<Database>();

  // The <Type> parameter must match what was registered
  // This works because we registered <ApiClient>:
  final client = getIt<ApiClient>(); // ✅ Works

  // This would fail if ApiClient was registered as a concrete type:
  // final client = getIt<SomeInterface>(); // ❌ Error if not registered as SomeInterface
}
// #endregion example

void main() {
  setupServices();
  accessServices();
}
