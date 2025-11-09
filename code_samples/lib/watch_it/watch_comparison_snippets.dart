// ignore_for_file: unused_local_variable, unreachable_from_main
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region property_value_difference
void propertyValueDifference(BuildContext context) {
  // Rebuilds on EVERY SettingsModel change
  final settings = watchIt<SettingsModel>();
  final darkMode1 = settings.darkMode;

  // Rebuilds ONLY when darkMode changes
  final darkMode2 = watchPropertyValue((SettingsModel m) => m.darkMode);
}
// #endregion property_value_difference

// #region quick_comparison
void quickComparison(BuildContext context) {
  // 1. watchValue - Most common
  final todos = watchValue((TodoManager m) => m.todos);

  // 2. watchIt - When manager IS a Listenable
  final manager = watchIt<CounterModel>();

  // 3. watch - Local or direct Listenable
  final counter = createOnce(() => ValueNotifier(0));
  final count = watch(counter).value;

  // 4. watchPropertyValue - Selective updates
  final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);
}
// #endregion quick_comparison

// #region watchValue_usage
void watchValueUsage(BuildContext context) {
  final data = watchValue((DataManager m) => m.data);
}
// #endregion watchValue_usage

// #region watchIt_usage
void watchItUsage(BuildContext context) {
  final manager = watchIt<CounterModel>();
  // Can call methods on manager
}
// #endregion watchIt_usage

// #region watch_usage
void watchUsage(BuildContext context) {
  final controller = createOnce(() => TextEditingController());
  final text = watch(controller).value.text;
}
// #endregion watch_usage

// #region watchPropertyValue_usage
void watchPropertyValueUsage(BuildContext context) {
  // Only rebuild when THIS specific property changes
  final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);
}
// #endregion watchPropertyValue_usage

void main() {}
