---
title: listen_it Examples
---

# listen_it Examples

This section contains examples for using the `listen_it` package for event-driven architecture in Flutter applications.

## Basic Usage

### listen() Extension

```dart
import 'package:listen_it/listen_it.dart';

void basicListenExample() {
  final counter = ValueNotifier<int>(0);
  
  // Listen to value changes
  final subscription = counter.listen((value, _) {
    print('Counter changed to: $value');
  });
  
  // Update the value
  counter.value = 1; // Prints: Counter changed to: 1
  counter.value = 2; // Prints: Counter changed to: 2
  
  // Cancel the subscription
  subscription.cancel();
  
  counter.value = 3; // Nothing printed
}

void listenWithSubscription() {
  final counter = ValueNotifier<int>(0);
  
  counter.listen((value, subscription) {
    print('Counter: $value');
    
    // Cancel subscription when counter reaches 5
    if (value >= 5) {
      subscription.cancel();
    }
  });
  
  // This will print 0, 1, 2, 3, 4, 5 and then stop
  for (int i = 0; i <= 10; i++) {
    counter.value = i;
  }
}
```

### map() Extension

```dart
void mapExample() {
  final nameNotifier = ValueNotifier<String>('john');
  
  // Convert to uppercase
  final upperCaseName = nameNotifier.map((name) => name.toUpperCase());
  
  // Listen to the transformed value
  upperCaseName.listen((value, _) {
    print('Uppercase name: $value');
  });
  
  nameNotifier.value = 'jane'; // Prints: Uppercase name: JANE
  nameNotifier.value = 'bob';  // Prints: Uppercase name: BOB
}

void mapTypeChange() {
  final ageNotifier = ValueNotifier<int>(25);
  
  // Convert int to string
  final ageString = ageNotifier.map<String>((age) => 'Age: $age');
  
  ageString.listen((value, _) {
    print(value); // Prints: Age: 25, Age: 30, etc.
  });
  
  ageNotifier.value = 30;
  ageNotifier.value = 35;
}
```

### where() Extension

```dart
void whereExample() {
  final numberNotifier = ValueNotifier<int>(0);
  
  // Only listen to even numbers
  final evenNumbers = numberNotifier.where((number) => number.isEven);
  
  evenNumbers.listen((value, _) {
    print('Even number: $value');
  });
  
  // This will only print even numbers
  for (int i = 0; i <= 10; i++) {
    numberNotifier.value = i;
  }
  // Prints: Even number: 0, Even number: 2, Even number: 4, etc.
}

void conditionalFilter() {
  final numberNotifier = ValueNotifier<int>(0);
  bool onlyPositive = true;
  
  // Dynamic filter based on condition
  final filteredNumbers = numberNotifier.where((number) {
    return onlyPositive ? number > 0 : true;
  });
  
  filteredNumbers.listen((value, _) {
    print('Filtered number: $value');
  });
  
  numberNotifier.value = -5; // Nothing printed (onlyPositive = true)
  numberNotifier.value = 5;  // Prints: Filtered number: 5
  
  onlyPositive = false;
  numberNotifier.value = -3; // Prints: Filtered number: -3
}
```

## Advanced Examples

### select() Extension

```dart
class User {
  final String name;
  final int age;
  final String email;
  
  User({required this.name, required this.age, required this.email});
}

void selectExample() {
  final userNotifier = ValueNotifier<User>(
    User(name: 'John', age: 25, email: 'john@example.com')
  );
  
  // Only react to age changes
  final ageNotifier = userNotifier.select<int>((user) => user.age);
  
  ageNotifier.listen((age, _) {
    print('Age changed to: $age');
  });
  
  // This will trigger the listener
  userNotifier.value = User(name: 'John', age: 26, email: 'john@example.com');
  
  // This will NOT trigger the listener (age didn't change)
  userNotifier.value = User(name: 'John', age: 26, email: 'john2@example.com');
}
```

### Chaining Extensions

```dart
void chainingExample() {
  final numberNotifier = ValueNotifier<int>(0);
  
  // Chain multiple transformations
  final processedNumbers = numberNotifier
    .where((number) => number > 0)        // Only positive numbers
    .map((number) => number * 2)          // Double the number
    .map<String>((number) => 'Result: $number'); // Convert to string
  
  processedNumbers.listen((value, _) {
    print(value);
  });
  
  numberNotifier.value = -1; // Nothing printed (filtered out)
  numberNotifier.value = 5;  // Prints: Result: 10
  numberNotifier.value = 10; // Prints: Result: 20
}
```

### debounce() Extension

```dart
void debounceExample() {
  final searchTermNotifier = ValueNotifier<String>('');
  
  // Debounce search term changes
  final debouncedSearch = searchTermNotifier.debounce(
    Duration(milliseconds: 500)
  );
  
  debouncedSearch.listen((searchTerm, _) {
    print('Searching for: $searchTerm');
    // In real app, this would call your search API
  });
  
  // Rapid changes - only the last one will trigger after 500ms
  searchTermNotifier.value = 'h';
  searchTermNotifier.value = 'he';
  searchTermNotifier.value = 'hel';
  searchTermNotifier.value = 'hell';
  searchTermNotifier.value = 'hello';
  
  // After 500ms, only "Searching for: hello" will be printed
}
```

### combineLatest() Extension

```dart
void combineLatestExample() {
  final firstNameNotifier = ValueNotifier<String>('');
  final lastNameNotifier = ValueNotifier<String>('');
  
  // Combine two ValueNotifiers
  final fullNameNotifier = firstNameNotifier.combineLatest(
    lastNameNotifier,
    (firstName, lastName) => '$firstName $lastName'.trim()
  );
  
  fullNameNotifier.listen((fullName, _) {
    print('Full name: $fullName');
  });
  
  firstNameNotifier.value = 'John';     // Prints: Full name: John
  lastNameNotifier.value = 'Doe';       // Prints: Full name: John Doe
  firstNameNotifier.value = 'Jane';     // Prints: Full name: Jane Doe
}
```

### Real-World Widget Example

```dart
class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final searchController = TextEditingController();
  final searchTermNotifier = ValueNotifier<String>('');
  StreamSubscription? _searchSubscription;

  @override
  void initState() {
    super.initState();
    
    // Debounce search term and listen to changes
    final debouncedSearch = searchTermNotifier.debounce(
      Duration(milliseconds: 300)
    );
    
    _searchSubscription = debouncedSearch.listen((searchTerm, _) {
      if (searchTerm.isNotEmpty) {
        performSearch(searchTerm);
      }
    });
  }

  void performSearch(String term) {
    print('Searching for: $term');
    // Implement your search logic here
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Search',
        suffixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        searchTermNotifier.value = value;
      },
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