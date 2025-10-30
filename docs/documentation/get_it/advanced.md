---
title: Advanced
---

# Advanced

#### Implementing the `Disposable` interface

Instead of passing a disposing function on registration or when pushing a Scope from V7.0 on your objects `onDispose()` method will be called
if the object that you register implements the `Disposable` interface:

```dart
abstract class Disposable {
  FutureOr onDispose();
}
```

---

## Reference Counting

Reference counting helps manage singleton lifecycle when multiple consumers might need the same instance, especially useful for recursive scenarios like navigation.

### The Problem

Imagine a detail page that can be pushed recursively (e.g., viewing related items, navigating through a hierarchy):

```
Home → DetailPage(item1) → DetailPage(item2) → DetailPage(item3)
```

Without reference counting:
- First DetailPage registers `DetailService`
- Second DetailPage tries to register → Error or must skip registration
- First DetailPage pops, disposes service → Breaks remaining pages

### The Solution: `registerSingletonIfAbsent` and `releaseInstance`

```dart
T registerSingletonIfAbsent<T>(
  T Function() factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
})

void releaseInstance(Object instance)
```

**How it works:**
1. First call: Creates instance, registers, sets reference count to 1
2. Subsequent calls: Returns existing instance, increments counter
3. `releaseInstance`: Decrements counter
4. When counter reaches 0: Unregisters and disposes

### Recursive Navigation Example

```dart
class DetailService extends ChangeNotifier {
  final String itemId;
  String? data;
  bool isLoading = false;

  DetailService(this.itemId) {
    // Trigger async loading in constructor (fire and forget)
    _loadData();
  }

  Future<void> _loadData() async {
    if (data != null) return; // Already loaded

    isLoading = true;
    notifyListeners();

    print('Loading data for $itemId from backend...');
    // Simulate backend call
    await Future.delayed(Duration(seconds: 1));
    data = 'Data for $itemId';

    isLoading = false;
    notifyListeners();
  }
}

class DetailPage extends WatchingWidget {
  final String itemId;
  const DetailPage(this.itemId);

  @override
  Widget build(BuildContext context) {
    // Register once when widget is created - increments reference count
    // Service created synchronously, constructor triggers async loading
    callOnce(() {
      getIt.registerSingletonIfAbsent<DetailService>(
        () => DetailService(itemId),
        instanceName: itemId,
      );
    });

    // Register disposal handler - decrements reference count when widget disposes
    registerHandler(() {
      getIt.releaseInstance(getIt<DetailService>(instanceName: itemId));
    });

    // Watch the service - rebuilds when notifyListeners() called
    final service = watchIt<DetailService>(instanceName: itemId);

    return Scaffold(
      appBar: AppBar(title: Text('Detail $itemId')),
      body: service.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text(service.data ?? 'No data'),
                ElevatedButton(
                  onPressed: () {
                    // Can push same page recursively
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage('related-$itemId'),
                      ),
                    );
                  },
                  child: Text('View Related'),
                ),
              ],
            ),
    );
  }
}
```

**Flow:**
```
Push DetailPage(item1)      → Create service, load data, refCount = 1
  Push DetailPage(item2)    → Create service, load data, refCount = 1
    Push DetailPage(item1)  → Get existing (NO reload!), refCount = 2
    Pop DetailPage(item1)   → Release, refCount = 1 (service stays)
  Pop DetailPage(item2)     → Release, refCount = 0 (service disposed)
Pop DetailPage(item1)       → Release, refCount = 0 (service disposed)
```

**Benefits:**
- ✅ Service created synchronously (no async factory needed)
- ✅ Async loading triggered in constructor
- ✅ No duplicate loading for same item (checked before loading)
- ✅ Automatic memory management via reference counting
- ✅ Reactive UI updates via watch_it (rebuilds on state changes)
- ✅ ChangeNotifier automatically disposed when refCount reaches 0
- ✅ Each itemId uniquely identified via `instanceName`

**Key Integration:**
This example demonstrates how **get_it** (reference counting) and **watch_it** (reactive UI) work together seamlessly for complex navigation patterns.

### Nested Scope Example

