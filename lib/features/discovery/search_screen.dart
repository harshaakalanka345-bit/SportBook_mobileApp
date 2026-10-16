import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import '../../core/venue_filters.dart';
import '../../core/venue_image.dart';
import '../auth/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import 'filter_screen.dart';
import 'venue_detail_screen.dart';

/// Search tab: free-text search plus filters over the live venue list.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const canvas = Color(0xFFF6F8FD);

  final _service = SupabaseService();
  final _query = TextEditingController();
  List<Map<String, dynamic>> _venues = [];
  VenueFilters _filters = const VenueFilters();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final venues = await _service.getVenues(includeCourts: true);
      if (mounted) setState(() => _venues = venues);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _results =>
      _venues.where((venue) => _filters.matches(venue, _query.text)).toList();

  List<String> get _sports =>
      _venues
          .map((venue) => '${venue['sport'] ?? ''}'.trim())
          .where((sport) => sport.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  Future<void> _openFilters() async {
    final result = await Navigator.push<VenueFilters>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          venues: _venues,
          initial: _filters,
          initialQuery: _query.text,
        ),
      ),
    );
    if (result != null && mounted) setState(() => _filters = result);
  }

  Future<void> _notifyMe() async {
    final sport = _filters.sport ?? 'Any sport';
    final area = _filters.area ?? 'Any area';
    try {
      await _service.addSlotAlert(sport: sport, area: area);
      toast(
        'Alert saved: $sport in $area. (Notifications are not delivered yet.)',
      );
    } catch (e) {
      toast('Could not create the alert: $e');
    }
  }

  List<(String, VoidCallback)> get _chips => [
    if (_filters.sport != null)
      (
        _filters.sport!,
        () => setState(() => _filters = _filters.copyWith(sport: null)),
      ),
    if (_filters.environment != null)
      (
        _filters.environment!,
        () => setState(() => _filters = _filters.copyWith(environment: null)),
      ),
    if (_filters.area != null)
      (
        _filters.area!,
        () => setState(() => _filters = _filters.copyWith(area: null)),
      ),
    if (_filters.date != null)
      (
        '${_filters.date!.day}/${_filters.date!.month}/${_filters.date!.year}',
        () => setState(
          () => _filters = _filters.copyWith(
            date: null,
            timeWindow: null,
            availableVenueIds: {},
          ),
        ),
      ),
    if (_filters.timeWindow != null)
      (
        _filters.timeWindow!,
        () => setState(
          () => _filters = _filters.copyWith(
            date: null,
            timeWindow: null,
            availableVenueIds: {},
          ),
        ),
      ),
    for (final surface in _filters.surfaceTypes)
      (
        surface,
        () => setState(
          () => _filters = _filters.copyWith(
            surfaceTypes: {..._filters.surfaceTypes}..remove(surface),
          ),
        ),
      ),
    if (_filters.minRate > 0 || _filters.maxRate < VenueFilters.rateCeiling)
      (
        'LKR ${_filters.minRate.round()}-${_filters.maxRate >= VenueFilters.rateCeiling ? '${VenueFilters.rateCeiling.round()}+' : _filters.maxRate.round()}',
        () => setState(
          () => _filters = _filters.copyWith(
            minRate: 0,
            maxRate: VenueFilters.rateCeiling,
          ),
        ),
      ),
    for (final amenity in _filters.amenities)
      (
        amenity,
        () => setState(
          () => _filters = _filters.copyWith(
            amenities: {..._filters.amenities}..remove(amenity),
          ),
        ),
      ),
  ];

  void _setSport(String? sport) {
    setState(
      () => _filters = _filters.copyWith(
        sport: _filters.sport == sport ? null : sport,
      ),
    );
  }

  void _setEnvironment(String? environment) {
    setState(
      () => _filters = _filters.copyWith(
        environment: _filters.environment == environment ? null : environment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Search',
              style: TextStyle(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                tooltip: 'Filters',
                icon: const Icon(Icons.tune_rounded, color: ink),
                onPressed: _venues.isEmpty ? null : _openFilters,
              ),
              if (_filters.activeCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_filters.activeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded, color: ink),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 20, left: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, viewport) {
          final wide = viewport.maxWidth >= 820;
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _intro(),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _searchField()),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 56,
                              child: FilledButton.icon(
                                onPressed: _venues.isEmpty
                                    ? null
                                    : _openFilters,
                                icon: const Icon(Icons.tune_rounded, size: 19),
                                label: Text(
                                  _filters.activeCount == 0
                                      ? 'Filters'
                                      : 'Filters (${_filters.activeCount})',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: ink,
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: Color(0xFFE1E6F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_sports.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _quickFilters(),
                        ],
                        if (_chips.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              for (final chip in _chips)
                                InputChip(
                                  label: Text(
                                    chip.$1,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onDeleted: chip.$2,
                                  backgroundColor: const Color(0xFFE8EEFF),
                                  side: BorderSide.none,
                                  deleteIconColor: AppColors.primary,
                                ),
                              ActionChip(
                                label: const Text('Clear all'),
                                onPressed: () => setState(
                                  () => _filters = const VenueFilters(),
                                ),
                                backgroundColor: Colors.transparent,
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.only(top: 72),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_error != null)
                          _message(
                            Icons.cloud_off_rounded,
                            'Could not load courts',
                            _error!,
                            [
                              FilledButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          )
                        else if (results.isEmpty)
                          _message(
                            Icons.search_off_rounded,
                            _venues.isEmpty
                                ? 'Courts are on their way'
                                : 'No courts match just yet',
                            _venues.isEmpty
                                ? 'New places to play will show up here. Pull down to check again.'
                                : 'Try a different search or loosen your filters to see more courts.',
                            [
                              if (!_filters.isEmpty || _query.text.isNotEmpty)
                                OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    _filters = const VenueFilters();
                                    _query.clear();
                                  }),
                                  icon: const Icon(
                                    Icons.restart_alt_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Reset search'),
                                ),
                              if (_venues.isEmpty)
                                OutlinedButton.icon(
                                  onPressed: _notifyMe,
                                  icon: const Icon(
                                    Icons.notifications_active_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Notify me'),
                                ),
                            ],
                          )
                        else ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Text(
                                  '${results.length} ${results.length == 1 ? 'court' : 'courts'} to explore',
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.touch_app_outlined,
                                  size: 16,
                                  color: muted,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Tap a court for details',
                                  style: TextStyle(color: muted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (wide)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: results.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.52,
                                  ),
                              itemBuilder: (context, index) =>
                                  _venueCard(results[index]),
                            )
                          else
                            ...results.map(_venueCard),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _intro() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1268F3), Color(0xFF5B8CFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x251268F3),
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FIND YOUR COURT',
                style: TextStyle(
                  color: Color(0xFFDDE8FF),
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready when you are.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Explore places to play and book your next game.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .88),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.sports_tennis_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
      ],
    ),
  );

  Widget _searchField() => TextField(
    controller: _query,
    onChanged: (_) => setState(() {}),
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Search by court, sport or area',
      hintStyle: const TextStyle(color: Color(0xFF8992A6), fontSize: 14),
      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
      suffixIcon: _query.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(_query.clear),
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE1E6F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );

  Widget _quickFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _quickChip(
          'All sports',
          _filters.sport == null,
          () => _setSport(null),
          icon: Icons.grid_view_rounded,
        ),
        for (final sport in _sports)
          _quickChip(sport, _filters.sport == sport, () => _setSport(sport)),
        if (_venues.any(
          (venue) => '${venue['environment']}'.toLowerCase() == 'indoor',
        ))
          _quickChip(
            'Indoor',
            _filters.environment == 'Indoor',
            () => _setEnvironment('Indoor'),
            icon: Icons.roofing_rounded,
          ),
        if (_venues.any(
          (venue) => '${venue['environment']}'.toLowerCase() == 'outdoor',
        ))
          _quickChip(
            'Outdoor',
            _filters.environment == 'Outdoor',
            () => _setEnvironment('Outdoor'),
            icon: Icons.wb_sunny_outlined,
          ),
      ],
    ),
  );

  Widget _quickChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    IconData? icon,
  }) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      avatar: icon == null
          ? null
          : Icon(icon, size: 15, color: selected ? Colors.white : muted),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : ink,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: selected ? AppColors.primary : const Color(0xFFE1E6F0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      showCheckmark: false,
    ),
  );

  Widget _message(
    IconData icon,
    String title,
    String body,
    List<Widget> actions,
  ) => Container(
    margin: const EdgeInsets.only(top: 18),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF0FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ],
      ],
    ),
  );

  Widget _venueCard(Map<String, dynamic> venue) {
    final amenities = ((venue['amenities'] as List?) ?? const [])
        .take(2)
        .toList();
    final rate = venue['hourly_rate'];
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VenueDetailScreen(venue: venue)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8ECF4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D001844),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 282,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VenueImage(venue: venue),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x22000000), Colors.transparent],
                            stops: [0, .55],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .94),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${venue['environment'] ?? 'Court'}',
                            style: const TextStyle(
                              color: ink,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${venue['name'] ?? 'Court'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              rate is num
                                  ? 'LKR ${rate.toStringAsFixed(0)}'
                                  : 'Price on request',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: muted,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${venue['area'] ?? 'Location not listed'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Text(
                              '/ hour',
                              style: TextStyle(color: muted, fontSize: 10),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _detailTag('${venue['sport'] ?? 'Sport'}'),
                            for (final amenity in amenities)
                              _detailTag('$amenity', subtle: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailTag(String label, {bool subtle = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: subtle ? const Color(0xFFF3F5FA) : const Color(0xFFEAF0FF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: subtle ? muted : AppColors.primary,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
