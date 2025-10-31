import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// All scopes
  final Iterable<Plugin> allPlugins = await getIt.getAllAsync<Plugin>(
    fromAllScopes: true,
  );

// Specific named scope
  final Iterable<Plugin> basePlugins = await getIt.getAllAsync<Plugin>(
    onlyInScope: 'baseScope',
  );
}
// #endregion example
