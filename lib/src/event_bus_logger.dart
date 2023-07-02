// Copyright (c) 2023 Larry Aasen. All rights reserved.

import 'package:logger/logger.dart';

import 'event_bus.dart';

/// An [EventBus] consumer that logs all events to [logger].
class EventBusLogger {
  EventBusLogger(this.eb, Logger logger) {
    eb.events.listen((event) {
      var prefix = '';
      var level = Level.info;
      if (event.group == EventBusGroup.error) {
        level = Level.error;
      } else if (event.group == EventBusGroup.tap) {
        prefix = 'tap=>';
      } else if (event.group == EventBusGroup.network) {
        level = Level.debug;
        prefix = '⚡︎ ';
      } else if (event.group == EventBusGroup.trace) {
        level = Level.debug;
      }
      final params = event.params.isEmpty ? '' : ' - ${event.params}';
      logger.log(level, '@ $prefix${event.name}$params');
    });
  }

  final EventBus eb;
}
