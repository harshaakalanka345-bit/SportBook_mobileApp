import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

class AppLocation {
  const AppLocation(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

Future<AppLocation?> requestCurrentLocation() async {
  try {
    final result = Completer<AppLocation?>();
    web.window.navigator.geolocation.getCurrentPosition(
      ((web.GeolocationPosition position) {
        result.complete(AppLocation(position.coords.latitude, position.coords.longitude));
      }).toJS,
      ((web.GeolocationPositionError error) {
        result.complete(null);
      }).toJS,
      web.PositionOptions(enableHighAccuracy: true, timeout: 12000),
    );
    return await result.future.timeout(const Duration(seconds: 13), onTimeout: () => null);
  } catch (_) {
    return null;
  }
}
