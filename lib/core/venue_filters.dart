/// Search filters applied to the venue list.
class VenueFilters {
  const VenueFilters({
    this.sport,
    this.environment,
    this.area,
    this.minRate = 0,
    this.maxRate = rateCeiling,
    this.amenities = const {},
  });

  static const double rateCeiling = 5000;
  static const Object _keep = Object();

  final String? sport; // null = any
  final String? environment; // 'Indoor' | 'Outdoor' | null = any
  final String? area; // null = any
  final double minRate;
  final double maxRate;
  final Set<String> amenities;

  bool get isEmpty => sport == null && environment == null && area == null && minRate <= 0 && maxRate >= rateCeiling && amenities.isEmpty;

  int get activeCount => [sport, environment, area].where((e) => e != null).length + (minRate > 0 || maxRate < rateCeiling ? 1 : 0) + amenities.length;

  VenueFilters copyWith({
    Object? sport = _keep,
    Object? environment = _keep,
    Object? area = _keep,
    double? minRate,
    double? maxRate,
    Set<String>? amenities,
  }) =>
      VenueFilters(
        sport: identical(sport, _keep) ? this.sport : sport as String?,
        environment: identical(environment, _keep) ? this.environment : environment as String?,
        area: identical(area, _keep) ? this.area : area as String?,
        minRate: minRate ?? this.minRate,
        maxRate: maxRate ?? this.maxRate,
        amenities: amenities ?? this.amenities,
      );

  bool matches(Map<String, dynamic> venue, String query) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final hay = '${venue['name']} ${venue['area']} ${venue['address']} ${venue['sport']}'.toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (sport != null && venue['sport'] != sport) return false;
    if (environment != null && venue['environment'] != environment) return false;
    if (area != null && venue['area'] != area) return false;
    final rate = (venue['hourly_rate'] as num?)?.toDouble() ?? 0;
    if (rate < minRate) return false;
    if (maxRate < rateCeiling && rate > maxRate) return false;
    if (amenities.isNotEmpty) {
      final have = ((venue['amenities'] as List?) ?? const []).map((e) => '$e').toSet();
      if (!amenities.every(have.contains)) return false;
    }
    return true;
  }
}
