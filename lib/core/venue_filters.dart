/// Search filters applied to the venue list.
class VenueFilters {
  const VenueFilters({
    this.sport,
    this.environment,
    this.area,
    this.minRate = 0,
    this.maxRate = rateCeiling,
    this.amenities = const {},
    this.surfaceTypes = const {},
    this.date,
    this.timeWindow,
    this.availableVenueIds = const {},
  });

  static const double rateCeiling = 5000;
  static const Object _keep = Object();

  final String? sport; // null = any
  final String? environment; // 'Indoor' | 'Outdoor' | null = any
  final String? area; // null = any
  final double minRate;
  final double maxRate;
  final Set<String> amenities;
  final Set<String> surfaceTypes;
  final DateTime? date;
  final String? timeWindow;

  /// Venue IDs with at least one court free in the selected time window.
  final Set<String> availableVenueIds;

  bool get isEmpty =>
      sport == null &&
      environment == null &&
      area == null &&
      minRate <= 0 &&
      maxRate >= rateCeiling &&
      amenities.isEmpty &&
      surfaceTypes.isEmpty &&
      date == null &&
      timeWindow == null;

  int get activeCount =>
      [
        sport,
        environment,
        area,
        date,
        timeWindow,
      ].where((e) => e != null).length +
      (minRate > 0 || maxRate < rateCeiling ? 1 : 0) +
      amenities.length +
      surfaceTypes.length;

  VenueFilters copyWith({
    Object? sport = _keep,
    Object? environment = _keep,
    Object? area = _keep,
    double? minRate,
    double? maxRate,
    Set<String>? amenities,
    Set<String>? surfaceTypes,
    Object? date = _keep,
    Object? timeWindow = _keep,
    Set<String>? availableVenueIds,
  }) => VenueFilters(
    sport: identical(sport, _keep) ? this.sport : sport as String?,
    environment: identical(environment, _keep)
        ? this.environment
        : environment as String?,
    area: identical(area, _keep) ? this.area : area as String?,
    minRate: minRate ?? this.minRate,
    maxRate: maxRate ?? this.maxRate,
    amenities: amenities ?? this.amenities,
    surfaceTypes: surfaceTypes ?? this.surfaceTypes,
    date: identical(date, _keep) ? this.date : date as DateTime?,
    timeWindow: identical(timeWindow, _keep)
        ? this.timeWindow
        : timeWindow as String?,
    availableVenueIds: availableVenueIds ?? this.availableVenueIds,
  );

  bool matches(Map<String, dynamic> venue, String query) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final hay =
          '${venue['name']} ${venue['area']} ${venue['address']} ${venue['sport']}'
              .toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (sport != null && venue['sport'] != sport) return false;
    if (environment != null && venue['environment'] != environment) {
      return false;
    }
    if (area != null && venue['area'] != area) return false;
    final rate = (venue['hourly_rate'] as num?)?.toDouble() ?? 0;
    if (rate < minRate) return false;
    if (maxRate < rateCeiling && rate > maxRate) return false;
    if (amenities.isNotEmpty) {
      final have = ((venue['amenities'] as List?) ?? const [])
          .map((e) => '$e')
          .toSet();
      if (!amenities.every(have.contains)) return false;
    }
    if (surfaceTypes.isNotEmpty) {
      final courts = (venue['courts'] as List?) ?? const [];
      final surfaces = courts
          .whereType<Map>()
          .map((court) => '${court['type'] ?? ''}')
          .toSet();
      if (!surfaceTypes.any(surfaces.contains)) return false;
    }
    if (date != null && !availableVenueIds.contains('${venue['id']}')) {
      return false;
    }
    return true;
  }
}
