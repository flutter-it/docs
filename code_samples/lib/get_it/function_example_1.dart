import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
void registerLazySingleton<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
  void Function(T instance)? onCreated,
  bool useWeakReference = false,
})
// #endregion example