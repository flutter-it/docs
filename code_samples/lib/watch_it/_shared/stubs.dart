// ignore_for_file: unused_element, unused_field
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';

// Export di from watch_it for watch_it samples
export 'package:watch_it/watch_it.dart' show di;

// ============================================================================
// Models
// ============================================================================

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class CounterModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

class SettingsModel extends ChangeNotifier {
  bool _darkMode = false;
  String _language = 'en';
  double _fontSize = 14.0;

  bool get darkMode => _darkMode;
  String get language => _language;
  double get fontSize => _fontSize;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }
}

class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      completed: json['completed'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class WeatherModel {
  final String location;
  final double temperature;
  final String condition;
  final DateTime timestamp;

  WeatherModel({
    required this.location,
    required this.temperature,
    required this.condition,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ============================================================================
// Services
// ============================================================================

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = 'https://api.example.com'});

  Future<Map<String, dynamic>> get(String path) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'data': 'mock response'};
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, 'data': data};
  }

  Future<void> delete(String path) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> put(String path, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      id: '1',
      name: 'John Doe',
      email: email,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name,
        email: _currentUser!.email,
        avatarUrl: _currentUser!.avatarUrl,
      );
      notifyListeners();
    }
  }
}

class DataService {
  final ApiClient _apiClient;
  final List<TodoModel> _cachedTodos = [];

  DataService(this._apiClient);

  Future<List<TodoModel>> fetchTodos() async {
    await Future.delayed(const Duration(seconds: 1));
    final todos = [
      TodoModel(
          id: '1', title: 'Buy groceries', description: 'Milk, eggs, bread'),
      TodoModel(
          id: '2',
          title: 'Finish project',
          description: 'Complete documentation'),
      TodoModel(id: '3', title: 'Call mom', description: 'Weekly check-in'),
    ];
    _cachedTodos
      ..clear()
      ..addAll(todos);
    return todos;
  }

  Future<TodoModel> createTodo(String title, String description) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final todo = TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
    );
    _cachedTodos.add(todo);
    return todo;
  }

  Future<void> updateTodo(TodoModel todo) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _cachedTodos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _cachedTodos[index] = todo;
    }
  }

  Future<void> deleteTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cachedTodos.removeWhere((t) => t.id == id);
  }

  Future<WeatherModel> fetchWeather(String location) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return WeatherModel(
      location: location,
      temperature: 22.5,
      condition: 'Sunny',
    );
  }
}

// ============================================================================
// Managers (with Commands)
// ============================================================================

class TodoManager {
  final DataService _dataService;
  final ValueNotifier<List<TodoModel>> todos;
  final ValueNotifier<TodoModel?> selectedTodo;

  TodoManager(this._dataService)
      : todos = ValueNotifier<List<TodoModel>>([]),
        selectedTodo = ValueNotifier<TodoModel?>(null);

  late final fetchTodosCommand = Command.createAsyncNoParam<List<TodoModel>>(
    () async {
      final result = await _dataService.fetchTodos();
      todos.value = result;
      return result;
    },
    initialValue: <TodoModel>[],
    debugName: 'fetchTodos',
  );

  late final createTodoCommand =
      Command.createAsync<CreateTodoParams, TodoModel?>(
    (params) async {
      final result =
          await _dataService.createTodo(params.title, params.description);
      todos.value = [...todos.value, result];
      return result;
    },
    initialValue: null,
    debugName: 'createTodo',
  );

  late final updateTodoCommand = Command.createAsync<TodoModel, void>(
    (todo) async {
      await _dataService.updateTodo(todo);
      final index = todos.value.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        final updated = List<TodoModel>.from(todos.value);
        updated[index] = todo;
        todos.value = updated;
      }
    },
    initialValue: null,
    debugName: 'updateTodo',
  );

  late final deleteTodoCommand = Command.createAsync<String, void>(
    (id) async {
      await _dataService.deleteTodo(id);
      todos.value = todos.value.where((t) => t.id != id).toList();
    },
    initialValue: null,
    debugName: 'deleteTodo',
  );

  void selectTodo(TodoModel? todo) {
    selectedTodo.value = todo;
  }

  void dispose() {
    todos.dispose();
    selectedTodo.dispose();
    fetchTodosCommand.dispose();
    createTodoCommand.dispose();
    updateTodoCommand.dispose();
    deleteTodoCommand.dispose();
  }
}

