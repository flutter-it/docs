// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:listen_it/listen_it.dart';

// #region build_inline
class BadWidget extends StatelessWidget {
  final ValueNotifier<int> source;

  BadWidget(this.source, {super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ WRONG: Chain created in build - NEW CHAIN EVERY REBUILD!
    final chain = source.map((x) => x * 2); // MEMORY LEAK!
    return Text('${chain.value}');
  }
}
// #endregion build_inline

// #region valueListenableBuilder_inline
class BadWidgetValueListenable extends StatelessWidget {
  final ValueNotifier<int> source;

  BadWidgetValueListenable(this.source, {super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ WRONG: Chain created inline - NEW CHAIN EVERY REBUILD!
    return ValueListenableBuilder<int>(
      valueListenable: source.map((x) => x * 2), // MEMORY LEAK!
      builder: (context, value, child) => Text('$value'),
    );
  }
}
// #endregion valueListenableBuilder_inline
