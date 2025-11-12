import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

// #region example
class TimerWidget extends WatchingWidget {
  const TimerWidget({super.key, required this.timerStream});

  final Stream<int> timerStream;

  @override
  Widget build(BuildContext context) {
    // Watch a stream passed as parameter (not from get_it)
    final snapshot = watchStream(
      null, // No selector needed
      target: timerStream, // Watch this stream directly
      initialValue: 0,
    );

    return Text('Seconds: ${snapshot.data}');
  }
}
// #endregion example

void main() {
  // Create a local stream (not registered in get_it)
  final stream = Stream<int>.periodic(
    Duration(seconds: 1),
    (count) => count,
  );

  runApp(MaterialApp(home: TimerWidget(timerStream: stream)));
}
