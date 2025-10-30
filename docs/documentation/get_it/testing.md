---
title: Testing
---

# Testing

Testing code that uses get_it requires different approaches depending on whether you're writing unit tests, widget tests, or integration tests. This guide covers best practices and common patterns.

## Quick Start: The Scope Pattern (Recommended)

**Best practice:** Use **scopes** to shadow real services with test doubles. This is cleaner and more maintainable than resetting get_it or using conditional registration.

```dart
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
    // UserService automatically gets MockApiClient!
  });
}
```

**Key benefits:**
- Only override what you need for each test
- Automatic cleanup between tests
- Same `configureDependencies()` as production

---

## Unit Testing Patterns

### Pattern 1: Scoped Test Doubles (Recommended)

Use scopes to inject mocks for specific services while keeping the rest of your dependency graph intact.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    // Register all real dependencies once
    getIt.registerLazySingleton<ApiClient>(() => ApiClientImpl());
    getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl(getIt()));
    getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt(), getIt()));
  });

  group('UserRepository tests', () {
    late MockApiClient mockApi;
    late MockAuthService mockAuth;

    setUp(() {
      // Push scope and shadow only the services we want to mock
      getIt.pushNewScope();

      mockApi = MockApiClient();
      mockAuth = MockAuthService();

      getIt.registerSingleton<ApiClient>(mockApi);
      getIt.registerSingleton<AuthService>(mockAuth);

      // UserRepository will be created fresh with our mocks
    });

    tearDown(() async {
      await getIt.popScope();
    });

    test('fetchUser should call API with correct auth token', () async {
      // Arrange
      when(mockAuth.getToken()).thenReturn('test-token');
      when(mockApi.get('/users/123', headers: anyNamed('headers')))
          .thenAnswer((_) async => Response(data: {'id': '123', 'name': 'Alice'}));

      // Act
      final repo = getIt<UserRepository>();
      final user = await repo.fetchUser('123');

      // Assert
      expect(user.name, 'Alice');
      verify(mockAuth.getToken()).called(1);
      verify(mockApi.get('/users/123', headers: {'Authorization': 'Bearer test-token'})).called(1);
    });
  });
}
```

### Pattern 2: Constructor Injection for Pure Unit Tests

For testing classes in complete isolation (without get_it), use optional constructor parameters.

```dart
class UserManager {
  final AppModel appModel;
  final DbService dbService;

  UserManager({
    AppModel? appModel,
    DbService? dbService,
  })  : appModel = appModel ?? getIt<AppModel>(),
        dbService = dbService ?? getIt<DbService>();

  Future<void> saveUser(User user) async {
    appModel.currentUser = user;
    await dbService.save(user);
  }
}

// In tests - no get_it needed
test('saveUser updates model and persists to database', () async {
  final mockModel = MockAppModel();
  final mockDb = MockDbService();

  // Create instance directly with mocks
  final manager = UserManager(appModel: mockModel, dbService: mockDb);

  await manager.saveUser(User(id: '1', name: 'Bob'));

  verify(mockDb.save(any)).called(1);
});
```

**When to use:**
- ✅ Testing pure business logic in isolation
- ✅ Classes that don't need the full dependency graph
- ❌ Integration-style tests where you want real dependencies

---

## Widget Testing

### Testing Widgets That Use get_it

Widgets often retrieve services from get_it. Use scopes to provide test-specific implementations.

```dart
void main() {
  setUpAll(() {
    // Register app dependencies
    getIt.registerLazySingleton<ThemeService>(() => ThemeServiceImpl());
    getIt.registerLazySingleton<UserService>(() => UserServiceImpl());
  });

  testWidgets('LoginPage displays user after successful login', (tester) async {
    // Arrange - push scope with mock
    getIt.pushNewScope();
    final mockUser = MockUserService();
    when(mockUser.login(any, any)).thenAnswer((_) async => User(name: 'Alice'));
    getIt.registerSingleton<UserService>(mockUser);

    // Act
    await tester.pumpWidget(MyApp());
    await tester.enterText(find.byKey(Key('username')), 'alice');
    await tester.enterText(find.byKey(Key('password')), 'secret');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Welcome, Alice'), findsOneWidget);

    // Cleanup
    await getIt.popScope();
  });
}
```

### Testing with Async Registrations

If your app uses `registerSingletonAsync`, ensure async services are ready before testing.

```dart
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
  expect(db, isA<MockDatabase>());

  await getIt.popScope();
});
```

---

## Integration Testing

### Full App Testing with Mocked Services

For integration tests, register mocks at the top level while keeping the rest of the app real.

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end user flow', () {
    setUpAll(() async {
      // Push scope for integration test environment
      getIt.pushNewScope(
        scopeName: 'integration-test',
        init: (scope) {
          // Mock only external dependencies
          scope.registerSingleton<ApiClient>(FakeApiClient());
          scope.registerSingleton<SecureStorage>(InMemoryStorage());

          // Use real implementations for everything else
          scope.registerLazySingleton<AuthService>(() => AuthServiceImpl(getIt()));
          scope.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));
        },
      );
    });

    tearDownAll(() async {
      await getIt.popScope();
    });

    testWidgets('User can login and view profile', (tester) async {
      await tester.pumpWidget(MyApp());

      // Interact with real UI + real services + fake backend
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
```

