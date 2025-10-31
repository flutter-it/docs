import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  final registration = getIt.findFirstObjectRegistration<MyService>();
  print('registration: $registration');
  print('Registered in scope: ${registration?.instanceName}');
  // #endregion example
}
