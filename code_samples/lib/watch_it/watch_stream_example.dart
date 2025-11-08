import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class TimerWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Create a timer stream once
    final timerStream = createOnce(() => TimerStream());

    // watchStream returns an AsyncSnapshot similar to StreamBuilder
    // Widget rebuilds whenever the stream emits a new value
    final snapshot = watchStream((_) => timerStream.stream);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Timer Stream Example',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        if (snapshot.hasData)
          Text(
            'Count: ${snapshot.data}',
            style: Theme.of(context).textTheme.headlineLarge,
          )
        else if (snapshot.hasError)
          Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          )
        else
          const CircularProgressIndicator(),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: TimerWidget(),
      ),
    ),
  ));
}
