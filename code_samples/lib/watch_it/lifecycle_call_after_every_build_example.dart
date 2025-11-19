import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

// #region example
class ScrollToTopWidget extends StatelessWidget with WatchItMixin {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final counter = watch(counterNotifier);

    // Scroll to top after every build where counter changes
    // The cancel function allows stopping the callback when needed
    callAfterEveryBuild((context, cancel) {
      if (counter.value > 5) {
        // Stop calling this callback after counter reaches 5
        cancel();
        return;
      }

      // Scroll to top after each rebuild
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Scroll Example')),
      body: ListView.builder(
        controller: scrollController,
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item $index - Counter: ${counter.value}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterNotifier.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
// #endregion example

// Stub classes
class Counter extends ValueNotifier<int> {
  Counter() : super(0);
  void increment() => value++;
}

final counterNotifier = Counter();

void main() {
  runApp(MaterialApp(
    home: ScrollToTopWidget(),
  ));
}
