import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  final registration = getIt.findFirstObjectRegistration<MyService>();
  print('registration: $registration');

  if (registration != null) {
    print(
        'Type: ${registration.registrationType}'); // factory, singleton, lazy, etc.
    print('Instance name: ${registration.instanceName}');
    print('Is async: ${registration.isAsync}');
    print('Is ready: ${registration.isReady}');
  }
}
// #endregion example
