import 'package:get_it/get_it.dart';

// #region example
T registerSingletonIfAbsent<T>(
  T Function() factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
}) =>
    factoryFunc();

void releaseInstance(Object instance) {}
// #endregion example
