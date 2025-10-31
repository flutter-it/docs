import 'package:code_samples/get_it/_shared/stubs.dart' as basic_samples;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:code_samples/get_it/async_objects.dart' as async_samples;

void main() {
  setUp(() {
    // Reset GetIt before each test
    GetIt.instance.reset();
  });

  group('Basic Usage Samples', () {
    test('configure dependencies works', () {
      basic_samples.configureDependencies();

      expect(GetIt.instance.isRegistered<basic_samples.ApiClient>(), isTrue);
      expect(GetIt.instance.isRegistered<basic_samples.Database>(), isTrue);
      expect(GetIt.instance.isRegistered<basic_samples.AuthService>(), isTrue);
    });

    test('access services works', () {
      basic_samples.configureDependencies();
      basic_samples.accessServices();
    });
  });

  group('Async Objects Samples', () {
    test('register factory async works', () async {
      async_samples.registerFactoryAsyncExample();
      await async_samples.useFactoryAsync();
    });

    test('register cached factory async works', () async {
      async_samples.registerCachedFactoryAsyncExample();
      await async_samples.useCachedFactoryAsync();
    });

    test('register singleton async works', () async {
      async_samples.registerSingletonAsyncExample();
      await async_samples.useSingletonAsync();
    });

    test('register lazy singleton async works', () async {
      async_samples.registerLazySingletonAsyncExample();
      await async_samples.useLazySingletonAsync();
    });

    test('dependencies example works', () async {
      async_samples.dependenciesExample();
      await async_samples.allReadyExample();
    });

    test('is ready example works', () async {
      async_samples.registerSingletonAsyncExample();
      await async_samples.isReadyExample();
    });
  });
}
