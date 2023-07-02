import 'package:event_bus_basics/event_bus_basics.dart';

Future<void> main() async {
  final eventBus = EventBus();

  eventBus.events.listen((event) {
    print('event: $event');
  });

  eventBus.app(EventBusAppEvent.coldStart);
  eventBus.tap('signin_button', screen: 'SignInScreen');
  eventBus.network('SignInBloc: start signing');
  eventBus.trace('SignInScreen.build: started', params: {'name': 'foobar'});
  eventBus.event('sign_in', params: {'username': 'foobar'});
  eventBus.error('SignInScreen._signIn: failed');
  eventBus.send(EventBusGroup.trace, name: 'SignInScreen._signIn: completed');
}
