import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();
final formValid = ValueNotifier<bool>(false);

// #region async_ui_feedback
late final loadDataCommand = Command.createAsyncNoParam<List<Data>>(
  () => api.fetchData(),
  initialValue: [],
);
// Automatic isRunning, error handling, UI integration
// #endregion async_ui_feedback

// #region operations_can_fail
late final saveCommand = Command.createAsyncNoResult<Data>(
  (data) => api.save(data),
  errorFilter: PredicatesErrorFilter([
    (e, _) => errorFilter<ApiException>(e, ErrorReaction.localHandler),
  ]),
);
// #endregion operations_can_fail

// #region user_triggered
late final submitCommand = Command.createAsyncNoResult<FormData>(
  (data) => api.submit(data),
  restriction: formValid.map((valid) => !valid),
);
// #endregion user_triggered

// #region sync_input_operators
class SearchManager {
  late final textChangedCommand = Command.createSync<String, String>(
    (s) => s,
    initialValue: '',
  );

  late final searchCommand = Command.createAsync<String, List<Result>>(
    (query) => api.search(query),
    initialValue: [],
  );

  SearchManager() {
    // Debounce text input before triggering search
    textChangedCommand.debounce(Duration(milliseconds: 500)).listen((text, _) {
      if (text.isNotEmpty) {
        searchCommand(text);
      }
    });
  }
}
// #endregion sync_input_operators

// #region dont_use_getter
// ignore_for_file: unused_field, unused_local_variable
String _name = '';

// ❌ Overkill
late final getNameCommand = Command.createSyncNoParam<String>(
  () => _name,
  initialValue: '',
);

// ✅ Just use a ValueNotifier
final name = ValueNotifier<String>('');
// #endregion dont_use_getter

// #region dont_use_computation
// ❌ Unnecessary
late final calculateCommand = Command.createSync<int, int>(
  (n) => n * 2,
  initialValue: 0,
);

// ✅ Just use a function
int calculate(int n) => n * 2;
// #endregion dont_use_computation

// #region dont_use_toggle
bool _enabled = false;

// ❌ Overcomplicated
late final toggleCommand = Command.createSyncNoParam<bool>(
  () => !_enabled,
  initialValue: false,
);

// ✅ Use ValueNotifier directly
final enabled = ValueNotifier<bool>(false);
void toggle() => enabled.value = !enabled.value;
// #endregion dont_use_toggle

void main() {
  // Examples compile but don't run
}
