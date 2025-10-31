import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // Only search the base scope
  final basePlugins = getIt.getAll<Plugin>(onlyInScope: 'baseScope');
  print('basePlugins: $basePlugins');
  // Returns: [CorePlugin, LoggingPlugin]

  // Only search the 'feature' scope
  final featurePlugins = getIt.getAll<Plugin>(onlyInScope: 'feature');
  print('featurePlugins: $featurePlugins');
  // Returns: [FeatureAPlugin, FeatureBPlugin]
}
// #endregion example
