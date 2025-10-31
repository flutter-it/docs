import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
void registerCachedFactory<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
})

void registerCachedFactoryParam<T, P1, P2>(
  FactoryFuncParam<T, P1, P2> factoryFunc, {
  String? instanceName,
})

void registerCachedFactoryAsync<T>(
  FactoryFuncAsync<T> factoryFunc, {
  String? instanceName,
})

void registerCachedFactoryParamAsync<T, P1, P2>(
  FactoryFuncParamAsync<T, P1, P2> factoryFunc, {
  String? instanceName,
})
// #endregion example