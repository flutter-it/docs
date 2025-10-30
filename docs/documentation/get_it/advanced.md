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

Imagine a page that registers a service when pushed, but this page can be pushed recursively (e.g., showing details of related items):

```
Home → DetailPage(item1) → DetailPage(item2) → DetailPage(item3)
```

Without reference counting:
- First DetailPage registers `DetailService`
- Second DetailPage tries to register → Error or overwrite
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
1. First call: Registers singleton and sets reference count to 1
2. Subsequent calls: Returns existing instance and increments counter
3. `releaseInstance`: Decrements counter
4. When counter reaches 0: Unregisters and disposes

### Recursive Navigation Example

```dart
class DetailPage extends StatefulWidget {
  final String itemId;
  DetailPage(this.itemId);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late DetailService _service;

  @override
  void initState() {
    super.initState();

    // Register or get existing - increments reference count
    _service = getIt.registerSingletonIfAbsent<DetailService>(
      () => DetailService(),
      dispose: (service) => service.cleanup(),
    );

    _service.loadDetails(widget.itemId);
  }

  @override
  void dispose() {
    // Decrements reference count, disposes only when reaching 0
    getIt.releaseInstance(_service);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail ${widget.itemId}')),
      body: Column(
        children: [
          Text(_service.data),
          ElevatedButton(
            onPressed: () {
              // Can push same page recursively
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage('related-item'),
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
Push DetailPage(1)   → register, refCount = 1
  Push DetailPage(2) → get existing, refCount = 2
    Push DetailPage(3) → get existing, refCount = 3
    Pop DetailPage(3)  → release, refCount = 2 (service stays)
  Pop DetailPage(2)    → release, refCount = 1 (service stays)
Pop DetailPage(1)      → release, refCount = 0 (service disposed)
```

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
