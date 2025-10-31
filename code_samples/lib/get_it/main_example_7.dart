import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
void main() {
  configureDependencies(); // First call
  configureDependencies(); // ❌ Second call - ERROR!
  runApp(MyApp());
}
// #endregion example
