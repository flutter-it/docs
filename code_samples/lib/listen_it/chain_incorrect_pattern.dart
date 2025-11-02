// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:listen_it/listen_it.dart';

// #region valueListenableBuilder_inline
class BadWidget extends StatelessWidget {
  final ValueNotifier<int> source;

  BadWidget(this.source, {super.key});

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

// #region builder_inline
class BadWidgetInBuilder extends StatelessWidget {
  final ValueNotifier<int> source;

  BadWidgetInBuilder(this.source, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: source,
      builder: (context, value, child) {
        // ❌ WRONG: Chain created in builder - NEW CHAIN EVERY REBUILD!
        final chain = source.map((x) => x * 2); // MEMORY LEAK!
        return Text('${chain.value}');
      },
    );
  }
}
// #endregion builder_inline

// #region stateful_build
class BadStatefulWidget extends StatefulWidget {
  final ValueNotifier<int> source;

  const BadStatefulWidget(this.source, {super.key});

  @override
  State<BadStatefulWidget> createState() => _BadStatefulWidgetState();
}

class _BadStatefulWidgetState extends State<BadStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    // ❌ WRONG: Chain created in build - NEW CHAIN EVERY REBUILD!
    final chain = widget.source.map((x) => x * 2); // MEMORY LEAK!
    return Text('${chain.value}');
  }
}
// #endregion stateful_build
