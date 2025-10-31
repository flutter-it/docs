---
title: Testing
---

# Testing

Testing code that uses get_it requires different approaches depending on whether you're writing unit tests, widget tests, or integration tests. This guide covers best practices and common patterns.

## Quick Start: The Scope Pattern (Recommended)

**Best practice:** Use **scopes** to shadow real services with test doubles. This is cleaner and more maintainable than resetting get_it or using conditional registration.


<<< @/../code_samples/lib/get_it/main_example_1.dart#example

**Key benefits:**
- Only override what you need for each test
- Automatic cleanup between tests
- Same `configureDependencies()` as production

---

## Unit Testing Patterns

### Pattern 1: Scoped Test Doubles (Recommended)

Use scopes to inject mocks for specific services while keeping the rest of your dependency graph intact.


<<< @/../code_samples/lib/get_it/main_example_2.dart#example

### Pattern 2: Constructor Injection for Pure Unit Tests

For testing classes in complete isolation (without get_it), use optional constructor parameters.


<<< @/../code_samples/lib/get_it/user_manager_example.dart#example

**When to use:**
- ✅ Testing pure business logic in isolation
- ✅ Classes that don't need the full dependency graph
- ❌ Integration-style tests where you want real dependencies

---

## Widget Testing

### Testing Widgets That Use get_it

Widgets often retrieve services from get_it. Use scopes to provide test-specific implementations.


<<< @/../code_samples/lib/get_it/main_signature.dart

### Testing with Async Registrations

If your app uses `registerSingletonAsync`, ensure async services are ready before testing.


<<< @/../code_samples/lib/get_it/code_sample_d18eeb0d_signature.dart

---

## Integration Testing

### Full App Testing with Mocked Services

For integration tests, register mocks at the top level while keeping the rest of the app real.


<<< @/../code_samples/lib/get_it/main_example_3.dart#example

### Environment-Based Registration (Alternative Pattern)

Use a flag to switch between real and test implementations. Less flexible than scopes but simpler for basic cases.


<<< @/../code_samples/lib/get_it/configure_dependencies_example_8.dart#example

**Limitations:**
- ❌ Can't switch between test/real per test
- ❌ No automatic cleanup between tests
- ❌ Must manually reset if needed

---

## Testing Factories

### Testing Factory Registrations

Factories create new instances on each `get()` call - verify this behavior in tests.


<<< @/../code_samples/lib/get_it/shopping_cart_signature_1.dart

### Testing Parameterized Factories


<<< @/../code_samples/lib/get_it/code_sample_5f4e16d1_signature.dart

---

## Common Testing Scenarios

### Scenario 1: Testing Service with Multiple Dependencies


<<< @/../code_samples/lib/get_it/api_client_signature_1.dart

### Scenario 2: Testing Scoped Services


<<< @/../code_samples/lib/get_it/code_sample_2fee2227_signature.dart

### Scenario 3: Testing Disposal


<<< @/../code_samples/lib/get_it/disposable_service_example.dart#example

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