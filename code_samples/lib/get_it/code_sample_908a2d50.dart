// ignore_for_file: missing_function_body, unused_element
// #region example
  /// retrieves or creates an instance of a registered type [T] depending on the registration
  /// function used for this type or based on a name.
  /// for factories you can pass up to 2 parameters [param1,param2] they have to match the types
  /// given at registration with [registerFactoryParam()]
  /// [type] if you want to get an instance by a Type object instead of a generic parameter.This should
  /// rarely be needed but can be useful if you have a runtime type and want to get an instance
T get<T extends Object>({
    dynamic param1,
    dynamic param2,
    String? instanceName,
    Type? type,
  });
// #endregion example
