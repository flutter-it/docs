import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
void registerFactoryParam<T, P1, P2>(
  FactoryFuncParam<T, P1, P2> factoryFunc, {
  String? instanceName,
})

void registerFactoryParamAsync<T, P1, P2>(
  FactoryFuncParamAsync<T, P1, P2> factoryFunc, {
  String? instanceName,
})
// #endregion example