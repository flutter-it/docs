import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
// Push a new scope
  getIt.pushNewScope(
    scopeName: 'my-scope', // Optional: name for later reference
    init: (getIt) {
      // Register objects immediately
      getIt.registerSingleton<Service>(ServiceImpl());
    },
    dispose: () {
      // Cleanup when scope pops (called before object disposal)
      print('Scope cleanup');
    },
  );

// Pop the current scope
  await getIt.popScope();

// Pop multiple scopes to a named one
  await getIt.popScopesTill('my-scope', inclusive: true);

// Drop a specific scope by name (without popping above it)
  await getIt.dropScope('my-scope');

// Check if a scope exists
  if (getIt.hasScope('session')) {
    // ...
  }

// Get current scope name
  print(getIt
      .currentScopeName); // Returns null for base scope, 'baseScope' for base
  // #endregion example
}
