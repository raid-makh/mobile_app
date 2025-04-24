import 'package:facebook_app_events/facebook_app_events.dart';

final facebookAppEvents = FacebookAppEvents();

void trackLoginEvent(String method) {
  facebookAppEvents.logEvent(
    name: "login",
    parameters: {
      'method': method, // Example: 'email', 'google', etc.
    },
  );
}
