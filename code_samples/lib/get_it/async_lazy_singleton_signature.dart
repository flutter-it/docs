// ignore_for_file: missing_function_body, unused_element
void registerLazySingletonAsync<T>(
  FactoryFuncAsync<T> factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
  void Function(T instance)? onCreated,
  bool useWeakReference = false,
})
