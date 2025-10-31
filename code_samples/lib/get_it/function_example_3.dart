import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
void resetLazySingleton<T>({
  Object? instance,
  String? instanceName,
  void Function(T)? disposingFunction,
});
// #endregion example