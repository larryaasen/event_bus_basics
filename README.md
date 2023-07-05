# Event Bus Basics

[![GitHub main workflow](https://github.com/larryaasen/event_bus_basics/actions/workflows/main.yml/badge.svg)](https://github.com/larryaasen/event_bus_basics/actions/workflows/main.yml)
[![codecov](https://codecov.io/gh/larryaasen/event_bus_basics/branch/main/graph/badge.svg)](https://app.codecov.io/gh/larryaasen/event_bus_basics)
[![pub package](https://img.shields.io/pub/v/event_bus_basics.svg)](https://pub.dartlang.org/packages/event_bus_basics)
[![GitHub Stars](https://img.shields.io/github/stars/larryaasen/event_bus_basics.svg)](https://github.com/larryaasen/event_bus_basics/stargazers)
<a href="https://www.buymeacoffee.com/larryaasen">
  <img alt="Buy me a coffee" src="https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg">
</a>

A Dart package for logging events once and writing them to multiple services.

## Overview

Most apps collect data on events that happen during the lifetime of the app. This
would include a user tapping a button, a failure at sign on, the completion
of a network request, an exception, and more.

When collecting these important events they are often sent to a metrics service
such as Firebase Analytics, Pendo, or New Relic, and then to the console, and maybe an
ad platform, and more.

It would not be a good idea to call multiple services for a single event.
That would make adding and updating events difficult.
```dart
onPressed: () {
    FirebaseAnalytics().logEvent('tapped_sign_in'); // Bad idea
    MyLogger.log('tapped sign in'); // Bad idea
    print('tapped sign in'); // Bad idea
}
```
It would also take a lot of work to change metrics providers or add an 
additional one throughout the app.

With `EventBus`, you can log one event in your code, and then create multiple
consumers that write the event to various services.

This is a similar but different kind of event bus from the
package [EventBus](https://pub.dev/packages/event_bus).

## Getting Started


There are specific types of events supported by `EventBus` that help organize
the events and make it easier for consumers to write them to services.

- app: when an app event occurs such as cold start, or resume from background.
- error: when an error occurs such as an exception.
- event: when a specific notable event occurs, such as the user completing sign
in, or the user completed a purchase.
- tap: when a user taps a button, a link, or any other tappable widget.
- network: when an HTTP request is made or completed.
- trace: any event to be logged that is not one of the above, such as normal
debug logging.

First, you need to instantiate the `EventBus` and hold a reference to it.
```
final eventBus = EventBus();
```

Now, you can log your events. For example, to log a tap on a button, use the
`tap` method on `EventBus`.
```
  eventBus.tap('signin_button', screen: 'SignInScreen');
```

You can also log any specific event with the `event` method on `EventBus`.
```
  eventBus.event('signin_completed');
```

All of the methods can take a additional parameters to enhance the logging.
These parameters are unlimited and take the form of a [Map].
```
  eventBus.event('signin_completed', params: {'username': username});
```

## Consumers

There will likely be multiple consumers needed, one to support each service.
These consumers will listen to the stream of events from the `EventBus`, and
decides which ones to send to their service.

Here is a simple consumer that just prints events to the console:

```
    eventBus.events.listen((event) {
      print(event);
    });
```

## Consumer: EventBusLogger

There is a consumer (`EventBusLogger`) included in this package that logs events to a [Logger].
It is very easy to use.

```
  final eventBus = EventBus();

  final logger = Logger(
    level: Level.debug,
    output: ConsoleOutput(),
    filter: ProductionFilter(),
    printer: PrefixPrinter(SimplePrinter(printTime: true, colors: false)),
  );

  EventBusLogger(eventBus, logger);
```

After `EventBusLogger` is setup, it will log every event to the logger with a format
that looks like this:
```
   INFO [I] TIME: 2023-07-02T18:29:34.613347 @ app.coldstart
   INFO [I] TIME: 2023-07-02T18:29:34.621539 @ tap=>signin_button - {screen: SignInScreen}
  DEBUG [D] TIME: 2023-07-02T18:29:34.621638 @ ⚡︎ SignInBloc: start signing
  DEBUG [D] TIME: 2023-07-02T18:29:34.621705 @ SignInScreen.build: started - {name: foobar}
   INFO [I] TIME: 2023-07-02T18:29:34.621751 @ sign_in - {username: foobar}
  ERROR [E] TIME: 2023-07-02T18:29:34.621784 @ SignInScreen._signIn: failed
  DEBUG [D] TIME: 2023-07-02T18:29:34.621828 @ SignInScreen._signIn: completed
```

If you like using `EventBusLogger` but would rather have a different output
format, just copy the code inside `EventBusLogger` to a new class, customize it
to your needs, and use that class instead.

## Consumer: EventBusEventCollector
There is also an included consumer ('EventBusEventCollector) that collects
events and keeps them in memory for things like displaying them on a
debug screen.


## Consumer: EventBusFirebaseAnayltics

Here is a convenient example of a consumer written for Firebase Analytics. It logs all
events to FB but changes the names of the error and tap events.

```
class EventBusFirebaseAnayltics {
  EventBusFirebaseAnayltics(this.eventBus) {
    eventBus.events.listen((event) {
      _handleEvent(event);
    });
  }

  final EventBus eventBus;

  Future<void> _handleEvent(EventBusEvent event) async {
    if (event.group == EventBusGroup.error) {
      final name = event.isValidName ? 'error_${event.name}' : 'error_detected';
      FirebaseAnalytics.instance.logEvent(name: name, parameters: event.params);
    } else if (event.group == EventBusGroup.tap) {
      final name = 'tap_${event.name}';
      FirebaseAnalytics.instance.logEvent(name: name, parameters: event.params);
    } else {
      FirebaseAnalytics.instance
          .logEvent(name: event.name, parameters: event.params);
    }
  }
}
```
Note: This class is not included in this package to avoid requiring 
FirebaseAnalytics as a dependency. Feel free to copy this class to your app
for your own use.

## Contributing
All [comments](https://github.com/larryaasen/event_bus_basics/issues) and [pull requests](https://github.com/larryaasen/event_bus_basics/pulls) are welcome.

## Donations / Sponsor

Please sponsor or donate to the creator of `event_bus_basics` on [Flattr](https://flattr.com/@larryaasen) or [Patreon](https://www.patreon.com/larryaasen).
