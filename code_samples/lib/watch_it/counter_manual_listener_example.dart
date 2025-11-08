import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late CounterManager _manager;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _manager = di<CounterManager>();
    _count = _manager.count.value;
    _manager.count.addListener(_onCountChanged); // Manual listener
  }

  void _onCountChanged() {
    setState(() {
      _count = _manager.count.value;
    });
  }

  @override
  void dispose() {
    _manager.count.removeListener(_onCountChanged); // Don't forget!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $_count');
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: CounterWidget()));
}