### Environment-Based Registration (Alternative Pattern)

Use a flag to switch between real and test implementations. Less flexible than scopes but simpler for basic cases.

```dart
void configureDependencies({bool testing = false}) {
  if (testing) {
    getIt.registerSingleton<ApiClient>(FakeApiClient());
    getIt.registerSingleton<Database>(InMemoryDatabase());
  } else {
    getIt.registerSingleton<ApiClient>(ApiClientImpl());
    getIt.registerSingleton<Database>(DatabaseImpl());
  }

  // Shared registrations
  getIt.registerLazySingleton<UserService>(() => UserServiceImpl(getIt()));
}

// In main.dart
void main() {
  configureDependencies();
  runApp(MyApp());
}

// In test
void main() {
  setUpAll(() {
    configureDependencies(testing: true);
  });

  // Tests...
}
```

**Limitations:**
- ❌ Can't switch between test/real per test
- ❌ No automatic cleanup between tests
- ❌ Must manually reset if needed

---

## Testing Factories

### Testing Factory Registrations

Factories create new instances on each `get()` call - verify this behavior in tests.

```dart
test('factory creates new instance each time', () {
  getIt.pushNewScope();

  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());

  final cart1 = getIt<ShoppingCart>();
  final cart2 = getIt<ShoppingCart>();

  expect(identical(cart1, cart2), false); // Different instances

  await getIt.popScope();
});
```

### Testing Parameterized Factories

```dart
test('factory param passes parameters correctly', () {
  getIt.pushNewScope();

  getIt.registerFactoryParam<UserViewModel, String, void>(
    (userId, _) => UserViewModel(userId),
  );

  final vm = getIt<UserViewModel>(param1: 'user-123');
  expect(vm.userId, 'user-123');

  await getIt.popScope();
});
```

---

## Common Testing Scenarios

### Scenario 1: Testing Service with Multiple Dependencies

```dart
test('complex service uses all dependencies correctly', () {
  getIt.pushNewScope();

  // Mock all dependencies
  final mockApi = MockApiClient();
  final mockDb = MockDatabase();
  final mockAuth = MockAuthService();

  getIt.registerSingleton<ApiClient>(mockApi);
  getIt.registerSingleton<Database>(mockDb);
  getIt.registerSingleton<AuthService>(mockAuth);

  // Service under test (uses real implementation)
  getIt.registerLazySingleton<SyncService>(() => SyncService(
    getIt<ApiClient>(),
    getIt<Database>(),
    getIt<AuthService>(),
  ));

  when(mockAuth.isAuthenticated).thenReturn(true);
  when(mockApi.fetchData()).thenAnswer((_) async => ['data']);

  final sync = getIt<SyncService>();
  // Test sync behavior...

  await getIt.popScope();
});
```

### Scenario 2: Testing Scoped Services

