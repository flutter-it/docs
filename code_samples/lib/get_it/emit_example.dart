import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
class EventBus {
  final _controller = StreamController<Event>.broadcast();
  Stream<Event> get events => _controller.stream;
  void emit(Event event) => _controller.add(event);
}

class ServiceA {
  ServiceA(EventBus bus) {
    bus.events.where((e) => e is ServiceBEvent).listen(_handle);
  }
}

class ServiceB {
  ServiceB(EventBus bus) {
    bus.events.where((e) => e is ServiceAEvent).listen(_handle);
  }
}
// #endregion example
