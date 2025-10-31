import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<void> main() async {
  // setupDependencies(); // Setup your dependencies first

  // Wait for specific service
  await getIt.isReady<Database>();

  // Now safe to use
  final db = getIt<Database>();

  // Wait for named instance
  await getIt.isReady<ApiClient>(instanceName: 'production');
}
// #endregion example
