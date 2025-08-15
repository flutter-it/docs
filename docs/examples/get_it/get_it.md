---
title: get_it Examples
---

# get_it Examples

This section contains examples for using the `get_it` package for dependency injection in Flutter applications.

## Basic Usage

### Setup and Registration

```dart
import 'package:get_it/get_it.dart';

// Global variable for easy access (using 'di' as recommended by watch_it)
final di = GetIt.instance;

void setupLocator() {
  // Register a singleton
  di.registerSingleton<AppModel>(AppModel());
  
  // Register a lazy singleton (created on first access)
  di.registerLazySingleton<ApiService>(() => ApiService());
  
  // Register a factory (new instance each time)
  di.registerFactory<Repository>(() => Repository(di<ApiService>()));
}

// Alternative setup using the shortcut
void setupLocatorAlternative() {
  GetIt.I.registerSingleton<AppModel>(AppModel());
  GetIt.I.registerLazySingleton<ApiService>(() => ApiService());
}
```

### Using Registered Objects

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access registered objects
    final appModel = di<AppModel>();
    final apiService = di<ApiService>();
    
    return MaterialButton(
      child: Text("Update"),
      onPressed: appModel.update,
    );
  }
}
```

### Abstract Base Classes

```dart
// Define abstract base class
abstract class ApiService {
  Future<String> fetchData();
}

// Concrete implementation
class ApiServiceImpl implements ApiService {
  @override
  Future<String> fetchData() async {
    // Implementation here
    return "Data from API";
  }
}

// Register with abstract type
void setup() {
  di.registerSingleton<ApiService>(ApiServiceImpl());
}

// Use with abstract type
class DataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiService = di<ApiService>(); // Returns ApiServiceImpl
    return FutureBuilder<String>(
      future: apiService.fetchData(),
      builder: (context, snapshot) {
        return Text(snapshot.data ?? 'Loading...');
      },
    );
  }
}
```

## Advanced Examples

### Scopes

```dart
void setupScopes() {
  // Register in root scope
  di.registerSingleton<UserService>(UserService());
  
  // Push new scope for user session
  di.pushNewScope(
    scopeName: 'user_session',
    init: (getIt) {
      getIt.registerSingleton<User>(User(id: '123', name: 'John'));
    },
  );
}

void cleanupUserSession() async {
  // Pop scope when user logs out
  await di.popScope();
}
```

### Async Objects

```dart
void setupAsyncObjects() {
  // Register async factory
  di.registerFactoryAsync<DatabaseService>(() async {
    final db = DatabaseService();
    await db.initialize();
    return db;
  });
}

// Use with await
Future<void> useDatabase() async {
  final db = await di.getAsync<DatabaseService>();
  await db.query('SELECT * FROM users');
}
```

### Testing

```dart
void setupTestLocator() {
  // Reset for each test
  di.reset();
  
  // Register mock implementations
  di.registerSingleton<ApiService>(MockApiService());
  di.registerSingleton<UserService>(MockUserService());
}

class MockApiService implements ApiService {
  @override
  Future<String> fetchData() async {
    return "Mock data";
  }
}
``` 