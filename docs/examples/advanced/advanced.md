---
title: Advanced Examples
---

# Advanced Examples

This section contains advanced examples showing how to combine multiple flutter_it packages together in real-world applications.

## Complete App Example

### App Structure

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';
import 'package:command_it/command_it.dart';
import 'package:listen_it/listen_it.dart';

// Global service locator
final di = GetIt.instance;

void main() {
  setupDependencies();
  runApp(MyApp());
}

void setupDependencies() {
  // Register services
  di.registerSingleton<AuthService>(AuthService());
  di.registerSingleton<UserService>(UserService());
  di.registerSingleton<ApiService>(ApiService());
  
  // Register managers
  di.registerSingleton<AppManager>(AppManager());
  di.registerSingleton<SearchManager>(SearchManager());
  di.registerSingleton<FormManager>(FormManager());
}
```

### Services

```dart
class AuthService {
  final _isLoggedIn = ValueNotifier<bool>(false);
  final _currentUser = ValueNotifier<User?>(null);
  
  ValueNotifier<bool> get isLoggedIn => _isLoggedIn;
  ValueNotifier<User?> get currentUser => _currentUser;
  
  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    
    final user = User(id: '1', email: email, name: 'John Doe');
    _currentUser.value = user;
    _isLoggedIn.value = true;
  }
  
  void logout() {
    _currentUser.value = null;
    _isLoggedIn.value = false;
  }
}

class UserService {
  Future<List<User>> fetchUsers() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      User(id: '1', email: 'user1@example.com', name: 'User 1'),
      User(id: '2', email: 'user2@example.com', name: 'User 2'),
    ];
  }
  
  Future<void> updateUser(User user) async {
    await Future.delayed(Duration(seconds: 1));
    print('Updated user: ${user.name}');
  }
}

class ApiService {
  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return 'Data from API';
  }
}

class User {
  final String id;
  final String email;
  final String name;
  
  User({required this.id, required this.email, required this.name});
}
```

### App Manager with Commands

```dart
class AppManager extends ChangeNotifier {
  final AuthService _authService = di<AuthService>();
  final UserService _userService = di<UserService>();
  final ApiService _apiService = di<ApiService>();
  
  List<User> _users = [];
  String _data = '';
  
  List<User> get users => _users;
  String get data => _data;
  
  // Commands initialized directly in constructor
  late final loginCommand = Command.createAsyncNoParamNoResult(() async {
    await _authService.login('user@example.com', 'password');
  });
  
  late final logoutCommand = Command.createAsyncNoParamNoResult(() async {
    _authService.logout();
  });
  
  late final fetchUsersCommand = Command.createAsyncNoParamNoResult(() async {
    _users = await _userService.fetchUsers();
    notifyListeners();
  });
  
  late final fetchDataCommand = Command.createAsyncNoParamNoResult(() async {
    _data = await _apiService.fetchData();
    notifyListeners();
  });
  
  late final updateUserCommand = Command.createAsyncNoResult<User>(
    (user) async {
      await _userService.updateUser(user);
    },
  );
}
```

### Search Manager

```dart
class SearchManager extends ChangeNotifier {
  List<SearchResult> _searchResults = [];
  
  List<SearchResult> get searchResults => _searchResults;
  
  // Command initialized directly in constructor
  late final searchCommand = Command.createAsyncNoResult<String>(
    (searchTerm) async {
      // Simulate search
      await Future.delayed(Duration(seconds: 1));
      _searchResults = [
        SearchResult(title: 'Result 1 for $searchTerm', description: 'Description 1'),
        SearchResult(title: 'Result 2 for $searchTerm', description: 'Description 2'),
      ];
      notifyListeners();
    },
  );
}

class SearchResult {
  final String title;
  final String description;
  
  SearchResult({required this.title, required this.description});
}
```

### Form Manager

```dart
class FormManager extends ChangeNotifier {
  final _email = ValueNotifier<String>('');
  final _password = ValueNotifier<String>('');
  final _confirmPassword = ValueNotifier<String>('');
  
  ValueNotifier<String> get email => _email;
  ValueNotifier<String> get password => _password;
  ValueNotifier<String> get confirmPassword => _confirmPassword;
  
