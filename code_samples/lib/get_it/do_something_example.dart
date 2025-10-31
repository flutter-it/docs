import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
abstract class IServiceA {
  void doSomething();
}

class ServiceB {
  final IServiceA serviceA;
  ServiceB(this.serviceA);
}

class ServiceA implements IServiceA {
  late final ServiceB serviceB;

  void init() {
    serviceB = getIt<ServiceB>(); // Get after construction
  }

  @override
  void doSomething() { /* ... */ }
}

// Register
getIt.registerLazySingleton<ServiceB>(() => ServiceB(getIt<IServiceA>()));
getIt.registerLazySingleton<IServiceA>(() => ServiceA()..init());
}
// #endregion example