// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'dart:async';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
class Event {}

class ServiceAEvent extends Event {}

class ServiceBEvent extends Event {}

class EventBus {
  final _controller = StreamController<Event>.broadcast();
  Stream<Event> get events => _controller.stream;
  void emit(Event event) => _controller.add(event);
}

class ServiceA {
  ServiceA(EventBus bus) {
    bus.events.where((e) => e is ServiceBEvent).listen(_handle);
  }
  void _handle(Event event) {}
}

class ServiceB {
  ServiceB(EventBus bus) {
    bus.events.where((e) => e is ServiceAEvent).listen(_handle);
  }
  void _handle(Event event) {}
}
// #endregion example
