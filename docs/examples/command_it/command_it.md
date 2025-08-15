---
title: command_it Examples
---

# command_it Examples

This section contains examples for using the `command_it` package for implementing the command pattern in Flutter applications.

## Basic Usage

### Simple Counter Manager

```dart
import 'package:command_it/command_it.dart';
import 'package:get_it/get_it.dart';

// Global service locator
final di = GetIt.instance;

class CounterManager {
  int counter = 0;
  
  // Commands initialized directly in constructor
  late final incrementCommand = Command.createSyncNoParam(() {
    counter++;
    return counter.toString();
  }, '0');
  
  late final decrementCommand = Command.createSyncNoParam(() {
    counter--;
    return counter.toString();
  }, '0');
}

// Widget that uses the manager
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterManager = di<CounterManager>();
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            ValueListenableBuilder<String>(
              valueListenable: counterManager.incrementCommand,
              builder: (context, value, _) {
                return Text(
                  value,
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: counterManager.decrementCommand,
            tooltip: 'Decrement',
            child: Icon(Icons.remove),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: counterManager.incrementCommand,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

### User Manager with Async Commands

```dart
class UserService {
  Future<User> fetchUser(int id) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    return User(id: id, name: 'User $id');
  }
  
  Future<void> updateUser(User user) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    print('Updated user: ${user.name}');
  }
}

class User {
  final int id;
  final String name;
  
  User({required this.id, required this.name});
}

class UserManager {
  // Commands initialized directly in constructor
  late final fetchUserCommand = Command.createAsync<int, User>(
    (userId) => di<UserService>().fetchUser(userId),
    null, // initial value
  );
  
  late final updateUserCommand = Command.createAsyncNoResult<User>(
    (user) => di<UserService>().updateUser(user),
  );
}

// Widget that uses the manager
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userManager = di<UserManager>();
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<User?>(
              valueListenable: userManager.fetchUserCommand,
              builder: (context, user, _) {
                if (userManager.fetchUserCommand.isExecuting.value) {
                  return CircularProgressIndicator();
                }
                
                if (user != null) {
                  return Column(
                    children: [
                      Text('User: ${user.name}'),
                      ElevatedButton(
                        onPressed: () => userManager.updateUserCommand.execute(user),
                        child: Text('Update User'),
                      ),
                    ],
                  );
                }
                
                return Text('No user loaded');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => userManager.fetchUserCommand.execute(1),
              child: Text('Load User 1'),
            ),
            ElevatedButton(
              onPressed: () => userManager.fetchUserCommand.execute(2),
              child: Text('Load User 2'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Advanced Examples

### API Manager with Error Handling

```dart
class ApiService {
  Future<String> fetchData() async {
    // Simulate API call that might fail
    await Future.delayed(Duration(seconds: 1));
    
    if (DateTime.now().millisecond % 3 == 0) {
      throw Exception('Network error');
    }
    
    return 'Data loaded successfully';
  }
}

class ApiManager {
  late final fetchDataCommand = Command.createAsync<void, String>(
    (_) => di<ApiService>().fetchData(),
    'No data',
  );
}

// Widget that uses the manager
class ErrorHandlingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiManager = di<ApiManager>();
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<String>(
              valueListenable: apiManager.fetchDataCommand,
              builder: (context, data, _) {
                if (apiManager.fetchDataCommand.isExecuting.value) {
                  return CircularProgressIndicator();
                }
                
                if (apiManager.fetchDataCommand.thrownException != null) {
                  return Column(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      Text('Error: ${apiManager.fetchDataCommand.thrownException}'),
                    ],
                  );
                }
                
                return Text('Data: $data');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: apiManager.fetchDataCommand.canExecute ? apiManager.fetchDataCommand : null,
              child: Text('Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Form Manager with Validation

```dart
class FormManager extends ChangeNotifier {
  final _email = ValueNotifier<String>('');
  final _password = ValueNotifier<String>('');
  
  ValueNotifier<String> get email => _email;
  ValueNotifier<String> get password => _password;
  
  bool get isValid => _email.value.isNotEmpty && _password.value.length >= 6;
  
  // Command initialized directly in constructor
  late final submitCommand = Command.createAsyncNoParamNoResult(() async {
    // Simulate form submission
    await Future.delayed(Duration(seconds: 2));
    print('Form submitted: ${_email.value}');
  });

  FormManager() {
    // Listen to form changes to update command state
    _email.addListener(_updateCommandState);
    _password.addListener(_updateCommandState);
  }

  void _updateCommandState() {
    submitCommand.canExecute = isValid;
  }

  void updateEmail(String email) {
    _email.value = email;
  }

  void updatePassword(String password) {
    _password.value = password;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}

// Widget that uses the manager
class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formManager = di<FormManager>();
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: formManager.updateEmail,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: formManager.updatePassword,
            ),
            SizedBox(height: 32),
            ValueListenableBuilder<bool>(
              valueListenable: formManager.submitCommand,
              builder: (context, isExecuting, _) {
                return ElevatedButton(
                  onPressed: formManager.submitCommand.canExecute && !isExecuting 
                    ? formManager.submitCommand 
                    : null,
                  child: isExecuting 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
``` 