```dart
class FeatureManager {
  void enterFeature(String featureId) {
    getIt.pushNewScope(scopeName: 'feature-$featureId');

    // Register shared resource with reference counting
    final cache = getIt.registerSingletonIfAbsent<FeatureCache>(
      () => FeatureCache(),
      dispose: (cache) => cache.clear(),
    );

    cache.loadFeatureData(featureId);
  }

  void exitFeature() async {
    // Release reference before popping scope
    if (getIt.isRegistered<FeatureCache>()) {
      getIt.releaseInstance(getIt<FeatureCache>());
    }
    await getIt.popScope();
  }
}

// Multiple features can share the cache
featureManager.enterFeature('feature-a');  // refCount = 1
featureManager.enterFeature('feature-b');  // refCount = 2
featureManager.exitFeature();              // refCount = 1 (cache stays)
featureManager.exitFeature();              // refCount = 0 (cache disposed)
```

### Force Release: `ignoreReferenceCount`

In rare cases, you might need to force unregister regardless of reference count:

```dart
// Force unregister even if refCount > 0
getIt.unregister<MyService>(ignoreReferenceCount: true);
```

::: warning Use with Caution
Only use `ignoreReferenceCount: true` when you're certain no other code is using the instance. This can cause crashes if other parts of your app still hold references.
:::

### When to Use Reference Counting

✅ **Good use cases:**
- Recursive navigation (same page pushed multiple times)
- Shared resources across nested scopes
- Services needed by multiple simultaneously active features
- Complex hierarchical component structures

❌ **Don't use when:**
- Simple singleton that lives for app lifetime (use regular `registerSingleton`)
- One-to-one widget-service relationship (use scopes)
- Testing (use scopes to shadow instead)

### Best Practices

1. **Always pair register with release**: Every `registerSingletonIfAbsent` should have a matching `releaseInstance`
2. **Store instance reference**: Keep the returned instance so you can release the correct one
3. **Release in dispose/cleanup**: Tie release to widget/component lifecycle
4. **Document shared resources**: Make it clear when a service uses reference counting

---

## Utility Methods

### Safe Retrieval: `maybeGet<T>()`

Returns `null` instead of throwing an exception if the type is not registered. Useful for optional dependencies and feature flags.

```dart
T? maybeGet<T>({
  String? instanceName,
  dynamic param1,
  dynamic param2,
  Type? type,
})
```

**Example:**

```dart
// Feature flag scenario
final analyticsService = getIt.maybeGet<AnalyticsService>();
if (analyticsService != null) {
  analyticsService.trackEvent('user_action');
}

// Optional dependency
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logger = getIt.maybeGet<Logger>();
    logger?.log('Building MyWidget'); // Safe even if Logger not registered

    return Text('Hello');
  }
}

// Graceful degradation
final premiumFeature = getIt.maybeGet<PremiumFeature>();
if (premiumFeature != null) {
  return PremiumUI(feature: premiumFeature);
} else {
  return BasicUI(); // Fallback when premium not available
}
```

**When to use:**
- ✅ Optional features that may or may not be registered
- ✅ Feature flags (service registered only when feature enabled)
- ✅ Platform-specific services (might not exist on all platforms)
- ✅ Graceful degradation scenarios

**Don't use when:**
- ❌ The dependency is required - use `get<T>()` to fail fast
- ❌ Missing registration indicates a bug - exception is helpful

---

### Instance Renaming: `changeTypeInstanceName()`

Rename a registered instance without unregistering and re-registering (avoids triggering dispose functions).

```dart
void changeTypeInstanceName<T>({
  String? instanceName,
  required String newInstanceName,
  T? instance,
})
```

**Example:**

```dart
// Register with temporary name
getIt.registerSingleton<UserSession>(
  UserSession(),
  instanceName: 'temp-session',
);

// Later, rename to permanent name (e.g., after authentication)
getIt.changeTypeInstanceName<UserSession>(
  instanceName: 'temp-session',
  newInstanceName: 'authenticated-session',
);

// Now accessible with new name
final session = getIt<UserSession>(instanceName: 'authenticated-session');
```

**Use cases:**
- Dynamic naming schemes based on runtime conditions
- Promoting temporary registrations to permanent ones
- Avoiding disposal side effects from unregister/register cycle
- Complex scope hierarchies with name-based lookups

