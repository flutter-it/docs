// ignore_for_file: unused_local_variable, unused_field
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final api = ApiClient();
final getIt = GetIt.instance;

// #region initial_values
class HeavyObject {
  final List<int> data = List.generate(1000, (i) => i);
}

// ❌ Wasteful: Large initial value that will be replaced
late final loadCommandBad = Command.createAsyncNoParam<List<HeavyObject>>(
  () async => [HeavyObject()],
  initialValue:
      List.generate(1000, (_) => HeavyObject()), // Immediately discarded!
);

// ✅ Lightweight initial value
late final loadCommandGood = Command.createAsyncNoParam<List<HeavyObject>>(
  () async => [HeavyObject()],
  initialValue: [], // Empty list is cheap
);
// #endregion initial_values

// #region debounce
class SearchManagerDebounce {
  late final searchTextCommand = Command.createSync<String, String>(
    (text) => text,
    initialValue: '',
  );

  late final searchCommand = Command.createAsync<String, List<Result>>(
    (query) => api.search(query),
    initialValue: [],
  );

  SearchManagerDebounce() {
    // Debounce text changes
    searchTextCommand.debounce(Duration(milliseconds: 300)).listen((text, _) {
      if (text.isNotEmpty) {
        searchCommand(text);
      }
    });
  }
}
// #endregion debounce

// #region dispose
class DataManager {
  late final command = Command.createAsyncNoParam<Data>(
    () => api.fetchData().then((list) => list.first),
    initialValue: Data.empty(),
  );

  // ✅ Always dispose in cleanup
  void dispose() {
    command.dispose();
  }
}

// With StatefulWidget
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final manager = DataManager();

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();
}

// With get_it scopes
void registerWithGetIt() {
  getIt.registerLazySingleton<DataManager>(
    () => DataManager(),
    dispose: (manager) => manager.dispose(),
  );
}
// #endregion dispose

// #region rebuilds
class RebuildExample extends StatelessWidget {
  final Command<void, String> command;

  const RebuildExample({super.key, required this.command});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ❌ Rebuilds on every command property change
        ValueListenableBuilder(
          valueListenable: command.results,
          builder: (context, result, _) => Text(result.data?.toString() ?? ''),
        ),

        // ✅ Only rebuilds when value changes
        ValueListenableBuilder(
          valueListenable: command,
          builder: (context, data, _) => Text(data.toString()),
        ),
      ],
    );
  }
}
// #endregion rebuilds

void main() {
  registerWithGetIt();
}
