import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  // Force unregister even if refCount > 0
  getIt.unregister<MyService>(ignoreReferenceCount: true);
  // #endregion example
}
