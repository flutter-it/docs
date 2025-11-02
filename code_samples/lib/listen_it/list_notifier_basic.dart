import '_shared/stubs.dart';

// #region example
void main() {
  final items = ListNotifier<String>(data: []);

  // Listen to changes - gets notified on every mutation
  items.listen((list, _) {
    print('List changed: $list');
  });

  items.add('first item');
  // Prints: List changed: [first item]

  items.add('second item');
  // Prints: List changed: [first item, second item]

  items.addAll(['third', 'fourth']);
  // Prints: List changed: [first item, second item, third, fourth]

  items.removeAt(1);
  // Prints: List changed: [first item, third, fourth]

  items[0] = 'updated first';
  // Prints: List changed: [updated first, third, fourth]
}
// #endregion example
