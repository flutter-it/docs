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

// Toast/Snackbar service for error examples
class ToastService {
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

// Analytics service for error tracking examples
class AnalyticsService {
  void logError(Object error, StackTrace? stackTrace) {
    debugPrint('Analytics: Error logged - $error');
  }

  void logEvent(String eventName, Map<String, dynamic>? parameters) {
    debugPrint('Analytics: Event logged - $eventName');
  }
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
}

// Global helper for showing snackbars in examples
void showSnackBar(String message) {
  debugPrint('SnackBar: $message');
}
