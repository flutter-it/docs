import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  setUp(() {
    configureDependencies(); // Call your real DI setup

    getIt.pushNewScope(); // Shadow specific services with mocks
    getIt.registerSingleton<ApiClient>(MockApiClient());
    getIt.registerSingleton<Database>(MockDatabase());
  });

  tearDown(() async {
    await getIt.popScope(); // Remove mocks, clean slate for next test
  });
}
// #endregion example
