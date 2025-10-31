// ignore_for_file: unused_element, use_super_parameters
// Stub classes for get_it code samples
// These provide minimal implementations to make examples compile

import 'dart:async';
import 'package:flutter/material.dart';
export 'package:flutter/material.dart' show Key, ChangeNotifier;
import 'package:test/test.dart' hide Matcher, Description;
export 'package:test/test.dart'
    show
        expect,
        test,
        setUp,
        setUpAll,
        tearDown,
        tearDownAll,
        group,
        isNotNull,
        throwsStateError;
import 'package:flutter_test/flutter_test.dart' as flutter_test;
export 'package:flutter_test/flutter_test.dart'
    show
        testWidgets,
        WidgetTester,
        find,
        findsOneWidget,
        findsWidgets,
        findsNothing;

// Import real get_it classes instead of stubbing
import 'package:get_it/get_it.dart';
export 'package:get_it/get_it.dart'
    show
        FactoryFunc,
        FactoryFuncParam,
        FactoryFuncAsync,
        FactoryFuncParamAsync,
        DisposingFunc,
        ObjectRegistration,
        WillSignalReady,
        Disposable;

// Import real watch_it classes instead of stubbing
import 'package:watch_it/watch_it.dart';
export 'package:watch_it/watch_it.dart'
    show
        WatchingWidget,
        WatchingStatefulWidget,
        callOnce,
        watchIt,
        di,
        pushScope;

/// Annotation stubs for injectable code generation examples
const injectable = Injectable();

class Injectable {
  final Type? as;
  const Injectable({this.as});
}

class InjectableInit {
  const InjectableInit();
}

/// Extension for generated init method
extension GetItInjectableX on dynamic {
  void init() {
    // Stub for generated initialization
  }
}

/// Configuration service stub
class ConfigService {
  static Future<ConfigService> load() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return ConfigService();
  }

  Future<void> loadFromFile() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> loadConfig() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> loadFromDisk() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> loadRemoteConfig() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  void validateConfig() {}
  void setupConnections() {}

  String getSetting(String key) => 'value';
  bool get isDevelopment => true;
  String get apiUrl => 'https://api.example.com';
  String get dbPath => '/data/db.sqlite';
  String get databasePath => '/data/db.sqlite';
  String get prodUrl => 'https://api.production.com';
  bool get enableFeatureX => true;
}

/// Database connection stub
class Database {
  Database([String? path]);

  static Future<Database> connect([String? connectionString]) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return Database(connectionString);
  }

  Future<void> connectToDatabase() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> runMigrations() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> close() async {}
  Future<Map<String, dynamic>> query(String sql) async => {};
  Future<void> save(dynamic data) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

/// Heavy database stub (expensive to create)
class HeavyDatabase extends Database {
  HeavyDatabase() : super();
}

/// Database connection stub (alternative name)
class DatabaseConnection {
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> disconnect() async {}
  bool get isConnected => true;
}

/// API client stub
class ApiClient {
  ApiClient([String? baseUrl]);

  static Future<ApiClient> create([String? baseUrl]) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return ApiClient(baseUrl);
  }

  static Future<ApiClient> connect() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return ApiClient();
  }

  Future<User> login(String username, String password) async {
    return User(id: '123', name: username, token: 'fake-token');
  }

  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? headers}) async {
    return {'data': 'mock'};
  }

  Future<Map<String, dynamic>> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return {'data': 'fetched', 'timestamp': DateTime.now().toString()};
  }

  Future<void> authenticate() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> close() async {}
}

/// Authentication service interface
abstract class IAuthService {}

/// Authentication service stub
class AuthService extends ChangeNotifier implements IAuthService {
  AuthService._();
  AuthService([dynamic dep]);  // Public unnamed constructor for examples

  static Future<AuthService> init() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return AuthService._();
  }

  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return User(id: '123', name: username, token: 'fake-token');
  }

  Future<void> logout() async {}
  Future<void> cleanup() async {}
  bool get isAuthenticated => false;

  final ApiClient api = ApiClient();
  final User user = User(id: '1', name: 'Test');
}

/// Auth service implementation
class AuthServiceImpl extends AuthService {
  AuthServiceImpl() : super._();
}

/// User repository stub
class UserRepository {
  UserRepository([this.apiClient, this.database]);
  final ApiClient? apiClient;
  final Database? database;

