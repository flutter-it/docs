// ignore_for_file: unused_local_variable, unreachable_from_main
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

void propertyValueDifference(BuildContext context) {
  // #region property_value_difference
  // Rebuilds on EVERY SettingsModel change
  final settings = watchIt<SettingsModel>();
  final darkMode1 = settings.darkMode;

  // Rebuilds ONLY when darkMode changes
  final darkMode2 = watchPropertyValue((SettingsModel m) => m.darkMode);
  // #endregion property_value_difference
}

void quickComparison(BuildContext context) {
  // #region quick_comparison
  // 1. watchValue - Watch ValueListenable property from get_it
  final todos = watchValue((TodoManager m) => m.todos);

  // 2. watchIt - When manager is a Listenable registered in get_it
  final manager = watchIt<CounterModel>();

  // 3. watch - Local or direct Listenable
  final counter = createOnce(() => ValueNotifier(0));
  final count = watch(counter).value;

  // 4. watchPropertyValue - Selective updates from Listenable registered in get_it
  final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);
  // #endregion quick_comparison
}

void watchValueUsage(BuildContext context) {
  // #region watchValue_usage
  final data = watchValue((DataManager m) => m.data);
  // #endregion watchValue_usage
}

void watchItUsage(BuildContext context) {
  // #region watchIt_usage
  final manager = watchIt<CounterModel>();
  // Can call methods on manager
  // #endregion watchIt_usage
}

void watchUsage(BuildContext context) {
  // #region watch_usage
  final controller = createOnce(() => TextEditingController());
  final text = watch(controller).value.text;
  // #endregion watch_usage
}

void watchPropertyValueUsage(BuildContext context) {
  // #region watchPropertyValue_usage
  // Only rebuild when THIS specific property changes
  final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);
  // #endregion watchPropertyValue_usage
}

void main() {}
