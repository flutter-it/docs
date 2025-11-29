// Shared stubs for command_it code samples
// Import watch_it stubs for common models and services
import '../../watch_it/_shared/stubs.dart';

export '../../watch_it/_shared/stubs.dart';

import 'package:flutter/foundation.dart';

// Command-specific exception types
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  ValidationException(this.message, [this.fieldErrors]);

  @override
  String toString() => 'ValidationException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

// Toast/Snackbar manager for error examples
class ToastManager {
  void showError(String message) {
    debugPrint('Toast: $message');
  }

  void showSuccess(String message) {
    debugPrint('Toast: $message');
  }

  void showInfo(String message) {
    debugPrint('Toast: $message');
  }
}

// Analytics manager for error tracking examples
class AnalyticsManager {
  void logError(Object error, StackTrace? stackTrace) {
    debugPrint('Analytics: Error logged - $error');
  }

  void logEvent(String eventName, Map<String, dynamic>? parameters) {
    debugPrint('Analytics: Event logged - $eventName');
  }
}

// Database stub
class Database {
  Future<void> initialize() async {}
}

// User class for auth examples
class User {
  final String id;
  final String name;

  User(this.id, this.name);

  static User empty() => User('', '');
}

// Profile class for examples
class Profile {
  final String name;

  Profile(this.name);

  static Profile empty() => Profile('');
}

// Generic Data class for examples
class Data {
  final String? id;
  final String? value;

  Data([this.id, this.value]);

  static Data empty() => Data();
}

// Form data for examples
class FormData {
  final Map<String, dynamic> fields;

  FormData([this.fields = const {}]);
}

// Search result
class Result {
  final String id;
  final String title;

  Result(this.id, this.title);
}

// Additional models for command examples
class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo(this.id, this.title, [this.completed = false]);

  Todo copyWith({String? id, String? title, bool? completed}) {
    return Todo(
      id ?? this.id,
      title ?? this.title,
      completed ?? this.completed,
    );
  }
}

class LoginCredentials {
  final String username;
  final String password;

  LoginCredentials(this.username, this.password);
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult(this.isValid, [this.errors = const []]);
}

class WeatherEntry {
  final String city;
  final String condition;
  final int temperature;

  WeatherEntry(this.city, this.condition, this.temperature);
}

// Fake data for examples
final fakeTodos = [
  Todo('1', 'Learn command_it'),
  Todo('2', 'Build amazing app'),
  Todo('3', 'Ship to production'),
];

// Simulate API delay
Future<void> simulateDelay([int milliseconds = 500]) {
  return Future.delayed(Duration(milliseconds: milliseconds));
}

// Extension on ApiClient for command_it examples
extension ApiClientCommandExtensions on ApiClient {
  Future<List<Data>> fetchData() async {
    await simulateDelay();
    return [Data('1', 'value1'), Data('2', 'value2')];
  }

  Future<void> save(Data data) async {
    await simulateDelay();
  }

  Future<void> submit(FormData data) async {
    await simulateDelay();
  }

  Future<List<Result>> search(String query) async {
    await simulateDelay();
    return [Result('1', 'Result for $query')];
  }

  Future<User> login(String username, String password) async {
    await simulateDelay();
    return User('1', username);
  }

  Future<void> logout() async {
    await simulateDelay();
  }

  Future<Profile> loadProfile() async {
    await simulateDelay();
    return Profile('John Doe');
  }

  Future<List<Todo>> fetchTodos() async {
    await simulateDelay();
    return fakeTodos;
  }

  Future<void> saveTodo(Todo todo) async {
    await simulateDelay();
  }

  Future<void> deleteTodo(String id) async {
    await simulateDelay();
  }

  Future<void> toggleTodo(String id, bool completed) async {
    await simulateDelay();
  }

  Future<void> updateBookmark(String postId, bool isBookmarked) async {
    await simulateDelay();
  }

  Future<void> saveContent(String content) async {
    await simulateDelay();
  }

  Future<List<String>> searchData(String query) async {
    await simulateDelay();
    return [
      'Result 1 for $query',
      'Result 2 for $query',
      'Result 3 for $query'
    ];
  }
}

// Global helper for showing snackbars in examples
void showSnackBar(String message) {
  debugPrint('SnackBar: $message');
}

// Progress Control stubs
class Item {
  final String? id;
  final String? name;

  Item([this.id, this.name]);
}

Future<void> uploadChunk(dynamic file, int chunkIndex) async {
  await simulateDelay(50);
}

Future<void> downloadData() async {
  await simulateDelay(300);
}

Future<void> processData() async {
  await simulateDelay(300);
}

Future<void> saveResults() async {
  await simulateDelay(300);
}

Future<void> processItem(Item item) async {
  await simulateDelay(100);
}
