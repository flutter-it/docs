// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region notify_only_when_changes
class ItemManager {
  late final loadCommand = Command.createAsyncNoParam<List<Item>>(
    () => api.fetchItems(),
    initialValue: [],
    notifyOnlyWhenValueChanges:
        true, // ✅ Only notify when data actually changes
  );
}
// #endregion notify_only_when_changes

class Item {}

extension on ApiClient {
  Future<List<Item>> fetchItems() async {
    await simulateDelay();
    return [Item()];
  }
}

void main() {}
