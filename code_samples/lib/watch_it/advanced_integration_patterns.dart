// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, unused_element, dead_code, use_key_in_widget_constructors, prefer_const_constructors_in_immutables
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

final di = GetIt.instance;

// Simple User class for examples
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

// Database class for async examples
class Database {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  void dispose() {}
}

// ConfigService class for async examples
class ConfigService {
  String apiUrl = 'https://api.example.com';

  Future<void> loadFromFile() async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  void dispose() {}
}

// Extended ApiClient with request tracking
class ApiClientExtended extends ApiClient {
  ApiClientExtended({super.baseUrl});

  final requestCount = ValueNotifier<int>(0);
  final data = ValueNotifier<String>('');
}

// Stub classes for advanced integration examples
class ProfileManager {
  ProfileManager({required String userId});
  final profile = ValueNotifier<String>('Profile');
}

class ProductDetailManager {
  ProductDetailManager({required String productId});
  final product = ValueNotifier<String>('Product');
  final isLoading = ValueNotifier<bool>(false);
}

class CartManager {
  void dispose() {}
}

class PaymentService {
  void dispose() {}
}

class ShippingService {
  void dispose() {}
}

class AdvancedUserManager {
  AdvancedUserManager(User user);
  final user = ValueNotifier<User>(User(id: '1', name: 'Test User'));
  void dispose() {}
}

class UserPreferences {
  UserPreferences({required String userId});
  void dispose() {}
}

class AuthManager extends ChangeNotifier {
  final user = ValueNotifier<User>(User(id: '1', name: 'Test User'));
}

class AuthServiceAdvanced {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class FeatureManager {
  final data = ValueNotifier<String>('Feature Data');
}

class AdvancedFeatureAManager {
  AdvancedFeatureAManager({required AuthManager auth, required ApiClient api});
  final data = ValueNotifier<String>('Feature A Data');
}

abstract class CheckoutFlowBase extends ChangeNotifier {
  Widget buildUI();
}

class CheckoutFlowA extends CheckoutFlowBase {
  @override
  Widget buildUI() => Text('Checkout Flow A');
}

class CheckoutFlowB extends CheckoutFlowBase {
  @override
  Widget buildUI() => Text('Checkout Flow B');
}

class MockApiClient extends ApiClient {
  MockApiClient() : super(baseUrl: 'http://mock');
}

class MockAuthManager extends AuthManager {}

// UI Widgets
class CheckoutStepper extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

class ProductDetailView extends StatelessWidget {
  final String product;
  ProductDetailView({required this.product});
  @override
  Widget build(BuildContext context) => Text(product);
}

class DataDisplay extends StatelessWidget {
  final String data;
  DataDisplay(this.data);
  @override
  Widget build(BuildContext context) => Text(data);
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text('Loading...');
}

class ErrorScreen extends StatelessWidget {
  final Object? error;
  ErrorScreen({this.error});
  @override
  Widget build(BuildContext context) => Text('Error: $error');
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text('Main App');
}

void showErrorDialog(BuildContext context, Object? error) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Error'),
      content: Text('$error'),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text('Home');
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text('Login');
}

class UserProfile extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final user = watchValue((AuthManager m) => m.user);
    return Text(user.name);
  }
}

class YourUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

class FeatureUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

// Package structures
class CorePackage {
  static void register(GetIt di) {
    di.registerLazySingleton<AuthManager>(() => AuthManager());
    di.registerLazySingleton<ApiClient>(() => ApiClient());
  }
}

class FeatureA {
  static void register(GetIt di) {
    di.registerLazySingleton<AdvancedFeatureAManager>(
      () => AdvancedFeatureAManager(
        auth: di<AuthManager>(),
        api: di<ApiClient>(),
      ),
    );
  }
}

class FeatureB {
  static void register(GetIt di) {}
}

class AppPackage {
  static void register(GetIt di) {}
}

class FeatureModule {
  static void register(GetIt scope) {
    scope.registerLazySingleton<FeatureManager>(() => FeatureManager());
  }
}