  // Use listen_it to create validation streams
  late final ValueNotifier<bool> _isEmailValid;
  late final ValueNotifier<bool> _isPasswordValid;
  late final ValueNotifier<bool> _doPasswordsMatch;
  late final ValueNotifier<bool> _isFormValid;
  
  // Command initialized directly in constructor
  late final submitCommand = Command.createAsyncNoParamNoResult(() async {
    // Form submission logic
    await Future.delayed(Duration(seconds: 2));
    print('Form submitted: ${_email.value}');
  });
  
  FormManager() {
    _setupValidation();
    _setupCommandState();
  }
  
  void _setupValidation() {
    // Email validation
    _isEmailValid = _email.map<bool>((email) => 
      email.contains('@') && email.contains('.')
    );
    
    // Password validation
    _isPasswordValid = _password.map<bool>((password) => 
      password.length >= 6
    );
    
    // Password confirmation
    _doPasswordsMatch = _password.combineLatest(
      _confirmPassword,
      (password, confirmPassword) => password == confirmPassword
    );
    
    // Overall form validation
    _isFormValid = _isEmailValid.combineLatest(
      _isPasswordValid,
      (emailValid, passwordValid) => emailValid && passwordValid
    ).combineLatest(
      _doPasswordsMatch,
      (formValid, passwordsMatch) => formValid && passwordsMatch
    );
  }
  
  void _setupCommandState() {
    // Update command state based on form validation
    _isFormValid.listen((isValid, _) {
      submitCommand.canExecute = isValid;
    });
  }
  
  ValueNotifier<bool> get isEmailValid => _isEmailValid;
  ValueNotifier<bool> get isPasswordValid => _isPasswordValid;
  ValueNotifier<bool> get doPasswordsMatch => _doPasswordsMatch;
  ValueNotifier<bool> get isFormValid => _isFormValid;
}
```

### Main App Widget

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IT Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget with WatchItMixin {
  @override
  Widget build(BuildContext context) {
    // Watch authentication state
    final isLoggedIn = watchValue((AuthService a) => a.isLoggedIn);
    final currentUser = watchValue((AuthService a) => a.currentUser);
    
    // Watch app manager state
    final users = watchPropertyValue((AppManager m) => m.users);
    final data = watchPropertyValue((AppManager m) => m.data);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter IT Demo'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: di<AppManager>().logoutCommand,
            ),
        ],
      ),
      body: isLoggedIn
        ? _buildLoggedInContent(currentUser, users, data)
        : _buildLoginContent(),
    );
  }
  
  Widget _buildLoginContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Please log in'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: di<AppManager>().loginCommand,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoggedInContent(User? user, List<User> users, String data) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${user?.name}!', style: TextStyle(fontSize: 24)),
          SizedBox(height: 32),
          
          Text('Data: $data', style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: di<AppManager>().fetchDataCommand,
            child: Text('Fetch Data'),
          ),
          
          SizedBox(height: 32),
          Text('Users:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: di<AppManager>().fetchUsersCommand,
            child: Text('Fetch Users'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: ElevatedButton(
                    onPressed: () => di<AppManager>().updateUserCommand.execute(user),
                    child: Text('Update'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Search with Debouncing Example

```dart
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with WatchItMixin {
  final searchController = TextEditingController();
  final searchTermNotifier = ValueNotifier<String>('');
  StreamSubscription? _searchSubscription;
  
  @override
  void initState() {
    super.initState();
    
    // Use listen_it to debounce search
    final debouncedSearch = searchTermNotifier.debounce(
      Duration(milliseconds: 300)
    );
    
    _searchSubscription = debouncedSearch.listen((searchTerm, _) {
      if (searchTerm.isNotEmpty) {
        di<SearchManager>().searchCommand.execute(searchTerm);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final searchResults = watchPropertyValue((SearchManager m) => m.searchResults);
    final isSearching = watchValue((SearchManager m) => m.searchCommand.isExecuting);
    
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchTermNotifier.value = value;
              },
            ),
          ),
          if (isSearching)
            LinearProgressIndicator()
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return ListTile(
                    title: Text(result.title),
                    subtitle: Text(result.description),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchSubscription?.cancel();
    searchController.dispose();
    searchTermNotifier.dispose();
    super.dispose();
  }
}
``` 