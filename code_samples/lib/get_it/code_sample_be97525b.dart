import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
final registration = getIt.findFirstObjectRegistration<MyService>();

if (registration != null) {
  print('Type: ${registration.registrationType}'); // factory, singleton, lazy, etc.
  print('Instance name: ${registration.instanceName}');
  print('Is async: ${registration.isAsync}');
  print('Is ready: ${registration.isReady}');
}
// #endregion example