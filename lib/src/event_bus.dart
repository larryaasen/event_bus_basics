// Copyright (c) 2023 Larry Aasen. All rights reserved.

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:stack_trace/stack_trace.dart';

/// Event Bus Group type.
enum EventBusGroup {
  /// App level events like app started, paused, resumed.
  app,

  /// Any error.
  error,

  /// An event.
  event,

  /// Requests and responses from the network.
  network,

  /// User tapped on something.
  tap,

  /// App activity tracing.
  trace,
}

extension EventBusGroupExt on EventBusGroup {
  static List<String> allNames({bool toUpperCase = true}) {
    return EventBusGroup.values.map((e) {
      return toUpperCase ? e.name.toUpperCase() : e.name;
    }).toList();
  }

  static EventBusGroup byName(String name) {
    switch (name.toLowerCase()) {
      case 'app':
        return EventBusGroup.app;
      case 'error':
        return EventBusGroup.error;
      case 'event':
        return EventBusGroup.event;
      case 'network':
        return EventBusGroup.network;
      case 'tap':
        return EventBusGroup.tap;
      case 'trace':
        return EventBusGroup.trace;
    }
    throw Exception('EventBusGroupExt.byName unknown name $name');
  }
}

/// App events.
enum EventBusAppEvent {
  coldStart,
  inactive,
  resume,

  /// App version
  version,

  /// Dart version
  dartVersion,
}

extension EventBusAppEventExt on EventBusAppEvent {
  /// Returns the text name for the app event.
  String get eventName => nameForEvent(this);

  /// Returns the text name for the app event.
  static String nameForEvent(EventBusAppEvent event) {
    switch (event) {
      case EventBusAppEvent.coldStart:
        return 'app.coldstart';
      case EventBusAppEvent.inactive:
        return 'app.inactive';
      case EventBusAppEvent.resume:
        return 'app.resume';
      case EventBusAppEvent.version:
        return 'app.version';
      case EventBusAppEvent.dartVersion:
        return 'app.dart.version';
    }
  }
}

/// A centralized event bus that tracks all events throughout the app to keep
/// them organized and provide easy access to all events. This makes it easy to
/// track an event in one place, and then utilize it by multiple consumers,
/// such as loggers, metrics, analytics, performance monitoring, etc.
/// The event only needs to be produced in one place, such as when a button is
/// tapped, and then future consumers of the event can utilze the event data
/// without having to change the code in the original event producer.
class EventBusEvent extends Equatable {
  /// Creates an [EventBusEvent].
  EventBusEvent({
    required this.group,
    required this.name,
    required this.params,
    required this.from,
  });

  final EventBusGroup group;
  final String name;
  final Map<String, Object?> params;
  final String from;

  DateTime get created => _created;
  final _created = DateTime.now();

  /// Is the name a valid event name?
  /// Valid event names are not required, but it is recommended to use.
  bool get isValidName => isValidEventName(name);

  /// Is the name a valid event name?
  /// Valid event names are not required, but it is recommended to use.
  static bool isValidEventName(String name) {
    return name.contains(RegExp(r'^[A-Za-z0-9_.]+$'));
  }

  @override
  String toString() {
    return 'group: ${group.name}, name: $name'
        '${params.isNotEmpty ? ', $params' : ''}';
  }

  @override
  List<Object?> get props => [group, name, params];
}

/// The event bus.
/// There should only be 1 instance of [EventBus] per app.
class EventBus {
  /// Creates an [EventBus] instance with an optional [logger].
  EventBus({this.logger});

  /// An optional [logger] that records exceptions encountered by [EventBus].
  final Logger? logger;

  /// Create a stream for the events.
  final _streamController = StreamController<EventBusEvent>.broadcast();

  /// Returns an events stream.
  Stream<EventBusEvent> get events => _streamController.stream;

  /// Send an event with [group] and event [name] and optional
  /// parameters [params], to the event bus.
  void send(EventBusGroup group,
      {required String name, Map<String, Object?>? params, String from = ''}) {
    assert(name.isNotEmpty);
    if (from.isEmpty) {
      from = _TraceFrame.caller;
    }
    final event = EventBusEvent(
      group: group,
      name: name,
      params: params ?? {},
      from: from,
    );

    try {
      _streamController.add(event);
    } catch (e) {
      Future.delayed(Duration(milliseconds: 1), () {
        logger?.e('EventBus.send.exception: $e');
      });
    }
  }

  /// Sends a [EventBusGroup.app] event.
  void app(EventBusAppEvent appEvent, {Map<String, Object?>? params}) {
    final name = appEvent.eventName;
    final from = _TraceFrame.caller;
    send(EventBusGroup.app, name: name, params: params, from: from);
  }

  /// Sends a [EventBusGroup.error] event.
  void error(String name, {Map<String, Object?>? params}) {
    final from = _TraceFrame.caller;
    send(EventBusGroup.error, name: name, params: params, from: from);
  }

  /// Sends a [EventBusGroup.event] event.
  void event(String name, {Map<String, Object?>? params}) {
    final from = _TraceFrame.caller;
    send(EventBusGroup.event, name: name, params: params, from: from);
  }

  /// Sends a [EventBusGroup.network] event.
  void network(String name, {Map<String, Object?>? params}) {
    final from = _TraceFrame.caller;
    send(EventBusGroup.network, name: name, params: params, from: from);
  }

  /// Sends a [EventBusGroup.tap] event.
  void tap(String name,
      {required String screen, Map<String, Object?>? params}) {
    final from = _TraceFrame.caller;
    params = params ?? {};
    params['screen'] = screen;
    send(EventBusGroup.tap, name: name, params: params, from: from);
  }

  /// Sends a [EventBusGroup.trace] event.
  void trace(String name, {Map<String, Object?>? params}) {
    final from = _TraceFrame.caller;
    send(EventBusGroup.trace, name: name, params: params, from: from);
  }
}

/// A private extension on the Stack Trace.
extension _TraceFrame on Trace {
  /// Get the caller name from the stack trace.
  static String get caller {
    final frames = Trace.current().frames;
    return frames.length > 2 && frames[2].member != null
        ? frames[2].member!
        : '';
  }
}
