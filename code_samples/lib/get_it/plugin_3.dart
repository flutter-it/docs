import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Base scope
  getIt.registerSingleton<Plugin>(CorePlugin());
  getIt.registerSingleton<Plugin>(LoggingPlugin());

  // Push new scope
  getIt.pushNewScope(scopeName: 'feature');
  getIt.registerSingleton<Plugin>(FeatureAPlugin());
  getIt.registerSingleton<Plugin>(FeatureBPlugin());

  // Current scope only (default)
  final featurePlugins = getIt.getAll<Plugin>();
  print('featurePlugins: $featurePlugins');
  // Returns: [FeatureAPlugin, FeatureBPlugin]
}
// #endregion example
