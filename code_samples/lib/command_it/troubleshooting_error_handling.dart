// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

Future<List<Data>> fetchData() => ApiClient().fetchData();

// #region global_only_bad
final commandGlobalOnly = Command.createAsync<String, List<Data>>(
  (query) => fetchData(),
  initialValue: [],
  errorFilter: const GlobalErrorFilter(), // ❌️ UI won't see errors!
);
// #endregion global_only_bad

// #region local_filter_good
final commandLocalFilter = Command.createAsync<String, List<Data>>(
  (query) => fetchData(),
  initialValue: [],
  errorFilter: const LocalErrorFilter(), // ✅ Notifies .errors property
  // Or: const LocalAndGlobalErrorFilter() for both
);
// #endregion local_filter_good

void main() {}
