# Advanced Integration

Advanced patterns for integrating watch_it with get_it, including scopes, named instances, async initialization, and multi-package coordination.

## get_it Scopes with pushScope

Scopes allow you to create temporary registrations that are automatically cleaned up when a widget is disposed. Perfect for feature-specific dependencies or screen-level state.

### What are Scopes?

get_it scopes create isolated registration contexts:
- **Push a scope** - Create new registration context
- **Register in scope** - Dependencies only live in that scope
- **Pop the scope** - All scoped registrations are disposed

### pushScope() - Automatic Scope Management

`pushScope()` creates a scope when the widget mounts and automatically cleans it up on dispose:

```dart
class UserProfileScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Create scope on first build
    pushScope(
      init: (scope) {
        // Register screen-specific dependencies
        scope.registerLazySingleton<ProfileManager>(
          () => ProfileManager(userId: '123'),
        );
        scope.registerLazySingleton<EditController>(
          () => EditController(),
        );
      },
      dispose: () {
        // Cleanup when scope is popped (widget disposed)
        print('Profile screen scope disposed');
      },
    );

    // Use scoped dependencies
    final profile = watchValue((ProfileManager m) => m.profile);

    return YourUI();
  }
}
```

**What happens:**
1. Widget builds first time → Scope is pushed, `init` callback runs
2. Dependencies registered in new scope
3. Widget can watch scoped dependencies
4. Widget disposes → Scope is automatically popped, `dispose` callback runs
5. All scoped registrations are cleaned up

### Use Cases for Scopes

#### 1. Screen-Specific State

```dart
class ProductDetailScreen extends WatchingWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (scope) {
        // Register screen-specific manager
        scope.registerLazySingleton<ProductDetailManager>(
          () => ProductDetailManager(productId: productId),
        );
      },
    );

    final product = watchValue((ProductDetailManager m) => m.product);
    final isLoading = watchValue((ProductDetailManager m) => m.isLoading);

    if (isLoading) return CircularProgressIndicator();
    return ProductDetailView(product: product);
  }
}
```

#### 2. Feature Modules

```dart
class CheckoutFlow extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (scope) {
        // Register all checkout-related services
        scope.registerLazySingleton<CartManager>(() => CartManager());
        scope.registerLazySingleton<PaymentService>(() => PaymentService());
        scope.registerLazySingleton<ShippingService>(() => ShippingService());
      },
      dispose: () {
        print('Checkout flow completed, cleaning up');
      },
    );

    return CheckoutStepper();
  }
}
```

#### 3. User Session State

```dart
class AuthenticatedApp extends WatchingWidget {
  final User user;

  AuthenticatedApp({required this.user});

  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (scope) {
        // User-specific services
        scope.registerLazySingleton<UserManager>(
          () => UserManager(user),
        );
        scope.registerLazySingleton<UserPreferences>(
          () => UserPreferences(userId: user.id),
        );
      },
      dispose: () {
        // User logged out, clean up user-specific state
        print('User session ended');
      },
    );

    return HomeScreen();
  }
}
```

### Scope Best Practices

**✅ DO:**
- Use scopes for screen/feature-specific dependencies
- Clean up resources in `dispose` callback
- Keep scopes focused and short-lived

**❌ DON'T:**
- Use scopes for app-wide singletons (use global registration)
- Create deeply nested scopes (keeps things simple)
- Register the same type in multiple scopes (use named instances instead)

## Named Instances

Watch specific named instances from get_it:

### Registering Named Instances

```dart
void setupDependencies() {
  // Register multiple instances of same type with different names
  di.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: 'https://api.prod.com'),
    instanceName: 'production',
  );

  di.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: 'https://api.staging.com'),
    instanceName: 'staging',
  );

  di.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: 'http://localhost:3000'),
    instanceName: 'development',
  );
}
```

### Watching Named Instances

```dart
class ApiMonitor extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch specific named instances
    final prodApi = watchValue(
      (ApiClient api) => api.requestCount,
      instanceName: 'production',
    );

    final stagingApi = watchValue(
      (ApiClient api) => api.requestCount,
      instanceName: 'staging',
    );

    return Column(
      children: [
        Text('Production: $prodApi requests'),
        Text('Staging: $stagingApi requests'),
      ],
    );
  }
}
```

