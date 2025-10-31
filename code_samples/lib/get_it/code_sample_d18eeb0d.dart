import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  test('widget works with async services', () async {
    getIt.pushNewScope();

    // Register async mock
    getIt.registerSingletonAsync<Database>(() async {
      await Future.delayed(Duration(milliseconds: 100));
      return MockDatabase();
    });

    // Wait for all async registrations
    await getIt.allReady();

    // Now safe to test
    final db = getIt<Database>();
    print('db: $db');
    expect(db, isA<MockDatabase>());

    await getIt.popScope();
  });
  // #endregion example
}
