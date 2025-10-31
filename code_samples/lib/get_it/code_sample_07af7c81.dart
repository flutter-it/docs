import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  // All scopes
  final allPlugins = getIt.getAll<Plugin>(fromAllScopes: true);
  print('allPlugins: $allPlugins');
  // Returns: [FeatureAPlugin, FeatureBPlugin, CorePlugin, LoggingPlugin]
  // #endregion example
}
