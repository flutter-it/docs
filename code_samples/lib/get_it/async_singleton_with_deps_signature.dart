// ignore_for_file: missing_function_body, unused_element
void registerSingletonWithDependencies<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
  required Iterable<Type>? dependsOn,
  bool? signalsReady,
  DisposingFunc<T>? dispose,
})
