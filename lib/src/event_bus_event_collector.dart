// Copyright (c) 2023 Larry Aasen. All rights reserved.

import 'event_bus.dart';

/// An [EventBus] consumer that collects events and keeps them in memory for
/// displaying on a debug screen.
class EventBusEventCollector {
  EventBusEventCollector(this.eventBus) {
    eventBus.events.listen((event) {
      _handleEvent(event);
    });
  }

  final EventBus eventBus;

  List<EventBusEvent> get events => _events;

  final _events = <EventBusEvent>[];

  void _handleEvent(EventBusEvent event) async {
    _events.add(event);
  }
}
