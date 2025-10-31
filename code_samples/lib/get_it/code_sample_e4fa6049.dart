import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
// #region example
  // Only search the base scope
  final basePlugins = getIt.getAll<Plugin>(onlyInScope: 'baseScope');
  // Returns: [CorePlugin, LoggingPlugin]

  // Only search the 'feature' scope
  final featurePlugins = getIt.getAll<Plugin>(onlyInScope: 'feature');
  // Returns: [FeatureAPlugin, FeatureBPlugin]
// #endregion example
  print('basePlugins: $basePlugins');
  print('featurePlugins: $featurePlugins');
}
