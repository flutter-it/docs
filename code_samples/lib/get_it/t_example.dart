import 'package:get_it/get_it.dart';

// #region example
T registerSingleton<T>(
  T instance, {
  String? instanceName,
  bool? signalsReady,
  DisposingFunc<T>? dispose,
}) =>
    instance;
// #endregion example
