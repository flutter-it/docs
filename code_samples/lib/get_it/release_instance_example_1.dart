import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
T registerSingletonIfAbsent<T>(
  T Function() factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
})

void releaseInstance(Object instance)
// #endregion example