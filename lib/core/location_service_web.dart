import 'dart:html' as html;

class AppLocation {
  const AppLocation(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

Future<AppLocation?> requestCurrentLocation() async {
  try {
    final position = await html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 12),
    );
    final latitude = position.coords?.latitude;
    final longitude = position.coords?.longitude;
    if (latitude == null || longitude == null) return null;
    return AppLocation(latitude.toDouble(), longitude.toDouble());
  } catch (_) {
    return null;
  }
}