```dart
test('service lifecycle matches scope lifecycle', () async {
  // Base scope
  getIt.registerLazySingleton<CoreService>(() => CoreService());

  // Feature scope
  getIt.pushNewScope(scopeName: 'feature');
  getIt.registerLazySingleton<FeatureService>(() => FeatureService(getIt()));

  expect(getIt<CoreService>(), isNotNull);
  expect(getIt<FeatureService>(), isNotNull);

  // Pop feature scope
  await getIt.popScope();

  expect(getIt<CoreService>(), isNotNull); // Still available
  expect(() => getIt<FeatureService>(), throwsStateError); // Gone!
});
```

### Scenario 3: Testing Disposal

```dart
class DisposableService implements Disposable {
  bool disposed = false;

  @override
  FutureOr onDispose() {
    disposed = true;
  }
}

test('services are disposed when scope is popped', () async {
  getIt.pushNewScope();

  final service = DisposableService();
  getIt.registerSingleton<DisposableService>(service);

  expect(service.disposed, false);

  await getIt.popScope();

  expect(service.disposed, true);
});
```

---

## Best Practices

### ✅ Do

1. **Use scopes for test isolation**
   ```dart
   setUp(() => getIt.pushNewScope());
   tearDown(() async => await getIt.popScope());
   ```

2. **Register real dependencies once in `setUpAll()`**
   ```dart
   setUpAll(() {
     configureDependencies(); // Same as production
   });
   ```

3. **Shadow only what you need to mock**
   ```dart
   setUp(() {
     getIt.pushNewScope();
     getIt.registerSingleton<ApiClient>(MockApiClient()); // Only mock this
     // Everything else uses real registrations from base scope
   });
   ```

4. **Await `popScope()` if services have async disposal**
   ```dart
   tearDown(() async {
     await getIt.popScope(); // Ensures cleanup completes
   });
   ```

5. **Use `allReady()` for async registrations**
   ```dart
   await getIt.allReady(); // Wait before testing
   ```

### ❌ Don't

1. **Don't call `reset()` between tests**
   ```dart
   // ❌ Bad - loses all registrations
   tearDown(() async {
     await getIt.reset();
   });

   // ✅ Good - use scopes instead
   tearDown(() async {
     await getIt.popScope();
   });
   ```

2. **Don't re-register everything in each test**
   ```dart
   // ❌ Bad - duplicates production setup
   setUp(() {
     getIt.registerLazySingleton<ApiClient>(...);
     getIt.registerLazySingleton<Database>(...);
     // ... 50 more registrations
   });

   // ✅ Good - reuse production setup
   setUpAll(() {
     configureDependencies(); // Call once
   });
   ```

3. **Don't use `allowReassignment` in tests**
   ```dart
   // ❌ Bad - masks bugs
   getIt.allowReassignment = true;

   // ✅ Good - use scopes for isolation
   ```

4. **Don't forget to pop scopes in tearDown**
   ```dart
   // ❌ Bad - scopes leak into next test
   test('...', () {
     getIt.pushNewScope();
     // ... test code
     // Missing popScope()!
   });
   ```

---

## Troubleshooting

### "Object/factory already registered" in tests

**Cause:** Scope wasn't popped in previous test, or `reset()` wasn't awaited.

**Fix:**
```dart
tearDown(() async {
  await getIt.popScope(); // Always await!
});
```

### Mocks not being used

**Cause:** Mock was registered in wrong scope or after service was already created.

**Fix:** Push scope and register mocks **before** accessing services:
```dart
setUp(() {
  getIt.pushNewScope();
  getIt.registerSingleton<ApiClient>(mockApi); // Register FIRST
});

test('test name', () {
  final service = getIt<UserService>(); // Accesses AFTER mock registered
  // ...
});
```

### Async service not ready

**Cause:** Trying to access async registration before it completes.

**Fix:**
```dart
test('async test', () async {
  await getIt.allReady(); // Wait for all async registrations
  final db = getIt<Database>();
  // ...
});
```

---

## See Also

- [Scopes](/documentation/get_it/scopes) - Detailed scope documentation
- [Object Registration](/documentation/get_it/object_registration) - Registration types
- [FAQ](/documentation/get_it/faq) - Common questions including testing