class CreateTodoParams {
  final String title;
  final String description;

  CreateTodoParams({required this.title, required this.description});
}

class UserManager {
  final AuthService _authService;
  final ApiClient _apiClient;
  final ValueNotifier<UserModel?> currentUser;

  UserManager(this._authService, this._apiClient)
      : currentUser = ValueNotifier<UserModel?>(null);

  late final loginCommand = Command.createAsync<LoginParams, UserModel?>(
    (params) async {
      await _authService.login(params.email, params.password);
      currentUser.value = _authService.currentUser;
      return _authService.currentUser;
    },
    initialValue: null,
    debugName: 'login',
  );

  late final logoutCommand = Command.createAsyncNoParamNoResult(
    () async {
      await _authService.logout();
      currentUser.value = null;
    },
    debugName: 'logout',
  );

  late final updateProfileCommand = Command.createAsync<String, void>(
    (name) async {
      await _authService.updateProfile(name);
      currentUser.value = _authService.currentUser;
    },
    initialValue: null,
    debugName: 'updateProfile',
  );

  void dispose() {
    currentUser.dispose();
    loginCommand.dispose();
    logoutCommand.dispose();
    updateProfileCommand.dispose();
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class WeatherManager {
  final DataService _dataService;
  final ValueNotifier<WeatherModel?> weather;
  final ValueNotifier<String> location;

  WeatherManager(this._dataService)
      : weather = ValueNotifier<WeatherModel?>(null),
        location = ValueNotifier<String>('London');

  late final fetchWeatherCommand = Command.createAsyncNoParam<WeatherModel?>(
    () async {
      final result = await _dataService.fetchWeather(location.value);
      weather.value = result;
      return result;
    },
    initialValue: null,
    debugName: 'fetchWeather',
  );

  void setLocation(String value) {
    location.value = value;
  }

  void dispose() {
    weather.dispose();
    location.dispose();
    fetchWeatherCommand.dispose();
  }
}

// ============================================================================
// Simple Notifiers (for basic examples)
// ============================================================================

class SimpleCounter extends ValueNotifier<int> {
  SimpleCounter() : super(0);

  void increment() {
    value++;
  }

  void decrement() {
    value--;
  }

  void reset() {
    value = 0;
  }
}

class CounterManager {
  final count = ValueNotifier<int>(0);

  void increment() {
    count.value++;
  }

  void decrement() {
    count.value--;
  }

  void dispose() {
    count.dispose();
  }
}

class DataManager {
  final isLoading = ValueNotifier<bool>(false);
  final data = ValueNotifier<String>('');

  Future<void> fetchData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    data.value = 'Sample Data';
    isLoading.value = false;
  }

  void dispose() {
    isLoading.dispose();
    data.dispose();
  }
}

class SimpleUserManager {
  final name = ValueNotifier<String>('John Doe');
  final email = ValueNotifier<String>('john@example.com');
  final avatarUrl = ValueNotifier<String>('https://i.pravatar.cc/150?u=john');

  void updateName(String value) {
    name.value = value;
  }

  void updateEmail(String value) {
    email.value = value;
  }

  void updateAvatar(String value) {
    avatarUrl.value = value;
  }

  void dispose() {
    name.dispose();
    email.dispose();
    avatarUrl.dispose();
  }
}

class LoadingState extends ValueNotifier<bool> {
  LoadingState() : super(false);

  void setLoading(bool loading) {
    value = loading;
  }
}

class NameNotifier extends ValueNotifier<String> {
  NameNotifier([super.initialValue = '']);

