import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class MyWidget extends StatelessWidget {
  final ValueNotifier<int> source;
  late final ValueListenable<int> chain;

  MyWidget(this.source, {super.key}) {
    // ✅ CORRECT: Chain created ONCE in constructor
    chain = source.map((x) => x * 2);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: chain, // Same object every rebuild - NO LEAK
      builder: (context, value, child) => Text('$value'),
    );
  }
}

// Alternative: Create chain as field initializer
class MyWidgetAlt extends StatelessWidget {
  final ValueNotifier<int> source;

  MyWidgetAlt(this.source, {super.key});

  // ✅ CORRECT: Chain created once as late final field
  late final ValueListenable<int> chain = source.map((x) => x * 2);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: chain, // Same object every rebuild - NO LEAK
      builder: (context, value, child) => Text('$value'),
    );
  }
}
// #endregion example