// #region pushscope_automatic
class UserProfileScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Create scope on first build
    pushScope(
      init: (getIt) {
        // Register screen-specific dependencies
        getIt.registerLazySingleton<ProfileManager>(
          () => ProfileManager(userId: '123'),
        );
      },
      dispose: () {
        // Optional cleanUp when the scope is popped when the widget gets disposed
        print('Profile screen scope disposed');
      },
    );

    // Use scoped dependencies
    final profile = watchValue((ProfileManager m) => m.profile);

    return YourUI();
  }
}
// #endregion pushscope_automatic

// #region screen_specific_state
class ProductDetailScreen extends WatchingWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (getIt) {
        // Register screen-specific manager
        getIt.registerLazySingleton<ProductDetailManager>(
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
// #endregion screen_specific_state

// #region feature_modules
class CheckoutFlow extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (getIt) {
        // Register all checkout-related services
        getIt.registerLazySingleton<CartManager>(() => CartManager());
        getIt.registerLazySingleton<PaymentService>(() => PaymentService());
        getIt.registerLazySingleton<ShippingService>(() => ShippingService());
      },
      dispose: () {
        print('Checkout flow completed, cleaning up');
      },
    );

    return CheckoutStepper();
  }
}
// #endregion feature_modules

// #region user_session_state
class AuthenticatedApp extends WatchingWidget {
  final User user;

  AuthenticatedApp({required this.user});

  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (getIt) {
        // User-specific services
        getIt.registerLazySingleton<AdvancedUserManager>(
          () => AdvancedUserManager(user),
        );
        getIt.registerLazySingleton<UserPreferences>(
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
// #endregion user_session_state

// #region registering_named_instances
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
// #endregion registering_named_instances

// #region watching_named_instances
class ApiMonitor extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch specific named instances
    final prodApi = watchValue(
      (ApiClientExtended api) => api.requestCount,
      instanceName: 'production',
    );

    final stagingApi = watchValue(
      (ApiClientExtended api) => api.requestCount,
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
// #endregion watching_named_instances

// #region environment_specific_config
class AppConfig {
  static const environment =
      String.fromEnvironment('ENV', defaultValue: 'development');

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
      (ApiClientExtended api) => api.data,
      instanceName: AppConfig.environment,
    );

    return DataDisplay(data);
  }
}
// #endregion environment_specific_config

// #region isready_single_dependency
void setupDependenciesAsync() async {
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
// #endregion isready_single_dependency

// #region allready_multiple_dependencies
void setupMultipleDependencies() async {
  di.registerSingletonAsync<Database>(() async {
    final db = Database();
    await db.initialize();
    return db;
  });

  di.registerSingletonAsync<ConfigService>(() async {
    final config = ConfigService();
    await config.loadFromFile();
    return config;
  });

  di.registerSingletonAsync<AuthServiceAdvanced>(
    () async {
      final auth = AuthServiceAdvanced();
      await auth.initialize();
      return auth;
    },
    dependsOn: [Database], // Waits for Database first
  );
}

class AppAllReady extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Wait for all async singletons
    final ready = allReady(
      timeout: Duration(seconds: 30),
      onError: (context, error) {
        // Handle timeout or initialization errors
        // Without onError, exceptions would be thrown!
        showErrorDialog(context, error);
      },
    );

    if (!ready) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MainApp();
  }
}
// #endregion allready_multiple_dependencies

// #region allready_watchfuture
class AppWithFullErrorHandling extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watchFuture gives you an AsyncSnapshot for full error control
    final snapshot = watchFuture<GetIt, void>(
      (getIt) => getIt.allReady(timeout: Duration(seconds: 30)),
      target: di,
      initialValue: null,
    );

    if (snapshot.hasError) {
      // Handle initialization errors (timeout or factory exceptions)
      return ErrorScreen(error: snapshot.error);
    }

    if (snapshot.connectionState != ConnectionState.done) {
      return SplashScreen();
    }

    return MainApp();
  }
}
// #endregion allready_watchfuture

