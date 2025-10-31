---
title: Getting started with get_it
prev:
  text: 'What to do with which package'
  link: '/getting_started/what_to_do_with_which_package'
next:
  text: 'Object Registration'
  link: '/documentation/get_it/object_registration'
---

# Getting Started

**get_it** is a simple, fast service locator for Dart and Flutter that allows you to access any object that you register from anywhere in your app without needing `BuildContext` or complex widget trees.

**Key benefits:**
- ✅ **Extremely fast** - O(1) lookup using Dart's Map
- ✅ **Easy to test** - Switch implementations for mocks in tests
- ✅ **No BuildContext needed** - Access from anywhere in your app (UI, business logic, anywhere)
- ✅ **Type safe** - Compile-time type checking
- ✅ **No code generation** - Works without build_runner

**Common use cases:**
- Access services like API clients, databases, or authentication from anywhere
- Manage app-wide state (view models, managers, BLoCs)
- Easily swap implementations for testing

---

## Installation

Add get_it to your `pubspec.yaml`:

```yaml
dependencies:
  get_it: ^8.3.0  # Check pub.dev for latest version
```

---

## Quick Example

**Step 1:** Create a global GetIt instance (typically in a separate file):

```dart
// lib/service_locator.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Register your services
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
```

**Step 2:** Call your configuration function **before** `runApp()`:

```dart
// lib/main.dart
void main() {
  configureDependencies();  // Register all services FIRST
  runApp(MyApp());
}
```

**Step 3:** Access your services from anywhere:

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Access service from anywhere - no BuildContext needed!
        await getIt<AuthService>().login(username, password);
      },
      child: Text('Login'),
    );
  }
}
```

**That's it!** No Provider wrappers, no InheritedWidgets, no BuildContext needed.

::: warning Isolate Safety
GetIt instances are not thread-safe and cannot be shared across isolates. Each isolate will get its own GetIt instance. This means objects registered in one isolate can't be accessed from another isolate.
:::

---

## When to Use Which Registration Type

get_it offers three main registration types:

| Registration Type | When Created | Lifetime | Use When |
|-------------------|--------------|----------|----------|
| **registerSingleton** | Immediately | Permanent | Service needed at startup, fast to create |
| **registerLazySingleton** | First access | Permanent | Service not always needed, expensive to create |
| **registerFactory** | Every `get()` call | Temporary | Need new instance each time (dialogs, temp objects) |

**Examples:**

```dart
void configureDependencies() {
  // Singleton - created immediately, used for entire app lifetime
  getIt.registerSingleton<Logger>(Logger());

  // LazySingleton - created on first use, used for entire app lifetime
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Factory - new instance every time you call getIt<ShoppingCart>()
  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());
}
```

**Best practice:** Use `registerSingleton()` if your object will be used anyway and doesn't require significant resources to create - it's the simplest approach. Only use `registerLazySingleton()` when you need to delay expensive initialization or for services not always needed.

---

## Registering Concrete Classes vs Interfaces

**Most of the time, register your concrete classes directly:**

```dart
void configureDependencies() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<UserRepository>(UserRepository());
}

// Access directly
final api = getIt<ApiClient>();
```

This is simpler and makes IDE navigation to implementation easier.

**Only use abstract interfaces when you expect multiple implementations:**

```dart
// Use interface when you have multiple versions
abstract class PaymentProcessor {
  Future<void> processPayment(double amount);
}

class StripePaymentProcessor implements PaymentProcessor { ... }
class PayPalPaymentProcessor implements PaymentProcessor { ... }

// Register by interface
void configureDependencies() {
  getIt.registerSingleton<PaymentProcessor>(StripePaymentProcessor());
}
```

**When to use interfaces:**
- ✅ Multiple implementations (production vs test, different providers)
- ✅ Platform-specific implementations (mobile vs web)
- ✅ Feature flags to switch implementations
- ❌ Don't use "just because" - creates navigation friction in your IDE

---

## Accessing Services

Get your registered services using `getIt<Type>()`:

```dart
// Access services
final api = getIt<ApiClient>();
final db = getIt<Database>();
final auth = getIt<AuthService>();

