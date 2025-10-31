import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
// lib/main.dart
void main() {
  configureDependencies(); // Register all services FIRST
  runApp(MyApp());
}
// #endregion example
