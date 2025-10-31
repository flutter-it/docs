import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
T registerSingleton<T>(
  T instance, {
  String? instanceName,
  bool? signalsReady,
  DisposingFunc<T>? dispose,
})
// #endregion example