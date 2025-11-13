---
title: Testing
---

# Testing

Testing code that uses get_it requires different approaches depending on whether you're writing unit tests, widget tests, or integration tests. This guide covers best practices and common patterns.

## Quick Start: The Scope Pattern (Recommended)

<strong>Best practice:</strong> Use <strong>scopes</strong> to shadow real services with test doubles. This is cleaner and more maintainable than resetting get_it or using conditional registration.


<<< @/../code_samples/lib/get_it/main_example_1.dart#example

<strong>Key benefits:</strong>
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

<strong>When to use:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅️ Testing pure business logic in isolation</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅️ Classes that don't need the full dependency graph</li>
</ul>
- ❌️ Integration-style tests where you want real dependencies

---

## Widget Testing

### Testing Widgets That Use get_it

Widgets often retrieve services from get_it. Use scopes to provide test-specific implementations.


<<< @/../code_samples/lib/get_it/main.dart#example

### Testing with Async Registrations

If your app uses `registerSingletonAsync`, ensure async services are ready before testing.


<<< @/../code_samples/lib/get_it/code_sample_d18eeb0d.dart#example

---

## Testing Factories

### Testing Factory Registrations

Factories create new instances on each `get()` call - verify this behavior in tests.


<<< @/../code_samples/lib/get_it/shopping_cart_1.dart#example

### Testing Parameterized Factories


<<< @/../code_samples/lib/get_it/code_sample_5f4e16d1.dart#example

---

## Common Testing Scenarios

::: details Scenario 1: Testing Service with Multiple Dependencies

<<< @/../code_samples/lib/get_it/api_client_1.dart#example
:::

::: details Scenario 2: Testing Scoped Services

<<< @/../code_samples/lib/get_it/code_sample_2fee2227.dart#example
:::

::: details Scenario 3: Testing Disposal

<<< @/../code_samples/lib/get_it/disposable_service_example.dart#example
:::

---

## Best Practices

### ✅️ Do

1. <strong>Use scopes for test isolation</strong>

   <<< @/../code_samples/lib/get_it/testing_f1b668dd_signature.dart#example

2. <strong>Register real dependencies once in `setUpAll()`</strong>

   <<< @/../code_samples/lib/get_it/testing_c8fe4e9b_signature.dart#example

3. <strong>Shadow only what you need to mock</strong>

   <<< @/../code_samples/lib/get_it/testing_8dbacaca_signature.dart#example

4. <strong>Await `popScope()` if services have async disposal</strong>

   <<< @/../code_samples/lib/get_it/testing_93df6902_signature.dart#example

5. <strong>Use `allReady()` for async registrations</strong>

   <<< @/../code_samples/lib/get_it/testing_cc70be3d.dart#example

### ❌️ Don't

1. <strong>Don't call `reset()` between tests</strong>

   <<< @/../code_samples/lib/get_it/testing_0a7443ea.dart#example

2. <strong>Don't re-register everything in each test</strong>

   <<< @/../code_samples/lib/get_it/testing_138c49df_signature.dart#example

3. <strong>Don't use `allowReassignment` in tests</strong>

   <<< @/../code_samples/lib/get_it/testing_a862f724_signature.dart#example

4. <strong>Don't forget to pop scopes in tearDown</strong>

   <<< @/../code_samples/lib/get_it/testing_4bac3b7c_signature.dart#example


---

## Troubleshooting

### "Object/factory already registered" in tests


<strong>Cause:</strong> Scope wasn't popped in previous test, or `reset()` wasn't awaited.

<strong>Fix:</strong>

<<< @/../code_samples/lib/get_it/testing_ac521152_signature.dart#example


### Mocks not being used

<strong>Cause:</strong> Mock was registered in wrong scope or after service was already created.

<strong>Fix:</strong> Push scope and register mocks <strong>before</strong> accessing services:

<<< @/../code_samples/lib/get_it/testing_78522d78_signature.dart#example


### Async service not ready

<strong>Cause:</strong> Trying to access async registration before it completes.

<strong>Fix:</strong>

<<< @/../code_samples/lib/get_it/testing_9153fb06_signature.dart#example


---

## See Also

- [Scopes](/documentation/get_it/scopes) - Detailed scope documentation
- [Object Registration](/documentation/get_it/object_registration) - Registration types
