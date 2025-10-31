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


<<< @/../code_samples/lib/get_it/main.dart

### Testing with Async Registrations

If your app uses `registerSingletonAsync`, ensure async services are ready before testing.


<<< @/../code_samples/lib/get_it/code_sample_d18eeb0d.dart

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


<<< @/../code_samples/lib/get_it/shopping_cart_1.dart

### Testing Parameterized Factories


<<< @/../code_samples/lib/get_it/code_sample_5f4e16d1.dart

---

## Common Testing Scenarios

### Scenario 1: Testing Service with Multiple Dependencies


<<< @/../code_samples/lib/get_it/api_client_1.dart

### Scenario 2: Testing Scoped Services


<<< @/../code_samples/lib/get_it/code_sample_2fee2227.dart

### Scenario 3: Testing Disposal


<<< @/../code_samples/lib/get_it/disposable_service_example.dart#example

---

## Best Practices

### ✅ Do

1. **Use scopes for test isolation**
   <<< @/../code_samples/lib/get_it/testing_f1b668dd_signature.dart


2. **Register real dependencies once in `setUpAll()`**
   <<< @/../code_samples/lib/get_it/testing_c8fe4e9b_signature.dart


3. **Shadow only what you need to mock**
   <<< @/../code_samples/lib/get_it/testing_8dbacaca_signature.dart


4. **Await `popScope()` if services have async disposal**
   <<< @/../code_samples/lib/get_it/testing_93df6902_signature.dart


5. **Use `allReady()` for async registrations**
   <<< @/../code_samples/lib/get_it/testing_cc70be3d.dart


### ❌ Don't

1. **Don't call `reset()` between tests**
   <<< @/../code_samples/lib/get_it/testing_0a7443ea.dart


2. **Don't re-register everything in each test**
   <<< @/../code_samples/lib/get_it/testing_138c49df_signature.dart


3. **Don't use `allowReassignment` in tests**
   <<< @/../code_samples/lib/get_it/testing_a862f724_signature.dart


4. **Don't forget to pop scopes in tearDown**
   <<< @/../code_samples/lib/get_it/testing_4bac3b7c_signature.dart


---

## Troubleshooting

### "Object/factory already registered" in tests

**Cause:** Scope wasn't popped in previous test, or `reset()` wasn't awaited.

**Fix:**
<<< @/../code_samples/lib/get_it/testing_ac521152_signature.dart


### Mocks not being used

**Cause:** Mock was registered in wrong scope or after service was already created.

**Fix:** Push scope and register mocks **before** accessing services:
<<< @/../code_samples/lib/get_it/testing_78522d78_signature.dart


### Async service not ready

**Cause:** Trying to access async registration before it completes.

**Fix:**
<<< @/../code_samples/lib/get_it/testing_9153fb06_signature.dart


---

## See Also

- [Scopes](/documentation/get_it/scopes) - Detailed scope documentation
- [Object Registration](/documentation/get_it/object_registration) - Registration types
- [FAQ](/documentation/get_it/faq) - Common questions including testing