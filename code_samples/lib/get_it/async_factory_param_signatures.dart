// ignore_for_file: missing_function_body, unused_element
import 'package:get_it/get_it.dart';

// #region example
// One parameter
void registerFactoryParamAsync<T, P1>(
  FactoryFuncParamAsync<T, P1, dynamic> factoryFunc, {
  String? instanceName,
}) {}

// Two parameters
void registerFactoryParam2Async<T, P1, P2>(
  FactoryFuncParamAsync<T, P1, P2> factoryFunc, {
  String? instanceName,
}) {}

// Cached with one parameter
void registerCachedFactoryParamAsync<T, P1>(
  FactoryFuncParamAsync<T, P1, dynamic> factoryFunc, {
  String? instanceName,
}) {}

// Cached with two parameters
void registerCachedFactoryParam2Async<T, P1, P2>(
  FactoryFuncParamAsync<T, P1, P2> factoryFunc, {
  String? instanceName,
}) {}
// #endregion example
