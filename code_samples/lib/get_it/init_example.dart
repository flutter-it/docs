import 'dart:async';
import 'package:get_it/get_it.dart';

// #region example
class StreamingService implements ShadowChangeHandlers {
  StreamSubscription? _subscription;
  final Stream<dynamic> dataStream = Stream.empty();

  void init() {
    _subscription = dataStream.listen(_handleData);
  }

  void _handleData(dynamic data) {
    // Handle data
  }

  @override
  void onGetShadowed(Object shadowingObject) {
    // Another StreamingService is now active - pause our work
    _subscription?.pause();
    print('Paused: $shadowingObject is now handling streams');
  }

  @override
  void onLeaveShadow(Object shadowingObject) {
    // We're active again - resume work
    _subscription?.resume();
    print('Resumed: $shadowingObject was removed');
  }
}
// #endregion example
