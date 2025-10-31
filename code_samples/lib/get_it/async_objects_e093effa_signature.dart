import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void registerSingletonWithDependencies<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
  required Iterable<Type>? dependsOn,
  bool? signalsReady,
  DisposingFunc<T>? dispose,
})
// #endregion example
