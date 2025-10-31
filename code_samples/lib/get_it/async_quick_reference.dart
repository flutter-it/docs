import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
void main() async {
  final getIt = GetIt.instance;
  // Example usage
  // Access async factory or singleton
  final service = await getIt.getAsync<ApiClient>();

  // Check if singleton is ready
  await getIt.isReady<ApiClient>();

  // Wait for all async singletons to be ready
  await getIt.allReady();
}
// #endregion example