  Future<User?> getUser(String id) async => User(id: id, name: 'Test User');
  Future<User?> fetchUser(String id) async => User(id: id, name: 'Test User');
  Future<void> saveUser(User user) async {}
}

/// User model stub
class User {
  User({required this.id, required this.name, this.token});
  final String id;
  final String name;
  final String? token;

  factory User.fromData(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String? ?? '0',
      name: data['name'] as String? ?? 'Unknown',
    );
  }
}

/// Weather service stub
class WeatherService {
  WeatherService(this.apiClient);
  final ApiClient apiClient;

  Future<Weather> getCurrentWeather(String city) async {
    return Weather(city: city, temperature: 20.0);
  }
}

/// Weather model stub
class Weather {
  Weather({required this.city, required this.temperature});
  final String city;
  final double temperature;
}

/// Logging service stub
class LoggingService {
  void log(String message) => print(message);
  void error(String message, [Object? error]) => print('ERROR: $message');
}

/// Analytics service stub
class AnalyticsService {
  AnalyticsService._();

  static Future<AnalyticsService> init() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return AnalyticsService._();
  }

  void trackEvent(String event) {}
}

/// Session analytics stub
class SessionAnalytics {
  SessionAnalytics();
  void trackEvent(String event) {}
  void endSession() {}
}

/// Settings service stub
class SettingsService {
  SettingsService(this.database);
  final Database database;

  String? getSetting(String key) => null;
  Future<void> setSetting(String key, String value) async {}
}

/// Cache service stub
class CacheService {
  Future<String?> get(String key) async => null;
  Future<void> set(String key, String value) async {}
  Future<void> clear() async {}
  Future<void> loadFromDisk() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

/// Global cache (for scope examples)
class GlobalCache {
  GlobalCache();
  Future<String?> get(String key) async => null;
  Future<void> set(String key, String value) async {}
}

/// Session cache (for scope examples)
class SessionCache {
  SessionCache();
  Future<String?> get(String key) async => null;
  Future<void> set(String key, String value) async {}
}

/// User state (for scope examples)
class UserState {
  UserState();
  String? userId;
  bool isLoggedIn = false;
}

/// Core service (for testing examples)
class CoreService {
  CoreService();
  void initialize() {}
}

/// Feature service (for testing examples)
class FeatureService {
  FeatureService(CoreService core);
  void doSomething() {}
}

/// Expensive service stub (for cached factory examples)
class ExpensiveService {
  ExpensiveService._();

  static Future<ExpensiveService> create() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ExpensiveService._();
  }

  void doWork() {}
}

/// Initialization progress tracker (used in pattern examples)
class InitializationProgress extends ChangeNotifier {
  final Map<String, bool> _progress = {};

  void markReady(String serviceName) {
    _progress[serviceName] = true;
    notifyListeners();
  }

  double get percentComplete =>
      _progress.values.where((ready) => ready).length / _progress.length;
}

/// Logger stub
class Logger {
  Logger._();
  Logger(); // Public constructor

  static Future<Logger> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return Logger._();
  }

  void log(String message) => print('LOG: $message');
  void info(String message) => print('INFO: $message');
  void error(String message, [Object? error]) => print('ERROR: $message');
  void debug(String message) => print('DEBUG: $message');
}

/// Mock API client stub (for testing/conditional init)
/// Directly configurable - set mockData before calling fetchData()
class MockApiClient extends ApiClient {
  MockApiClient() : super('http://localhost:3000');

  bool isAuthenticated = false;
  Map<String, dynamic> mockData = {'data': 'mock data'};

  @override
  Future<Map<String, dynamic>> fetchData() async => mockData;
}

/// Application model stub
class AppModel {
  AppModel._({this.userRepository, this.api, this.db, this.config});

  factory AppModel([UserRepository? userRepository]) {
    return AppModel._(userRepository: userRepository);
  }

  factory AppModel.withParams(
      {UserRepository? userRepository,
      ApiClient? api,
      Database? db,
      ConfigService? config}) {
    return AppModel._(
        userRepository: userRepository, api: api, db: db, config: config);
  }

  final UserRepository? userRepository;
  final ApiClient? api;
  final Database? db;
  final ConfigService? config;

  Future<void> loadUser(String userId) async {
    await userRepository?.getUser(userId);
  }
}

