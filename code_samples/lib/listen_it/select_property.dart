import '_shared/stubs.dart';

// #region example
void main() {
  final notifier = ValueNotifier(User(age: 18, name: "John"));

  // Only notifies when age changes
  final birthdayNotifier = notifier.select<int>((model) => model.age);

  birthdayNotifier.listen((age, _) => print('Age changed to: $age'));

  print('Initial age: ${birthdayNotifier.value}'); // 18

  // This triggers the listener (age changed)
  notifier.value = User(age: 19, name: "John");
  // Prints: Age changed to: 19

  // This does NOT trigger the listener (age unchanged)
  notifier.value = User(age: 19, name: "Johnny");
  // No output - name changed but age stayed the same

  // This triggers the listener (age changed)
  notifier.value = User(age: 20, name: "Johnny");
  // Prints: Age changed to: 20
}
// #endregion example