### Environment-Specific Configuration

```dart
class AppConfig {
  static const environment = String.fromEnvironment('ENV', defaultValue: 'development');

  static void setup() {
    di.registerLazySingleton<ApiClient>(
      () => ApiClient(baseUrl: _getBaseUrl()),
      instanceName: environment,
    );
  }

  static String _getBaseUrl() {
    switch (environment) {
      case 'production':
        return 'https://api.prod.com';
      case 'staging':
        return 'https://api.staging.com';
      default:
        return 'http://localhost:3000';
    }
  }
}

// Usage
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue(
      (ApiClient api) => api.data,
      instanceName: AppConfig.environment,
    );

    return DataDisplay(data);
  }
}
```

## Async Initialization with isReady and allReady

Handle complex initialization scenarios where multiple async dependencies must be ready before the app starts.

### isReady - Single Dependency

Check if a specific async dependency is ready:

```dart
void setupDependencies() async {
  // Register async singleton
  di.registerSingletonAsync<Database>(
    () async {
      final db = Database();
      await db.initialize();
      return db;
    },
  );
}

class App extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Check if ready
    final ready = isReady<Database>();

    if (!ready) {
      return SplashScreen();
    }

    return MainApp();
  }
}
```

### allReady - Multiple Dependencies

Wait for all async dependencies to complete:

```dart
void setupDependencies() async {
  di.registerSingletonAsync<Database>(() async {
    final db = Database();
    await db.initialize();
    return db;
  });

  di.registerSingletonAsync<ConfigService>(() async {
    final config = ConfigService();
    await config.load();
    return config;
  });

  di.registerSingletonAsync<AuthService>(
    () async {
      final auth = AuthService();
      await auth.initialize();
      return auth;
    },
    dependsOn: [Database],  // Waits for Database first
  );
}

class App extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Wait for all async singletons
    final ready = allReady(
      timeout: Duration(seconds: 30),
      ignorePendingAsyncCreation: false,
    );

    if (!ready) {
      return SplashScreen();
    }

    return MainApp();
  }
}
```

### Watching Initialization Progress

```dart
class InitializationScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final dbReady = isReady<Database>();
    final configReady = isReady<ConfigService>();
    final authReady = isReady<AuthService>();

    final progress = [dbReady, configReady, authReady]
        .where((ready) => ready)
        .length / 3;

    if (dbReady && configReady && authReady) {
      // All ready, navigate to main app
      callOnce((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainApp()),
        );
      });
    }

    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        Text('Initializing... ${(progress * 100).toInt()}%'),
        if (dbReady) Text('✓ Database ready'),
        if (configReady) Text('✓ Configuration loaded'),
        if (authReady) Text('✓ Authentication ready'),
      ],
    );
  }
}
```

## Custom GetIt Instances

Use multiple GetIt instances for different contexts:

```dart
// Global app dependencies
final appDI = GetIt.instance;

// Test-specific dependencies
final testDI = GetIt.asNewInstance();

// Feature module dependencies
final featureDI = GetIt.asNewInstance();

// Setup
void setupApp() {
  appDI.registerLazySingleton<ApiClient>(() => ApiClient());
  appDI.registerLazySingleton<Database>(() => Database());
}

void setupFeature() {
  featureDI.registerLazySingleton<FeatureManager>(() => FeatureManager());
}

// Usage in widgets
class FeatureWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch from specific GetIt instance
    final data = watchValue(
      (FeatureManager m) => m.data,
      getIt: featureDI,  // Use feature-specific instance
    );

    return YourUI();
  }
}
```

## Multi-Package Integration

Coordinate watch_it across multiple packages in a monorepo or modular app.

### Package Structure

```
app/
├── core_package/
│   └── lib/
│       └── managers/
│           └── auth_manager.dart
├── feature_a/
│   └── lib/
│       └── managers/
│           └── feature_a_manager.dart
└── main_app/
    └── lib/
        └── main.dart
```

