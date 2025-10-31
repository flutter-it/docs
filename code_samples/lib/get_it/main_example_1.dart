import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  setUpAll(() {
    configureDependencies(); // Register real app dependencies ONCE
  });

  setUp(() {
    getIt.pushNewScope(); // Create test scope
    getIt.registerSingleton<ApiClient>(MockApiClient()); // Shadow with mock
  });

  tearDown(() async {
    await getIt.popScope(); // Restore real services
  });

  test('test name', () {
    final service = getIt<UserService>();
    print('service: $service');
    // UserService automatically gets MockApiClient!
  });
}
// #endregion example
