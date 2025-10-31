import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.pushNewScope(
    isFinal: true, // Can't register after init completes
    init: (getIt) {
      // MUST register everything here
      getIt.registerSingleton<ServiceA>(ServiceA());
      getIt.registerSingleton<ServiceB>(ServiceB());
    },
  );

// This throws an error - scope is final!
// getIt.registerSingleton<ServiceC>(ServiceC());
}
// #endregion example
