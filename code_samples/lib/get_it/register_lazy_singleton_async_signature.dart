// ignore_for_file: missing_function_body, unused_element
// #region example
void registerLazySingletonAsync<T extends Object>(
  FactoryFuncAsync<T> factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
  void Function(T instance)? onCreated,
  bool useWeakReference = false,
});
// #endregion example
