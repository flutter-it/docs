import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

class Model {
  final ValueNotifier<int> source = ValueNotifier(0);
}

void _setupGetIt() {
  getIt.registerSingleton<Model>(Model());
}

// #region watchValue_safe
class SafeWatchItWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ SAFE: watch_it caches selectors by default
    // Chain created ONCE on first build, reused on subsequent builds
    final value = watchValue((Model m) => m.source.map((x) => x * 2));
    return Text('$value');
  }
}
// #endregion watchValue_safe

// #region registerHandler_safe
class SafeRegisterHandlerWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ SAFE: watch_it caches selectors by default
    // Chain created ONCE on first build, reused on subsequent builds
    registerHandler(
      select: (Model m) => m.source.map((x) => x * 2),
      handler: (context, value, cancel) {
        print('Value changed: $value');
      },
    );
    return Container();
  }
}
// #endregion registerHandler_safe

// #region unsafe_override
class UnsafeWatchItWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ UNSAFE: Explicitly disabling cache!
    // Creates NEW CHAIN every rebuild - MEMORY LEAK!
    final value = watchValue(
      (Model m) => m.source.map((x) => x * 2),
      allowObservableChange: true, // DON'T DO THIS unless needed!
    );
    return Text('$value');
  }
}
// #endregion unsafe_override

// #region valid_use_case
class Settings {
  final ValueNotifier<bool> darkMode = ValueNotifier(false);
  final ValueNotifier<List<String>> darkColors = ValueNotifier(['#000']);
  final ValueNotifier<List<String>> lightColors = ValueNotifier(['#FFF']);
}

class ValidDynamicObservable extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ VALID: Observable identity actually changes based on condition
    final colors = watchValue(
      (Settings s) => s.darkMode.value ? s.darkColors : s.lightColors,
      allowObservableChange: true, // Needed here!
    );
    return Text('Colors: $colors');
  }
}
// #endregion valid_use_case
