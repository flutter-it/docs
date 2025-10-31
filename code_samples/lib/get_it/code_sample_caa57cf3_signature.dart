// ignore_for_file: missing_function_body, unused_element
getIt.registerSingleton(TestClass());

    final instance1 = getIt.get(type: TestClass);

    expect(instance1 is TestClass, true);