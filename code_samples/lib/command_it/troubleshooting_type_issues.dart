// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

Future<List<Item>> fetchData(String param) async {
  await simulateDelay();
  return [Item()];
}

// #region inference_bad
final commandNoTypes = Command.createAsync(
  // ❌️ Dart can't infer types from context
  (param) async => await fetchData(param as String),
  initialValue: <Item>[],
);
// #endregion inference_bad

// #region inference_good
// ✅ Explicit types
final commandWithTypes = Command.createAsync<String, List<Item>>(
  (query) async => await fetchData(query),
  initialValue: [],
);
// #endregion inference_good

class Item {}

void main() {}
