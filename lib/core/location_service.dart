import 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart';

export 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart';

class LocationSelection {
  const LocationSelection({required this.label, this.location, this.searchText});

  final String label;
  final AppLocation? location;
  final String? searchText;
}
