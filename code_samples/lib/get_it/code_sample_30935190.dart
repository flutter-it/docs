// ignore_for_file: missing_function_body, unused_element
typedef FactoryFuncParam<T, P1, P2> = T Function(P1 param1, P2 param2);
typedef FactoryFuncParamAsync<T, P1, P2> = Future<T> Function(
    P1 param1, P2 param2);

void registerFactoryParam<T, P1, P2>(
  FactoryFuncParam<T, P1, P2> factoryFunc, {
  String? instanceName,
}) {}

void registerFactoryParamAsync<T, P1, P2>(
  FactoryFuncParamAsync<T, P1, P2> factoryFunc, {
  String? instanceName,
}) {}
