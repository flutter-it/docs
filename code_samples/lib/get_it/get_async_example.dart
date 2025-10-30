
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Example usage
  // Get async factory instance
  final conn = await getIt.getAsync<DatabaseConnection>();

  // Get async singleton (waits if still initializing)
  final api = await getIt.getAsync<ApiClient>();

  // Get named instance
  final cache = await getIt.getAsync<CacheService>(instanceName: 'user-cache');

  // Get with parameters (async factory param)
  final report = await getIt.getAsync<Report>(
    param1: 'user-123',
    param2: DateTime.now(),
  );

}
// #endregion example