  void updateName(String name) {
    value = name;
  }
}

// ============================================================================
// Stream Sources (for stream examples)
// ============================================================================

class TimerStream {
  Stream<int> get stream async* {
    var count = 0;
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield count++;
    }
  }
}

class ChatService {
  Stream<String> get messageStream async* {
    await Future.delayed(const Duration(seconds: 1));
    yield 'Hello!';
    await Future.delayed(const Duration(seconds: 2));
    yield 'How are you?';
    await Future.delayed(const Duration(seconds: 1));
    yield 'Welcome to chat!';
  }
}

class UserService {
  Stream<String> get activityStream async* {
    await Future.delayed(const Duration(seconds: 1));
    yield 'User logged in';
    await Future.delayed(const Duration(seconds: 2));
    yield 'User viewing dashboard';
    await Future.delayed(const Duration(seconds: 3));
    yield 'User editing profile';
  }

  Future<String> fetchAvatar(String userName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://i.pravatar.cc/150?u=$userName';
  }
}

class AppService {
  Future<bool> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate initialization tasks
    return true;
  }
}

class MessageService {
  final _messageController = StreamController<List<Message>>.broadcast();

  Stream<List<Message>> get messageStream => _messageController.stream;

  void addMessage(Message message) {
    // Simplified - would normally maintain a list
    _messageController.add([message]);
  }

  void dispose() {
    _messageController.close();
  }
}

class Message {
  final String id;
  final String text;
  final DateTime timestamp;

  Message({required this.id, required this.text, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class NotificationService {
  final _notificationController = StreamController<int>.broadcast();

  Stream<int> get notificationStream => _notificationController.stream;

  void sendNotification() {
    // Simplified notification count
    _notificationController.add(1);
  }

  void dispose() {
    _notificationController.close();
  }
}

class EventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void fire(AppEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

class StreamManager {
  final _controller1 = StreamController<int>.broadcast();
  final _controller2 = StreamController<int>.broadcast();

  Stream<int> get stream1 => _controller1.stream;
  Stream<int> get stream2 => _controller2.stream;

  // Controls which stream to use
  final useStream1 = ValueNotifier<bool>(true);

  void dispose() {
    _controller1.close();
    _controller2.close();
    useStream1.dispose();
  }
}

abstract class AppEvent {}

class TodoCreatedEvent extends AppEvent {
  final TodoModel todo;
  TodoCreatedEvent(this.todo);
}

class TodoUpdatedEvent extends AppEvent {
  final TodoModel todo;
  TodoUpdatedEvent(this.todo);
}

class TodoDeletedEvent extends AppEvent {
  final String todoId;
  TodoDeletedEvent(this.todoId);
}

// ============================================================================
// Utilities
// ============================================================================

final getIt = GetIt.instance;

void setupDependencyInjection() {
  if (getIt.isRegistered<ApiClient>()) {
    return; // Already set up
  }

  // Core services
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<DataService>(
      () => DataService(getIt<ApiClient>()));

  // Complex managers (with commands)
  getIt.registerLazySingleton<TodoManager>(
      () => TodoManager(getIt<DataService>()));
  getIt.registerLazySingleton<UserManager>(
    () => UserManager(getIt<AuthService>(), getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<WeatherManager>(
    () => WeatherManager(getIt<DataService>()),
  );

  // Simple managers (for tutorial examples) - use registerSingleton for simplicity
  getIt.registerSingleton<CounterManager>(CounterManager());
  getIt.registerSingleton<DataManager>(DataManager());
  getIt.registerSingleton<SimpleUserManager>(SimpleUserManager());

  // Stream/Future services (for async examples)
  getIt.registerSingleton<ChatService>(ChatService());
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<AppService>(AppService());
  getIt.registerSingleton<MessageService>(MessageService());
  getIt.registerSingleton<NotificationService>(NotificationService());

  // Event bus
  getIt.registerLazySingleton<EventBus>(() => EventBus());
}
