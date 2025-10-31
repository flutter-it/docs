import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Check if type is registered
  if (getIt.isRegistered<ApiClient>()) {
    print('ApiClient is already registered');
  }

// Check by instance name
  if (getIt.isRegistered<Database>(instanceName: 'test-db')) {
    print('Test database is registered');
  }

// Check if specific instance is registered
  final myLogger = Logger();
  if (getIt.isRegistered<Logger>(instance: myLogger)) {
    print('This specific logger instance is registered');
  }
}
// #endregion example
