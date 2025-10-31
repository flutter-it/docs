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

  Future<void> authenticate() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<Map<String, dynamic>> get(String endpoint) async => {};
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
  bool get isAuthenticated => false;
}

/// User repository stub
class UserRepository {
  UserRepository(this.apiClient, [this.database]);
  final ApiClient apiClient;
  final Database? database;

  Future<User?> getUser(String id) async => User(id: id, name: 'Test User');
  Future<void> saveUser(User user) async {}
}

/// User model stub
class User {
  User({required this.id, required this.name});
  final String id;
  final String name;
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
  TenantConfig(this.database, this.apiKey);
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