### Core Package Setup

```dart
// core_package/lib/core_package.dart
export 'managers/auth_manager.dart';

class CorePackage {
  static void register(GetIt di) {
    di.registerLazySingleton<AuthManager>(() => AuthManager());
    di.registerLazySingleton<ApiClient>(() => ApiClient());
  }
}
```

### Feature Package Setup

```dart
// feature_a/lib/feature_a.dart
export 'managers/feature_a_manager.dart';

class FeatureA {
  static void register(GetIt di) {
    // Depends on CorePackage being registered first
    di.registerLazySingleton<FeatureAManager>(
      () => FeatureAManager(
        auth: di<AuthManager>(),  // From core package
        api: di<ApiClient>(),
      ),
    );
  }
}
```

### Main App Integration

```dart
// main_app/lib/main.dart
import 'package:core_package/core_package.dart';
import 'package:feature_a/feature_a.dart';

void main() {
  // Register all packages
  CorePackage.register(di);
  FeatureA.register(di);

  runApp(MyApp());
}

class FeatureAScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Can watch dependencies from any package
    final user = watchValue((AuthManager m) => m.user);  // From core
    final data = watchValue((FeatureAManager m) => m.data);  // From feature_a

    return YourUI();
  }
}
```

### Package Registration Order

```dart
void setupDependencies() {
  // Order matters for dependencies!

  // 1. Core dependencies first
  CorePackage.register(di);

  // 2. Feature packages (depend on core)
  FeatureA.register(di);
  FeatureB.register(di);

  // 3. App-level dependencies (depend on everything)
  AppPackage.register(di);
}
```

## Integration Patterns

### Pattern 1: Lazy Module Loading

```dart
class FeatureLoader extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((_) {
      // Load feature module on demand
      pushScope(
        init: (scope) {
          FeatureModule.register(scope);
        },
      );
    });

    final ready = isReady<FeatureManager>();

    if (!ready) return CircularProgressIndicator();
    return FeatureUI();
  }
}
```

### Pattern 2: A/B Testing with Named Instances

```dart
void setupABTest() {
  final variant = Random().nextBool() ? 'A' : 'B';

  di.registerLazySingleton<CheckoutFlow>(
    () => variant == 'A' ? CheckoutFlowA() : CheckoutFlowB(),
    instanceName: 'current',
  );
}

class CheckoutScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final flow = watchIt<CheckoutFlow>(
      instanceName: 'current',
    );

    return flow.buildUI();
  }
}
```

### Pattern 3: Hot Swap Dependencies

```dart
class DebugPanel extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Unregister old
        di.unregister<ApiClient>();

        // Register new
        di.registerLazySingleton<ApiClient>(
          () => MockApiClient(),  // Swap to mock
        );

        // Widgets watching ApiClient will rebuild
      },
      child: Text('Switch to Mock API'),
    );
  }
}
```

## Advanced Patterns

### Global State Reset

```dart
class AppResetButton extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Reset all scopes
        await di.reset();

        // Re-register dependencies
        setupDependencies();

        // Navigate to fresh start
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      },
      child: Text('Reset App'),
    );
  }
}
```

### Dependency Injection Testing

```dart
void main() {
  setUp(() {
    // Reset get_it before each test
    di.reset();

    // Register mocks
    di.registerLazySingleton<AuthManager>(
      () => MockAuthManager(),
    );
  });

  testWidgets('shows user name', (tester) async {
    final mockAuth = di<AuthManager>() as MockAuthManager;
    mockAuth.user.value = User(name: 'Test User');

    await tester.pumpWidget(
      MaterialApp(home: UserProfile()),
    );

    expect(find.text('Test User'), findsOneWidget);
  });
}
```

## See Also

- [get_it Scopes Documentation](/documentation/get_it/scopes.md) - Detailed scope information
- [get_it Async Objects](/documentation/get_it/async_objects.md) - Async initialization
- [Best Practices](/documentation/watch_it/best_practices.md) - General best practices
- [Testing](/documentation/get_it/testing.md) - Testing with get_it
