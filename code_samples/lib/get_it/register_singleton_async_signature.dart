// ignore_for_file: missing_function_body, unused_element
// #region example
void registerSingletonAsync<T extends Object>(
  FactoryFuncAsync<T> factoryFunc, {
  String? instanceName,
  Iterable<Type>? dependsOn,
  bool? signalsReady,
  DisposingFunc<T>? dispose,
  void Function(T instance)? onCreated,
});
// #endregion example