/// Theme service stub (for testing examples)
abstract class ThemeService {
  String get currentTheme;
  void setTheme(String theme);
}

class ThemeServiceImpl implements ThemeService {
  String _theme = 'light';

  @override
  String get currentTheme => _theme;

  @override
  void setTheme(String theme) => _theme = theme;
}

// Fake mockito functions removed - use direct property access on Mock* classes instead

/// User service stub (for scopes example and testing)
abstract class UserService {
  static Future<UserService> load() => _UserServiceImpl.load();

  Future<User> login(String username, String password);
  Future<User> loadUser(String userId);
  Future<void> logout();
}

class _UserServiceImpl extends UserService {
  _UserServiceImpl();

  static Future<UserService> load() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _UserServiceImpl();
  }

  @override
  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return User(id: username, name: username);
  }

  @override
  Future<User> loadUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return User(id: userId, name: 'User $userId');
  }

  @override
  Future<void> logout() async {}
}

/// Image cache stub (for lazy singleton examples)
class ImageCache {
  ImageCache._();

  static Future<ImageCache> create() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return ImageCache._();
  }

  static Future<ImageCache> load() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return ImageCache._();
  }

  void clear() {}
}

/// Feature X stub (for multiple calls example)
class FeatureX {
  FeatureX._();

  static Future<FeatureX> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return FeatureX._();
  }
}

/// Generic service A for dependency examples
class ServiceA {
  ServiceA();
  ServiceA._();

  static Future<ServiceA> init() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return ServiceA._();
  }
}

/// Generic service B for dependency examples
class ServiceB {
  ServiceB([this.serviceA]);
  final ServiceA? serviceA;
}

/// Generic service C for dependency examples
class ServiceC {
  ServiceC(this.serviceA, this.serviceB);
  final ServiceA serviceA;
  final ServiceB serviceB;
}

/// Data sync service stub (for named dependencies example)
class DataSync {
  DataSync([ApiClient? api]);

  static Future<DataSync> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return DataSync();
  }

  Future<void> sync() async {}
}

/// App settings stub
class AppSettings {
  AppSettings({this.api, this.config, this.error});
  final ApiClient? api;
  final ConfigService? config;
  final Object? error;
}

/// Database service stub (alternative to Database)
class DatabaseService {
  DatabaseService._();

  static Future<DatabaseService> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return DatabaseService._();
  }

  Future<void> connectToDatabase() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> runMigrations() async {}
}

/// Heavy resource stub (for cached factory examples)
class HeavyResource {
  HeavyResource();

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void dispose() {}
}

/// Report stub (for parameterized factory examples)
class Report {
  Report(this.data, [this.format = 'PDF']);
  final String data;
  final String format;

  String get title => 'Report: $data';

  Future<void> generate() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

// Note: WillSignalReady is provided by package:get_it/get_it.dart
// No need to stub it here

/// Generic service interface and implementation stubs
class Service {}

class ServiceImpl implements Service {}

/// Payment processor stubs
abstract class PaymentProcessor {
  Future<void> processPayment(double amount);
}

class StripePaymentProcessor implements PaymentProcessor {
  @override
  Future<void> processPayment(double amount) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

class PayPalPaymentProcessor implements PaymentProcessor {
  @override
  Future<void> processPayment(double amount) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

class LegacyPaymentProcessor implements PaymentProcessor {
  @override
  Future<void> processPayment(double amount) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

/// Plugin interface stub
abstract class Plugin {
  String get name;
  Future<void> initialize();
}

/// Output interface stubs
abstract class IOutput {
  void write(String message);
}

class ConsoleOutput implements IOutput {
  @override
  void write(String message) => print(message);
}

class FileOutput implements IOutput {
  FileOutput(String path);

