// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, undefined_identifier
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region async_snapshot_guide
void asyncSnapshotGuide(AsyncSnapshot snapshot) {
  // Check connection state
  snapshot.connectionState == ConnectionState.waiting;
  snapshot.connectionState == ConnectionState.done;

  // Check for data/errors
  snapshot.hasData; // true if data available
  snapshot.hasError; // true if error occurred

  // Access data/error
  snapshot.data; // The value (T?)
  snapshot.error; // The error if any
}
// #endregion async_snapshot_guide

// #region pattern1_simple_loading
class Pattern1SimpleLoading extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final snapshot = watchFuture(
      (DataService s) => s.fetchTodos(),
      initialValue: null,
    );

    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    return Text('Data loaded: ${snapshot.data?.length} items');
  }
}
// #endregion pattern1_simple_loading

// #region pattern2_error_handling
class Pattern2ErrorHandling extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final snapshot = watchStream(
      (MessageService s) => s.messageStream,
      initialValue: <Message>[],
    );

    if (snapshot.hasError) {
      return Column(
        children: [
          Text('Error: ${snapshot.error}'),
          ElevatedButton(
            onPressed: () {}, // Retry logic
            child: Text('Retry'),
          ),
        ],
      );
    }

    return ListView(children: snapshot.data!.map((m) => Text(m.text)).toList());
  }
}
// #endregion pattern2_error_handling

// #region pattern3_keep_old_data
class Pattern3KeepOldData extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final snapshot = watchStream(
      (MessageService s) => s.messageStream,
      initialValue: <Message>[],
    );

    return Column(
      children: [
        // Show subtle loading indicator
        if (snapshot.connectionState == ConnectionState.waiting)
          LinearProgressIndicator(),

        // Keep showing old data while loading new
        Expanded(
          child: ListView(
            children: snapshot.data!.map((item) => Text(item.text)).toList(),
          ),
        ),
      ],
    );
  }
}
// #endregion pattern3_keep_old_data

// #region nested_builders_before
Widget nestedBuildersBefore(Future initFuture, Stream dataStream) {
  return FutureBuilder(
    future: initFuture,
    builder: (context, futureSnapshot) {
      if (futureSnapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      return StreamBuilder(
        stream: dataStream,
        builder: (context, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return Text(streamSnapshot.data!);
        },
      );
    },
  );
}
// #endregion nested_builders_before

// #region nested_builders_after
class NestedBuildersAfter extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final initSnapshot = watchFuture(
      (AppService s) => s.initialize(),
      initialValue: false,
    );

    final dataSnapshot = watchStream(
      (ChatService s) => s.messageStream,
      initialValue: '',
    );

    if (initSnapshot.connectionState == ConnectionState.waiting ||
        dataSnapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    return Text(dataSnapshot.data!);
  }
}
// #endregion nested_builders_after

void main() {}
