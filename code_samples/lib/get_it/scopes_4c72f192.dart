import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Get service from scope
  final service = getIt<MyServiceImpl>();
  service.doWork();
  service.saveState();

  // When exiting scope, call cleanup
  await getIt.popScope();

  // Scope is now disposed, service is unregistered
  // Next access will get service from parent scope (if any)
  final parentScopeService = getIt<MyServiceImpl>();
}
// #endregion example