// Use them
await api.fetchData();
await db.save(data);
final user = await auth.login('alice', 'secret');
```

::: tip Shorthand Syntax
`getIt<Type>()` is shorthand for `getIt.get<Type>()`. Both work the same - use whichever you prefer!
:::

---

## Organizing Your Setup Code

For larger apps, split registration into logical groups:

```dart
void configureDependencies() {
  _registerCoreServices();
  _registerDataServices();
  _registerBusinessLogic();
}

void _registerCoreServices() {
  getIt.registerLazySingleton<Logger>(() => Logger());
  getIt.registerLazySingleton<Analytics>(() => Analytics());
}

void _registerDataServices() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
}

void _registerBusinessLogic() {
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt(), getIt()));
}
```

See [Where should I put my get_it setup code?](/documentation/get_it/faq#where-should-i-put-my-get-it-setup-code) for more patterns.

---

## Next Steps

Now that you understand the basics, explore these topics:

**Core Concepts:**
- [Object Registration](/documentation/get_it/object_registration) - All registration types in detail
- [Scopes](/documentation/get_it/scopes) - Manage service lifetime for login/logout, features
- [Async Objects](/documentation/get_it/async_objects) - Handle services with async initialization
- [Testing](/documentation/get_it/testing) - Test your code that uses get_it

**Advanced Features:**
- [Multiple Registrations](/documentation/get_it/multiple_registrations) - Plugin systems, observers, middleware
- [Advanced Patterns](/documentation/get_it/advanced) - Named instances, reference counting, utilities

**Help:**
- [FAQ](/documentation/get_it/faq) - Common questions and troubleshooting
- [Examples](/examples/get_it/get_it) - Real-world code examples

---

## Why get_it?

<details>
<summary>Click to learn about the motivation behind get_it</summary>

As your app grows, you need to separate business logic from UI code. This makes your code easier to test and maintain. But how do you access these services from your widgets?

**Traditional approaches and their limitations:**

**InheritedWidget / Provider:**
- ❌ Requires `BuildContext` (not available in business layer)
- ❌ Adds complexity to widget tree
- ❌ Hard to access from background tasks, isolates

**Plain Singletons:**
- ❌ Can't swap implementation for tests
- ❌ Tight coupling to concrete classes
- ❌ No lifecycle management

**IoC/DI Containers:**
- ❌ Slow startup (reflection-based)
- ❌ "Magic" - hard to understand where objects come from
- ❌ Most don't work with Flutter (no reflection)

**get_it solves these problems:**
- ✅ Access from anywhere without BuildContext
- ✅ Easy to mock for tests (register interface, swap implementation)
- ✅ Extremely fast (no reflection, just Map lookup)
- ✅ Clear and explicit (you see exactly what's registered)
- ✅ Lifecycle management (scopes, disposal)
- ✅ Works in pure Dart and Flutter

**Service Locator pattern:**

get_it implements the Service Locator pattern - it decouples interface (abstract class) from concrete implementation while allowing access from anywhere.

For deeper understanding, read Martin Fowler's classic article: [Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html)

</details>

---

## Naming Your GetIt Instance

The standard pattern is to create a global variable:

```dart
final getIt = GetIt.instance;
```

**Alternative names you might see:**
- `final sl = GetIt.instance;` (service locator)
- `final locator = GetIt.instance;`
- `final di = GetIt.instance;` (dependency injection)
- `GetIt.instance` or `GetIt.I` (use directly without variable)

**Recommendation:** Use `getIt` or `di` - both are clear and widely recognized in the Flutter community.

::: tip Using with watch_it
If you're using the [watch_it](https://pub.dev/packages/watch_it) package, you already have a global `di` instance available - no need to create your own. Just import watch_it and use `di` directly.
:::

::: tip Cross-Package Usage
`GetIt.instance` returns the same singleton across all packages in your project. Create your global variable once in your main app and import it elsewhere.
:::