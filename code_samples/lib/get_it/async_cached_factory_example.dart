import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Cached async factory
  getIt.registerCachedFactoryAsync<HeavyResource>(
    () async {
      final resource = HeavyResource();
      await resource.initialize();
      return resource;
    },
  );

  // First access - creates new instance
  final resource1 = await getIt.getAsync<HeavyResource>();

  // While still in memory - returns cached instance
  final resource2 = await getIt.getAsync<HeavyResource>();

  print(
      'resource1 == resource2: ${identical(resource1, resource2)}'); // true - same instance
}
// #endregion example
