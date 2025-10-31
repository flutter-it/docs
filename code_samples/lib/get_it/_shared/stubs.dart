// Stub classes for get_it code samples
// These provide minimal implementations to make examples compile

import 'dart:async';
import 'package:flutter/material.dart';

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

  static Future<Database> connect() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return Database();
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

  Future<void> authenticate() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> close() async {}
}

/// Authentication service stub
class AuthService {
  AuthService._();

  static Future<AuthService> init() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return AuthService._();
  }

  Future<bool> login(String username, String password) async => true;
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
  UserRepository(this.apiClient, [this.database]);
  final ApiClient apiClient;
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
class MockApiClient extends ApiClient {
  MockApiClient() : super('http://localhost:3000');
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

/// User service stub (for scopes example)
class UserService {
  UserService._();

  static Future<UserService> load() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return UserService._();
  }

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
  ServiceA._();

  static Future<ServiceA> init() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return ServiceA._();
  }
}

/// Generic service B for dependency examples
class ServiceB {
  ServiceB(this.serviceA);
  final ServiceA serviceA;
}

/// Generic service C for dependency examples
class ServiceC {
  ServiceC(this.serviceA, this.serviceB);
  final ServiceA serviceA;
  final ServiceB serviceB;
}

/// Data sync service stub (for named dependencies example)
class DataSync {
  DataSync();

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
  AuthenticatedApiClient(String token) : super();
}

class GuestAuthService extends AuthService {
  GuestAuthService._() : super._();
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
  FileLogger._() : super._();
}

class ConsoleLogger extends Logger {
  ConsoleLogger._() : super._();
}

/// Service implementations
class MyServiceImpl implements Service {}

class RestServiceImpl extends RestService {
  RestServiceImpl(ApiClient client) : super(client);
}

class PublicApiClient extends ApiClient {
  PublicApiClient() : super();
}

/// Repository stubs
class CartService {
  CartService(Database db, ApiClient api);
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
void verify(dynamic mock) {}
T when<T>(T methodCall) => methodCall;

class MockDatabase extends Database {}

/// Plugin implementations
class LoggingPlugin extends AppPlugin {
  @override
  String get name => 'LoggingPlugin';
}

/// My Service interface
abstract class MyService {
  void doSomething();
  Future<void> dispose();
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

class ProfileController {
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

class UserServiceImpl {
  UserServiceImpl(ApiClient api);
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

/// Test framework stubs
void group(String description, Function() body) {
  body();
}

void testWidgets(String description, Function(dynamic tester) body) {}

void tearDownAll(Function() callback) {}

dynamic anyNamed(String name) => null;

/// Mock auth service
class MockAuthService extends AuthService {
  MockAuthService() : super._();

  String getToken() => 'mock-token';

  Future<dynamic> thenAnswer(dynamic invocation) async => null;
}

/// Additional viewmodels and services
class UserViewModel {
  UserViewModel(UserRepository repo);
}

class ReportGenerator {
  ReportGenerator(Database db);
}

class MemoryCache {
  void clear() {}
}

class DailyReport {
  DailyReport(Database db);
}

/// Storage implementation
class InMemoryStorage extends Database {
  InMemoryStorage() : super(':memory:');
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

/// watch_it widgets
abstract class WatchingWidget extends StatelessWidget {
  const WatchingWidget({super.key});

  void pushScope({required void Function(dynamic) init}) {
    // Stub implementation
  }
}

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

/// Flutter widget stubs
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page')),
    );
  }
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

/// watch_it integration stubs (for examples showing integration)
void callOnce(Function() callback, {Function()? dispose}) {
  callback();
}

dynamic watchIt<T>({String? instanceName}) => null;

/// ChangeNotifier from Flutter for reactive models
class ChangeNotifier {
  void notifyListeners() {}
}

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