::: tip Avoids Dispose
Unlike `unregister()` + `register()`, this doesn't trigger dispose functions, preserving the instance's state.
:::

---

### Lazy Singleton Introspection: `checkLazySingletonInstanceExists()`

Check if a lazy singleton has been instantiated yet (without triggering its creation).

```dart
bool checkLazySingletonInstanceExists<T>({
  String? instanceName,
})
```

**Example:**

```dart
// Register lazy singleton
getIt.registerLazySingleton<HeavyService>(() => HeavyService());

// Check if it's been created yet
if (getIt.checkLazySingletonInstanceExists<HeavyService>()) {
  print('HeavyService already created');
} else {
  print('HeavyService not created yet - will be lazy loaded');
}

// Access triggers creation
final service = getIt<HeavyService>();

// Now it exists
assert(getIt.checkLazySingletonInstanceExists<HeavyService>() == true);
```

**Use cases:**
- Performance monitoring (track which services have been initialized)
- Conditional initialization (pre-warm services if not created)
- Testing lazy loading behavior
- Debugging initialization order issues

**Example - Pre-warming:**

```dart
void preWarmCriticalServices() {
  // Only initialize if not already created
  if (!getIt.checkLazySingletonInstanceExists<DatabaseService>()) {
    getIt<DatabaseService>(); // Trigger creation
  }

  if (!getIt.checkLazySingletonInstanceExists<CacheService>()) {
    getIt<CacheService>(); // Trigger creation
  }
}
```

---

### Advanced Introspection: `findFirstObjectRegistration<T>()`

Get metadata about a registration without retrieving the instance.

```dart
ObjectRegistration? findFirstObjectRegistration<T>({
  Object? instance,
  String? instanceName,
})
```

**Example:**

```dart
final registration = getIt.findFirstObjectRegistration<MyService>();

if (registration != null) {
  print('Type: ${registration.registrationType}'); // factory, singleton, lazy, etc.
  print('Instance name: ${registration.instanceName}');
  print('Is async: ${registration.isAsync}');
  print('Is ready: ${registration.isReady}');
}
```

**Use cases:**
- Building tools/debugging utilities on top of GetIt
- Runtime dependency graph visualization
- Advanced lifecycle management
- Debugging registration issues

---

### Named registration

Ok, you have been warned! All registration functions have an optional named parameter `instanceName`. Providing a name with factory/singleton here registers that instance with that name and a type. Consequently `get()` has also an optional parameter `instanceName` to access
factories/singletons that were registered by name.

**IMPORTANT:** Each name must be unique per type.

```dart
  abstract class RestService {}
  class RestService1 implements RestService{
    Future<RestService1> init() async {
      Future.delayed(Duration(seconds: 1));
      return this;
    }
  }
  class RestService2 implements RestService{
    Future<RestService2> init() async {
      Future.delayed(Duration(seconds: 1));
      return this;
    }
  }

  getIt.registerSingletonAsync<RestService>(() async => RestService1().init(), instanceName : "restService1");
  getIt.registerSingletonAsync<RestService>(() async => RestService2().init(), instanceName : "restService2");

  getIt.registerSingletonWithDependencies<AppModel>(
      () {
          RestService restService1 = GetIt.I.get<RestService>(instanceName: "restService1");
          return AppModelImplmentation(restService1);
      },
      dependsOn: [InitDependency(RestService, instanceName:"restService1")],
  );
```

### Accessing an object inside GetIt by a runtime type

In rare occasions you might be faced with the problem that you don't know the type that you want to retrieve from GetIt at compile time which means you can't pass it as a generic parameter. For this the `get` functions have an optional `type` parameter

```dart
    getIt.registerSingleton(TestClass());

    final instance1 = getIt.get(type: TestClass);

    expect(instance1 is TestClass, true);
```

Be careful that the receiving variable has the correct type and don't pass `type` and a generic parameter.

### More than one instance of GetIt

While not recommended, you can create your own independent instance of `GetIt` if you don't want to share your locator with some
other package or because the physics of your planet demands it :-)

```dart
/// To make sure you really know what you are doing
/// you have to first enable this feature:
GetIt myOwnInstance = GetIt.asNewInstance();
```

This new instance does not share any registrations with the singleton instance.