// #region watching_initialization_progress
class InitializationScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final dbReady = isReady<Database>();
    final configReady = isReady<ConfigService>();
    final authReady = isReady<AuthServiceAdvanced>();

    final progress =
        [dbReady, configReady, authReady].where((ready) => ready).length / 3;

    if (dbReady && configReady && authReady) {
      // All ready, navigate to main app
      callOnceAfterThisBuild((context) {
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
// #endregion watching_initialization_progress

// #region custom_getit_instances
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
      getIt: featureDI, // Use feature-specific instance
    );

    return YourUI();
  }
}
// #endregion custom_getit_instances

// #region core_package_setup
// core_package/lib/core_package.dart
// export 'managers/auth_manager.dart';

class CorePackageExample {
  static void register(GetIt di) {
    di.registerLazySingleton<AuthManager>(() => AuthManager());
    di.registerLazySingleton<ApiClient>(() => ApiClient());
  }
}
// #endregion core_package_setup

// #region feature_package_setup
// feature_a/lib/feature_a.dart
// export 'managers/feature_a_manager.dart';

class FeatureAExample {
  static void register(GetIt di) {
    // Depends on CorePackage being registered first
    di.registerLazySingleton<AdvancedFeatureAManager>(
      () => AdvancedFeatureAManager(
        auth: di<AuthManager>(), // From core package
        api: di<ApiClient>(),
      ),
    );
  }
}
// #endregion feature_package_setup

// #region main_app_integration
// main_app/lib/main.dart
// import 'package:core_package/core_package.dart';
// import 'package:feature_a/feature_a.dart';

void mainExample() {
  // Register all packages
  CorePackage.register(di);
  FeatureA.register(di);

  runApp(MyApp());
}

class FeatureAScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Can watch dependencies from any package
    final user = watchValue((AuthManager m) => m.user); // From core
    final data =
        watchValue((AdvancedFeatureAManager m) => m.data); // From feature_a

    return YourUI();
  }
}
// #endregion main_app_integration

// #region package_registration_order
void setupDependenciesOrder() {
  // Order matters for dependencies!

  // 1. Core dependencies first
  CorePackage.register(di);

  // 2. Feature packages (depend on core)
  FeatureA.register(di);
  FeatureB.register(di);

  // 3. App-level dependencies (depend on everything)
  AppPackage.register(di);
}
// #endregion package_registration_order

// #region lazy_module_loading
class FeatureLoader extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((_) {
      // Load feature module on demand
      pushScope(
        init: (getIt) {
          FeatureModule.register(getIt);
        },
      );
    });

    final ready = isReady<FeatureManager>();

    if (!ready) return CircularProgressIndicator();
    return FeatureUI();
  }
}
// #endregion lazy_module_loading

// #region ab_testing_named_instances
void setupABTest() {
  final variant = Random().nextBool() ? 'A' : 'B';

  di.registerLazySingleton<CheckoutFlowBase>(
    () => variant == 'A' ? CheckoutFlowA() : CheckoutFlowB(),
    instanceName: 'current',
  );
}

class CheckoutScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final flow = watchIt<CheckoutFlowBase>(
      instanceName: 'current',
    );

    return flow.buildUI();
  }
}
// #endregion ab_testing_named_instances

// #region hot_swap_dependencies
class DebugPanel extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Unregister old
        di.unregister<ApiClient>();

        // Register new
        di.registerLazySingleton<ApiClient>(
          () => MockApiClient(), // Swap to mock
        );

        // Widgets watching ApiClient will rebuild
      },
      child: Text('Switch to Mock API'),
    );
  }
}
// #endregion hot_swap_dependencies

// #region global_state_reset
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
// #endregion global_state_reset

// #region dependency_injection_testing
void main() {
  // Test setup example
  void testSetup() {
    // Reset get_it before each test
    di.reset();

    // Register mocks
    di.registerLazySingleton<AuthManager>(
      () => MockAuthManager(),
    );
  }

  // Example test structure (not actual test)
  testSetup();
}
// #endregion dependency_injection_testing

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: Container());
}