  @override
  void write(String message) {
    // Write to file
  }
}

/// Tenant stubs
class Tenant {
  final String id;
  final String name;
  Tenant(this.id, this.name);
}

class TenantConfig {
  final String database;
  final String apiKey;
  final String dbUrl;
  final String apiUrl;
  TenantConfig(this.database, this.apiKey,
      {this.dbUrl = 'db://localhost', this.apiUrl = 'https://api.example.com'});
}

/// REST service stub
class RestService {
  RestService(ApiClient client);
  Future<Map<String, dynamic>> get(String endpoint) async => {};
}

/// Disposable service stubs
class DisposableService {
  Future<void> dispose() async {}
}

/// Checkout service stub
class CheckoutService {
  CheckoutService(UserService userService);
}

/// Middleware/Theme stubs
class Middleware {
  String get name => 'middleware';
}

class Theme {
  String get name => 'theme';
}

/// Authentication stubs
class AuthenticatedApiClient extends ApiClient {
  AuthenticatedApiClient(String? token) : super();
}

class GuestAuthService extends AuthService {
  GuestAuthService() : super._();
}

class GuestUser extends User {
  GuestUser() : super(id: 'guest', name: 'Guest');
}

/// Notification service stub
class NotificationService {
  NotificationService(String userId);
  void notify(String message) {}
}

/// Logger implementations
class FileLogger extends Logger {
  FileLogger() : super._();
}

class ConsoleLogger extends Logger {
  ConsoleLogger() : super._();
}

/// Service implementations
class RestServiceImpl extends RestService {
  RestServiceImpl(ApiClient client) : super(client);
}

class PublicApiClient extends ApiClient {
  PublicApiClient() : super();
}

/// Repository stubs
class CartService {
  CartService(dynamic param1, [dynamic param2]);
}

class OrderRepository {
  OrderRepository(ApiClient api);
}

/// Checkout service variant
class NewCheckoutService extends CheckoutService {
  NewCheckoutService(UserService userService) : super(userService);
}

/// Tenant functions
Future<TenantConfig> loadTenantConfig(String tenantId) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return TenantConfig('db_$tenantId', 'key_$tenantId');
}

/// Test helper stubs (for test-like examples)
void setUp(Function() callback) {}
void tearDown(Function() callback) {}
void setUpAll(Function() callback) {}
void test(String description, Function() callback) {}
void expect(dynamic actual, dynamic matcher) {}
// verify() removed - use direct assertions on Mock* classes instead

/// Test matcher base class
abstract class Matcher {
  bool matches(dynamic item, Map matchState);
  Description describe(Description description);
}

/// Test description class
class Description {
  final StringBuffer _buffer = StringBuffer();

  Description add(String text) {
    _buffer.write(text);
    return this;
  }

  @override
  String toString() => _buffer.toString();
}

/// Type matcher for testing
Matcher isA<T>() => _IsA<T>();

class _IsA<T> extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) => item is T;

  @override
  Description describe(Description description) => description.add('is a $T');
}

class MockDatabase extends Database {}

/// Plugin implementations
class LoggingPlugin extends AppPlugin {
  @override
  String get name => 'LoggingPlugin';

  static Future<LoggingPlugin> create() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return LoggingPlugin();
  }
}


/// Additional missing classes
class ShoppingCart {
  void addItem(String item) {}
  void clear() {}
  int get itemCount => 0;
}

class Response {
  final int statusCode;
  final String body;
  Response(this.statusCode, this.body);

  static Response forbidden() => Response(403, 'Forbidden');
}

class Request {
  final String url;
  final String method;
  Request(this.url, this.method);
}

class JsonParser {
  Map<String, dynamic> parse(String json) => {};
}

class HeavyParser extends JsonParser {}

class Event {
  final String name;
  final Map<String, dynamic> data;
  Event(this.name, this.data);
}

class AppPlugin implements Plugin {
  @override
  String get name => 'AppPlugin';

  @override
  Future<void> initialize() async {}
}

class CorePlugin extends AppPlugin {
  @override
  String get name => 'CorePlugin';

  static Future<CorePlugin> create() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return CorePlugin();
  }
}

class AnalyticsPlugin extends AppPlugin {
  @override
  String get name => 'AnalyticsPlugin';
}

class FeatureAPlugin implements Plugin {
  @override
  String get name => 'FeatureAPlugin';

  @override
  Future<void> initialize() async {}
}

class FeatureBPlugin implements Plugin {
  @override
  String get name => 'FeatureBPlugin';

  @override
  Future<void> initialize() async {}
}

class ThemeProvider {
  String get currentTheme => 'light';
  void setTheme(String theme) {}
}

class ProfileController extends ChangeNotifier {
  final String userId;
  ProfileController({required this.userId});

  User get userData => User(id: userId, name: 'Profile User');
  void loadProfile(String userId) {}
}

class DbService {
  Future<void> connect() async {}
  Future<void> save(dynamic data) async {}
}

