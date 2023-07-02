// Copyright (c) 2023 Larry Aasen. All rights reserved.

import 'package:event_bus_basics/event_bus_basics.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  final eventBus = EventBus();

  final logger = Logger(
    level: Level.debug,
    output: ConsoleOutput(),
    filter: ProductionFilter(),
    printer: PrefixPrinter(SimplePrinter(printTime: true, colors: false)),
  );

  EventBusLogger(eventBus, logger);

  eventBus.app(EventBusAppEvent.coldStart);
  eventBus.tap('signin_button', screen: 'SignInScreen');
  eventBus.network('SignInBloc: start signing');
  eventBus.trace('SignInScreen.build: started', params: {'name': 'foobar'});
  eventBus.event('sign_in', params: {'username': 'foobar'});
  eventBus.error('SignInScreen._signIn: failed');
  eventBus.send(EventBusGroup.trace, name: 'SignInScreen._signIn: completed');

  await Future.delayed(Duration.zero);
}
