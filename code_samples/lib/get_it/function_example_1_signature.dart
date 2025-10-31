// ignore_for_file: missing_function_body, unused_element
// #region example
  /// Unregister an [instance] of an object or a factory/singleton by Type [T] or by name
  /// [instanceName] if you need to dispose any resources you can do it using
  /// [disposingFunction] function that provides an instance of your class to be disposed.
  /// This function overrides the disposing you might have provided when registering.
  /// If you have enabled reference counting when registering, [unregister] will only unregister and dispose the object
  /// if referenceCount is 0
  /// [ignoreReferenceCount] if `true` it will ignore the reference count and unregister the object
  /// only use this if you know what you are doing
FutureOr unregister<T extends Object>({
    Object? instance,
    String? instanceName,
    FutureOr Function(T)? disposingFunction,
    bool ignoreReferenceCount = false,
  });
// #endregion example
