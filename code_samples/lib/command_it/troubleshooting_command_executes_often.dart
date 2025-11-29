// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

late final Command<String, void> command;
late final Command<String, List<Data>> actualSearchCommand;

// #region diagnosis_bad
class BadCallInBuild extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    command('query'); // ❌️ Called on every build!
    return SomeWidget();
  }
}
// #endregion diagnosis_bad

// #region solution1
class GoodEventHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Call command only when button is pressed
    return ElevatedButton(
      onPressed: () => command('query'),
      child: const Text('Search'),
    );
  }
}
// #endregion solution1

// #region solution2
class GoodCallOnce extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((context) => di<DataManager>().loadCommand());
    return SomeWidget();
  }
}
// #endregion solution2

// #region solution3
class SearchManager {
  // In your manager
  late final debouncedSearch = Command.createSync<String, String>(
    (query) => query,
    initialValue: '',
  );

  late final actualSearch = Command.createAsync<String, List<Data>>(
    (query) => ApiClient().fetchData(),
    initialValue: [],
  );

  SearchManager() {
    debouncedSearch.debounce(Duration(milliseconds: 500)).listen((query, _) {
      actualSearch(query);
    });
  }
}
// #endregion solution3

class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class DataManager {
  late final loadCommand = Command.createAsyncNoParam<List<Data>>(
    () => ApiClient().fetchData(),
    initialValue: [],
  );
}

void main() {}
