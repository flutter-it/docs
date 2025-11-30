import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region search_example
class SearchManager {
  late final textChangedCommand = Command.createSync<String, String>(
    (s) => s,
    initialValue: '',
  );

  late final searchCommand = Command.createAsync<String, List<Result>>(
    (query) => api.search(query),
    initialValue: [],
  );

  late final ListenableSubscription _subscription;

  SearchManager() {
    // Debounce + filter + pipe to search command
    _subscription = textChangedCommand
        .debounce(Duration(milliseconds: 500))
        .where((text) => text.length >= 3)
        .pipeToCommand(searchCommand);
  }

  void dispose() {
    _subscription.cancel();
    textChangedCommand.dispose();
    searchCommand.dispose();
  }
}
// #endregion search_example

// #region filter_example
class FilteredPipeManager {
  late final inputCommand = Command.createSync<int, int>(
    (n) => n,
    initialValue: 0,
  );

  late final processCommand = Command.createAsync<int, String>(
    (n) async => 'Processed: $n',
    initialValue: '',
  );

  late final ListenableSubscription _subscription;

  FilteredPipeManager() {
    // Only pipe positive numbers, debounced
    _subscription = inputCommand
        .where((n) => n > 0)
        .debounce(Duration(milliseconds: 200))
        .pipeToCommand(processCommand);
  }

  void dispose() {
    _subscription.cancel();
    inputCommand.dispose();
    processCommand.dispose();
  }
}
// #endregion filter_example

void main() {
  // Examples compile but don't run
}
