import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // All scopes
  final allPlugins = getIt.getAll<Plugin>(fromAllScopes: true);
  print('allPlugins: $allPlugins');
  // Returns: [FeatureAPlugin, FeatureBPlugin, CorePlugin, LoggingPlugin]
}
// #endregion example
