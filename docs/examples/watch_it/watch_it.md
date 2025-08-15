---
title: watch_it Examples
---

# watch_it Examples

This section contains examples for using the `watch_it` package for reactive state management in Flutter applications.

## Basic Usage

### ChangeNotifier Example

```dart
import 'package:watch_it/watch_it.dart';

// Create a ChangeNotifier based model
class UserModel extends ChangeNotifier {
  String _name = '';
  String get name => _name;
  
  set name(String value) {
    _name = value;
    notifyListeners();
  }
  
  void updateName(String newName) {
    name = newName;
  }
}

// Register it with get_it
void setup() {
  di.registerSingleton<UserModel>(UserModel());
}

// Watch it in a widget
class UserNameText extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final userName = watchPropertyValue((UserModel m) => m.name);
    return Text('Hello, $userName!');
  }
}
```

### ValueNotifier Example

```dart
class CounterModel {
  final count = ValueNotifier<int>(0);
  
  void increment() {
    count.value++;
  }
  
  void decrement() {
    count.value--;
  }
}

void setup() {
  di.registerSingleton<CounterModel>(CounterModel());
}

class CounterWidget extends StatelessWidget with WatchItMixin {
  @override
  Widget build(BuildContext context) {
    final count = watchValue((CounterModel m) => m.count);
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => di<CounterModel>().increment(),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

## Advanced Examples

### Multiple Watch Methods

```dart
class ComplexModel extends ChangeNotifier {
  String _name = '';
  int _age = 0;
  bool _isActive = false;
  
  String get name => _name;
  int get age => _age;
  bool get isActive => _isActive;
  
  void updateName(String name) {
    _name = name;
    notifyListeners();
  }
  
  void updateAge(int age) {
    _age = age;
    notifyListeners();
  }
  
  void toggleActive() {
    _isActive = !_isActive;
    notifyListeners();
  }
}

class ComplexWidget extends StatelessWidget with WatchItMixin {
  @override
  Widget build(BuildContext context) {
    // Watch multiple properties
    final name = watchPropertyValue((ComplexModel m) => m.name);
    final age = watchPropertyValue((ComplexModel m) => m.age);
    final isActive = watchPropertyValue((ComplexModel m) => m.isActive);
    
    return Column(
      children: [
        Text('Name: $name'),
        Text('Age: $age'),
        Text('Active: $isActive'),
        ElevatedButton(
          onPressed: () => di<ComplexModel>().toggleActive(),
          child: Text('Toggle Active'),
        ),
      ],
    );
  }
}
```

### Stream Example

```dart
class StreamModel {
  final _dataStream = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStream.stream;
  
  void emitData(String data) {
    _dataStream.add(data);
  }
  
  void dispose() {
    _dataStream.close();
  }
}

void setup() {
  di.registerSingleton<StreamModel>(StreamModel());
}

class StreamWidget extends StatelessWidget with WatchItMixin {
  @override
  Widget build(BuildContext context) {
    final data = watchStream((StreamModel m) => m.dataStream, 'No data');
    
    return Column(
      children: [
        Text('Stream Data: $data'),
        ElevatedButton(
          onPressed: () => di<StreamModel>().emitData('New data: ${DateTime.now()}'),
          child: Text('Emit Data'),
        ),
      ],
    );
  }
}
```

### Future Example

```dart
class FutureModel {
  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    return 'Data loaded at ${DateTime.now()}';
  }
}

void setup() {
  di.registerSingleton<FutureModel>(FutureModel());
}

class FutureWidget extends StatelessWidget with WatchItMixin {
  @override
  Widget build(BuildContext context) {
    final data = watchFuture((FutureModel m) => m.fetchData(), 'Loading...');
    
    return Text('Future Data: $data');
  }
}
```

### Using Different GetIt Instances

```dart
// If you want to use a different get_it instance
class CustomWidget extends StatelessWidget with WatchItMixin {
  @override
  Widget build(BuildContext context) {
    // Pass custom get_it instance
    final userName = watchPropertyValue(
      (UserModel m) => m.name,
      getIt: GetIt.instance, // or your custom instance
    );
    
    return Text('User: $userName');
  }
}
``` 