class AppLifecycleObserver {
  void onResume() {}
  void onPause() {}
}

class RequestMiddleware {
  Future<Response> process(Request request) async {
    return Response(200, '{}');
  }
}

class DetailService {
  DetailService(String itemId);
  Future<void> loadData() async {}
}

class CacheManager {
  void clear() {}
  String? get(String key) => null;
  Future<void> initialize(String tenantId) async {}
  Future<void> flush() async {}
}

class BaseLogger {
  void log(String message) {}
}

class TenantServices {
  final Database db;
  final ApiClient api;
  TenantServices(this.db, this.api);
}

abstract class IServiceA {
  void execute();
}

class AuthenticatedUser extends User {
  AuthenticatedUser(String token) : super(id: 'auth', name: 'Authenticated');
}

class LoggedInUser extends User {
  LoggedInUser() : super(id: 'logged-in', name: 'Logged In User');
}

/// Helper function
void notifyListeners() {}

/// Event bus stub
class EventBus {
  Stream<T> on<T>() => Stream.empty();
  void emit<T>(T event) {}
}

/// Streaming service stub
class StreamingService {
  Stream<String> get dataStream => Stream.empty();
  void initialize() {}
}

/// Feature implementation stub
class FeatureImplementation {
  void execute() {}
  void register(dynamic getIt) {}
}

/// Test implementation stubs
class FakeApiClient extends ApiClient {
  FakeApiClient() : super('http://fake.test');
}

class InMemoryDatabase extends Database {
  InMemoryDatabase() : super(':memory:');
}

class ApiClientImpl extends ApiClient {
  ApiClientImpl() : super();
}

class DatabaseImpl extends Database {
  DatabaseImpl() : super();
}

class UserServiceImpl extends UserService {
  final ApiClient api;
  UserServiceImpl(this.api);

  @override
  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return User(id: username, name: username);
  }

  @override
  Future<User> loadUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return User(id: userId, name: 'User $userId');
  }

  @override
  Future<void> logout() async {}
}

/// Mock service for testing
class MockUserService extends UserService {
  MockUserService();

  @override
  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return User(id: username, name: username);
  }

  @override
  Future<User> loadUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return User(id: userId, name: 'User $userId');
  }

  @override
  Future<void> logout() async {}
}

/// Plugin implementations
class ShoppingCartPlugin extends AppPlugin {
  @override
  String get name => 'ShoppingCartPlugin';
}

class PaymentPlugin extends AppPlugin {
  @override
  String get name => 'PaymentPlugin';
}

class DebugPlugin extends AppPlugin {
  @override
  String get name => 'DebugPlugin';
}

class FeaturePlugin extends AppPlugin {
  @override
  String get name => 'FeaturePlugin';
}

/// ViewModel stubs
class LoginViewModel {
  LoginViewModel(AuthService auth);
}

class Analytics {
  void trackEvent(String event) {}
}

/// Output implementations
class RemoteOutput implements IOutput {
  RemoteOutput(String url);

  @override
  void write(String message) {}
}

/// Widget page stubs
class DetailPage extends StatelessWidget {
  const DetailPage(this.itemId, {super.key});
  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(child: Text('Detail: $itemId')),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Page')),
    );
  }
}

/// API client variations
class ProdApiClient extends ApiClient {
  ProdApiClient() : super('https://api.production.com');
}

class DevApiClient extends ApiClient {
  DevApiClient() : super('https://api.dev.com');
}

/// Helper function stubs
void configureDependencies() {
  // Stub for test configuration
}

void accessServices() {
  // Stub for accessing services
}

/// Test framework stubs
void group(String description, Function() body) {
  body();
}

void testWidgets(String description, Function(dynamic tester) body) {}

void tearDownAll(Function() callback) {}

// anyNamed() removed - use direct configuration on Mock* classes instead

/// Mock auth service with configurable properties
/// Directly configurable - set isAuthenticated before use
class MockAuthService extends AuthService {
  MockAuthService() : super._();

  @override
  bool get isAuthenticated => _isAuthenticated;
  bool _isAuthenticated = false;
  set isAuthenticated(bool value) => _isAuthenticated = value;

  String getToken() => 'mock-token';
}

/// Additional viewmodels and services
class UserViewModel {
  UserViewModel(this.userId, {dynamic age, UserRepository? repo});
  final String? userId;
}

