// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region diagnosis
class DiagnosisWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((DataManager m) => m.loadCommand.results);

    // During loading: result.isRunning = true, result.data = null
    // After error: result.hasError = true, result.data = null
    // After success: result.hasData = true, result.data = <your data>

    return Text(result.data.toString()); // ❌ Crashes during loading/error!
  }
}
// #endregion diagnosis

// #region solution1
class ManagerWithLastResult {
  late final loadCommand = Command.createAsyncNoParam<List<Item>>(
    () => api.fetchItems(),
    initialValue: [],
    includeLastResultInCommandResults: true, // ✅ Keep old data visible
  );
}

// Now in your widget:
// During loading: result.data = <previous successful data>
// After error: result.data = <previous successful data>
// After success: result.data = <new data>
// #endregion solution1

// #region solution2
class Solution2Widget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((DataManager m) => m.loadCommand.results);

    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return ErrorWidget(result.error!);

    return DataWidget(result.data!); // ✅ Safe - hasData is true
  }
}
// #endregion solution2

// #region solution3
class Solution3Widget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Command's value always has data (uses initialValue as fallback)
    final data = watchValue((DataManager m) => m.loadCommand);
    return DataWidget(data); // ✅ Always has a value
  }
}
// #endregion solution3

class DataWidget extends StatelessWidget {
  final List<Data> data;
  const DataWidget(this.data, {super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class DataManager {
  late final loadCommand = Command.createAsyncNoParam<List<Data>>(
    () => api.fetchData(),
    initialValue: [],
  );
}

class Item {}

extension on ApiClient {
  Future<List<Item>> fetchItems() async {
    await simulateDelay();
    return [Item()];
  }
}

void main() {}
