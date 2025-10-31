// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
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
  void doSomething() {/* ... */}
}

// Register

void main() {
  getIt.registerLazySingleton<ServiceB>(() => ServiceB(getIt<IServiceA>()));
  getIt.registerLazySingleton<IServiceA>(() => ServiceA()..init());
}
// #endregion example