class ReportGenerator {
  ReportGenerator(dynamic param);
}

class TestClass {
  TestClass();
}

class UserPreferences {
  UserPreferences();
  String getSetting(String key) => 'value';
  void setSetting(String key, String value) {}
}

class ImageProcessor {
  ImageProcessor(this.width, this.height);
  final int width;
  final int height;

  void process() {}
}

class HeavyService {
  HeavyService();
  void doWork() {}
}

/// Cache interface for example code
abstract class Cache {
  dynamic get(String key);
  void set(String key, dynamic value);
  void clear();
}

class MemoryCache implements Cache {
  final Map<String, dynamic> _data = {};

  @override
  dynamic get(String key) => _data[key];

  @override
  void set(String key, dynamic value) => _data[key] = value;

  @override
  void clear() => _data.clear();
}

class UserCache {
  void clearCache() {}
}

class DailyReport extends Report {
  DailyReport([String? data]) : super(data ?? 'Daily data');
}

/// Storage implementation
class InMemoryStorage extends Database {
  InMemoryStorage() : super(':memory:');
}

/// Secure storage stub
class SecureStorage {
  Future<String?> read(String key) async => 'stored_value';
  Future<void> write(String key, String value) async {}
  Future<void> delete(String key) async {}
}

/// Premium feature stub
class PremiumFeature {
  final String name;
  PremiumFeature(this.name);
}

/// UI widgets
class PremiumUI extends StatelessWidget {
  final PremiumFeature? feature;
  const PremiumUI({super.key, this.feature});

  @override
  Widget build(BuildContext context) => const Text('Premium');
}

class BasicUI extends StatelessWidget {
  const BasicUI({super.key});

  @override
  Widget build(BuildContext context) => const Text('Basic');
}

// WatchingWidget imported from package:watch_it/watch_it.dart above

/// Observers
class AnalyticsObserver {
  void observe() {}
}

class LoggingObserver {
  void observe() {}
}

/// Provider stubs (for examples that use provider pattern)
class ChangeNotifierProvider extends StatelessWidget {
  final Widget? child;

  const ChangeNotifierProvider(
      {super.key, required dynamic create, required this.child});

  @override
  Widget build(BuildContext context) => child ?? const SizedBox();
}

class ThemeNotifier extends ChangeNotifier {
  String currentTheme = 'light';
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.error, {super.key});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Error: $error')),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

// callOnce, watchIt imported from package:watch_it/watch_it.dart above
// ChangeNotifier imported from package:flutter/material.dart above

/// Permissions system stubs
class Permissions {}

class GuestPermissions extends Permissions {}

class UserPermissions extends Permissions {
  UserPermissions(User user);
}

/// Tenant management stubs
class TenantManager {
  Future<Database> openTenantDatabase(String tenantId) async {
    return Database();
  }
}

/// File output helper
class File {
  final String path;
  File(this.path);

  void writeAsStringSync(String content) {
    // Stub implementation
  }
}

class FileOutputHelper {
  static FileOutput fileOutput(String path) => FileOutput(path);
}

/// App model extensions
extension AppModelExtensions on AppModel {
  set currentUser(User? user) {
    // Stub
  }
}

/// Database connection extensions
extension DatabaseConnectionExtensions on DatabaseConnection {
  Future<void> close() async {}
}

/// Mock classes for testing
class MockAppModel {
  User? currentUser;
}

class MockDbService {
  Future<void> save(dynamic data) async {}
}

/// SyncService stub
class SyncService {
  SyncService(ApiClient api, Database db, AuthService auth);
}

/// TypeRegistration stub
class TypeRegistration {
  final registrations = <dynamic>[];
  final namedRegistrations = <String, dynamic>{};
}

/// runApp stub (Flutter app entry) - commented out to avoid conflict with Flutter's runApp
// void runApp(Widget app) {}

/// setupDependencies stub
void setupDependencies() {}

/// HomePage widget stub
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Container();
}

/// MyApp widget stub
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp();
}

/// MyService stub with saveState
class MyService {
  void saveState() {}
  void doWork() {}
  void cleanup() {}
  void dispose() {}
}

class MyServiceImpl extends MyService {
  @override
  void saveState() {}

  @override
  void doWork() {}

  @override
  void cleanup() {}

  @override
  void dispose() {}
}
