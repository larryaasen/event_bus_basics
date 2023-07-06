import 'package:event_bus_basics/event_bus_basics.dart';
import 'package:logger/logger.dart';
import 'package:test/test.dart';

void main() {
  test('EventBus', () async {
    final logger = Logger(
      level: Level.debug,
      output: ConsoleOutput(),
      filter: ProductionFilter(),
      printer: PrefixPrinter(SimplePrinter(printTime: true, colors: false)),
    );
    final eventBus = EventBus(logger: logger);

    eventBus.events.listen((event) {
      print(event);
    });

    final eventLogger = EventBusLogger(eventBus, logger);
    expect(eventLogger.eb, equals(eventBus));

    expect(
        eventBus.events,
        emitsInOrder([
          EventBusEvent(
            group: EventBusGroup.trace,
            name: 'SignInScreen.build.start',
            params: {},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.trace,
            name: 'SignInScreen.build.end',
            params: {},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.app,
            name: 'app.coldstart',
            params: {},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.app,
            name: 'app.inactive',
            params: {},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.app,
            name: 'app.resume',
            params: {},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.app,
            name: 'app.version',
            params: {'version': '1.2.3'},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.app,
            name: 'app.dart.version',
            params: {'version': '3.0.0'},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.error,
            name: 'ApiClient.getVehicle.error',
            params: {'exception': 'e'},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.event,
            name: 'signed_in',
            params: {},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.network,
            name: 'pay',
            params: {'number': 1},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.tap,
            name: 'signin_button',
            params: {'screen': 'login'},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.trace,
            name: 'SignInScreen.build.started',
            params: {},
            from: '',
          ),
          EventBusEvent(
            group: EventBusGroup.trace,
            name: 'SignInScreen.build.started',
            params: {'name': 'foobar'},
            from: '',
          ),
        ]));

    eventBus.send(EventBusGroup.trace, name: 'SignInScreen.build.start');
    eventBus.send(EventBusGroup.trace, name: 'SignInScreen.build.end');

    eventBus.app(EventBusAppEvent.coldStart);
    eventBus.app(EventBusAppEvent.inactive);
    eventBus.app(EventBusAppEvent.resume);
    eventBus.app(EventBusAppEvent.version, params: {'version': '1.2.3'});
    eventBus.app(EventBusAppEvent.dartVersion, params: {'version': '3.0.0'});

    eventBus.error('ApiClient.getVehicle.error', params: {'exception': 'e'});

    eventBus.event('signed_in');

    eventBus.network('pay', params: {'number': 1});

    eventBus.tap('signin_button', screen: 'login');

    eventBus.trace('SignInScreen.build.started');
    eventBus.trace('SignInScreen.build.started', params: {'name': 'foobar'});
  }, timeout: Timeout(Duration(seconds: 2)));

  test('Valid event names', () async {
    expect(EventBusEvent.isValidEventName('login_button'), true);
    expect(EventBusEvent.isValidEventName('loginbutton'), true);
    expect(EventBusEvent.isValidEventName('a'), true);
    expect(EventBusEvent.isValidEventName('a_b_c'), true);
    expect(EventBusEvent.isValidEventName('00a_b_c00AAA'), true);
    expect(EventBusEvent.isValidEventName('login_button '), false);
    expect(EventBusEvent.isValidEventName('login_button!'), false);
    expect(EventBusEvent.isValidEventName('!login_button'), false);
    expect(EventBusEvent.isValidEventName('login_button:'), false);

    expect(EventBusEvent.isValidEventName('login_button'), true);

    expect(
        EventBusEvent(
          group: EventBusGroup.trace,
          name: 'SignInScreen.build.started',
          params: {'name': 'foobar'},
          from: '',
        ).isValidName,
        true);
  });

  test('test event group', () async {
    expect(EventBusGroupExt.allNames().length, 6);
    expect(EventBusGroupExt.allNames(toUpperCase: true).length, 6);

    expect(EventBusGroupExt.byName('app'), EventBusGroup.app);
    expect(EventBusGroupExt.byName('error'), EventBusGroup.error);
    expect(EventBusGroupExt.byName('event'), EventBusGroup.event);
    expect(EventBusGroupExt.byName('network'), EventBusGroup.network);
    expect(EventBusGroupExt.byName('tap'), EventBusGroup.tap);
    expect(EventBusGroupExt.byName('trace'), EventBusGroup.trace);
  });

  test('Valid EventBusEventCollector', () async {
    final eventBus = EventBus();
    final collector = EventBusEventCollector(eventBus);
    expect(collector.eventBus, equals(eventBus));
    expect(collector.events.length, 0);

    eventBus.tap('signin_button', screen: 'login');
    await Future.delayed(Duration.zero);
    expect(collector.events.length, 1);
  });
}
