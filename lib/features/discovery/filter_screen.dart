import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/venue_filters.dart';

/// Filter picker for venue search. Pops with the chosen [VenueFilters].
class FilterScreen extends StatefulWidget {
  const FilterScreen({
    super.key,
    required this.venues,
    required this.initial,
    this.initialQuery = '',
  });

  /// Used to offer only areas and amenities that exist in the venue list.
  final List<Map<String, dynamic>> venues;
  final VenueFilters initial;
  final String initialQuery;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const _ink = Color(0xFF17213A);
  static const _muted = Color(0xFF778099);
  static const _blue = AppColors.primary;
  static const _canvas = Color(0xFFF7F8FE);

  late VenueFilters _f;
  final _service = SupabaseService();
  late DateTime _selectedDate;
  late String _selectedTimeWindow;
  bool _loadingAvailability = false;
  String? _availabilityError;
  int _availabilityGeneration = 0;

  @override
  void initState() {
    super.initState();
    _f = widget.initial;
    _selectedDate = _dateOnly(widget.initial.date ?? DateTime.now());
    _selectedTimeWindow = widget.initial.timeWindow ?? 'Any time';
    if (widget.initial.date != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyAvailability(
            date: widget.initial.date,
            window: _selectedTimeWindow,
          );
        }
      });
    }
  }

  List<String> _distinct(String key) =>
      widget.venues
          .map((venue) => venue[key])
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<String> get _amenityOptions {
    final options = <String>{};
    for (final venue in widget.venues) {
      for (final amenity in (venue['amenities'] as List?) ?? const []) {
        options.add('$amenity');
      }
    }
    return options.toList()..sort();
  }

  List<String> get _surfaceOptions {
    final options = <String>{};
    for (final venue in widget.venues) {
      for (final court in (venue['courts'] as List?) ?? const []) {
        if (court is Map &&
            court['is_active'] != false &&
            '${court['type'] ?? ''}'.trim().isNotEmpty) {
          options.add('${court['type']}');
        }
      }
    }
    return options.toList()..sort();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _dayName(DateTime date) {
    if (_sameDay(date, _dateOnly(DateTime.now()))) return 'Today';
    if (_sameDay(
      date,
      _dateOnly(DateTime.now().add(const Duration(days: 1))),
    )) {
      return 'Tomorrow';
    }
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get _matchCount =>
      widget.venues.where((venue) => _f.matches(venue, '')).length;

  void _reset() => setState(() {
    _availabilityGeneration++;
    _loadingAvailability = false;
    _f = const VenueFilters();
    _selectedDate = _dateOnly(DateTime.now());
    _selectedTimeWindow = 'Any time';
    _availabilityError = null;
  });

  Future<void> _applyAvailability({DateTime? date, String? window}) async {
    final selectedDate = _dateOnly(date ?? _selectedDate);
    final selectedWindow = window ?? _selectedTimeWindow;
    final activeWindow = selectedWindow == 'Any time' ? null : selectedWindow;
    final generation = ++_availabilityGeneration;
    setState(() {
      _selectedDate = selectedDate;
      _selectedTimeWindow = selectedWindow;
      _availabilityError = null;
      _loadingAvailability = true;
      _f = _f.copyWith(
        date: selectedDate,
        timeWindow: activeWindow,
        availableVenueIds: {},
      );
    });
    try {
      final results = await Future.wait(
        widget.venues.map((venue) async {
          final venueId = '${venue['id'] ?? ''}';
          if (venueId.isEmpty) return null;
          final courts = ((venue['courts'] as List?) ?? const [])
              .whereType<Map>()
              .where((court) => court['is_active'] != false)
              .toList();
          if (courts.isEmpty) return null;
          final bookedRows = await _service.getBookedSlots(
            venueId,
            isoDate(selectedDate),
          );
          final booked = <String>{};
          for (final row in bookedRows) {
            for (final label in '${row['time_slot'] ?? ''}'.split(', ')) {
              booked.add('${row['court_name']}|$label');
            }
          }
          final now = DateTime.now();
          for (final court in courts) {
            final courtName = '${court['name'] ?? ''}';
            if (courtName.isEmpty) continue;
            for (final slot in kSlots) {
              if (!slotWithinVenueHours(slot, venue)) continue;
              if (!_slotMatchesWindow(slot.startHour, selectedWindow)) continue;
              if (_sameDay(selectedDate, _dateOnly(now)) &&
                  !slot.startOn(selectedDate).isAfter(now)) {
                continue;
              }
              if (!booked.contains('$courtName|${slot.label}')) return venueId;
            }
          }
          return null;
        }),
      );
      if (!mounted || generation != _availabilityGeneration) return;
      setState(
        () => _f = _f.copyWith(
          availableVenueIds: results.whereType<String>().toSet(),
        ),
      );
    } catch (_) {
      if (!mounted || generation != _availabilityGeneration) return;
      setState(
        () => _availabilityError =
            'Could not check live availability. Try again.',
      );
    } finally {
      if (mounted && generation == _availabilityGeneration) {
        setState(() => _loadingAvailability = false);
      }
    }
  }

  bool _slotMatchesWindow(int hour, String window) => switch (window) {
    'Morning (6 AM – 12 PM)' => hour >= 6 && hour < 12,
    'Afternoon (12 PM – 5 PM)' => hour >= 12 && hour < 17,
    'Evening / Floodlit (5 PM – 10 PM)' => hour >= 17 && hour <= 21,
    _ => true,
  };

  Widget _panel({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
    String? subtitle,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9ECF5)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080A1E52),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: _blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap, {
    IconData? icon,
  }) => ChoiceChip(
    avatar: icon == null
        ? null
        : Icon(icon, size: 15, color: selected ? Colors.white : _muted),
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    selectedColor: _blue,
    backgroundColor: const Color(0xFFF2F4FC),
    side: BorderSide(color: selected ? _blue : Colors.transparent),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    labelStyle: TextStyle(
      color: selected ? Colors.white : _ink,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    onSelected: (_) => onTap(),
  );

  Widget _environmentCard(String label, String note, IconData icon) {
    final selected = _f.environment == label;
    return Expanded(
      child: Material(
        color: selected ? _blue : const Color(0xFFF2F4FC),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(
            () => _f = _f.copyWith(environment: selected ? null : label),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected ? Colors.white : _blue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : _ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  note,
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: .8)
                        : _muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _rateLabel =>
      'LKR ${_formatRate(_f.minRate)} – ${_f.maxRate >= VenueFilters.rateCeiling ? '${_formatRate(VenueFilters.rateCeiling)}+' : _formatRate(_f.maxRate)}';

  String _formatRate(double value) => value.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );

  @override
  Widget build(BuildContext context) {
    final sports = _distinct('sport');
    final areas = _distinct('area');
    final amenities = _amenityOptions;
    final surfaceOptions = _surfaceOptions;
    final searchSummary = widget.initialQuery.trim();
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to search',
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(width: 9),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPORTSBOOK',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                Text(
                  'Find your court',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(color: _blue, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _searchSummary(searchSummary),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 14),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: _blue),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              _f.area?.toUpperCase() ?? 'ALL AREAS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                          Text(
                            '${_f.activeCount} FILTER${_f.activeCount == 1 ? '' : 'S'} APPLIED',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _panel(
                      title: 'Date & time',
                      icon: Icons.calendar_month_outlined,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF2FF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'LIVE AVAILABILITY',
                          style: TextStyle(
                            color: _blue,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var offset = 0; offset < 7; offset++)
                                  _dateCard(
                                    _dateOnly(
                                      DateTime.now().add(
                                        Duration(days: offset),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'PREFERRED TIME WINDOW',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 7,
                            runSpacing: 2,
                            children: [
                              for (final window in const [
                                'Any time',
                                'Morning (6 AM – 12 PM)',
                                'Afternoon (12 PM – 5 PM)',
                                'Evening / Floodlit (5 PM – 10 PM)',
                              ])
                                _chip(
                                  window,
                                  _selectedTimeWindow == window,
                                  () => _applyAvailability(window: window),
                                ),
                            ],
                          ),
                          if (_loadingAvailability) ...[
                            const SizedBox(height: 10),
                            const LinearProgressIndicator(minHeight: 2),
                            const SizedBox(height: 5),
                            const Text(
                              'Checking open courts for this date…',
                              style: TextStyle(color: _muted, fontSize: 10),
                            ),
                          ],
                          if (_availabilityError != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _availabilityError!,
                                    style: const TextStyle(
                                      color: Color(0xFFB54747),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _applyAvailability(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    _panel(
                      title: 'Sport category',
                      icon: Icons.sports_tennis_rounded,
                      trailing: const Text(
                        'CHOOSE ONE',
                        style: TextStyle(
                          color: _blue,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Wrap(
                        spacing: 7,
                        runSpacing: 2,
                        children: [
                          _chip(
                            'Any sport',
                            _f.sport == null,
                            () => setState(() => _f = _f.copyWith(sport: null)),
                            icon: Icons.grid_view_rounded,
                          ),
                          for (final sport in sports)
                            _chip(
                              sport,
                              _f.sport == sport,
                              () => setState(
                                () => _f = _f.copyWith(sport: sport),
                              ),
                              icon: _sportIcon(sport),
                            ),
                        ],
                      ),
                    ),
                    if (areas.isNotEmpty)
                      _panel(
                        title: 'Area',
                        icon: Icons.location_on_outlined,
                        trailing: Text(
                          _f.area ?? 'ANY AREA',
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 2,
                          children: [
                            _chip(
                              'Anywhere',
                              _f.area == null,
                              () =>
                                  setState(() => _f = _f.copyWith(area: null)),
                              icon: Icons.public_rounded,
                            ),
                            for (final area in areas)
                              _chip(
                                area,
                                _f.area == area,
                                () => setState(
                                  () => _f = _f.copyWith(area: area),
                                ),
                                icon: Icons.place_outlined,
                              ),
                          ],
                        ),
                      ),
                    _panel(
                      title: 'Court environment',
                      icon: Icons.roofing_rounded,
                      child: Row(
                        children: [
                          _environmentCard(
                            'Indoor',
                            'Covered play',
                            Icons.roofing_rounded,
                          ),
                          const SizedBox(width: 9),
                          _environmentCard(
                            'Outdoor',
                            'Open air',
                            Icons.wb_sunny_outlined,
                          ),
                        ],
                      ),
                    ),
                    _panel(
                      title: 'Hourly rate',
                      icon: Icons.payments_outlined,
                      trailing: RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _rateLabel,
                              style: const TextStyle(
                                color: _blue,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const TextSpan(
                              text: ' / hr',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          _rateHistogram(),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 8,
                              activeTrackColor: _blue,
                              inactiveTrackColor: const Color(0xFFDCE4FF),
                              rangeThumbShape: const RoundRangeSliderThumbShape(
                                enabledThumbRadius: 9,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                            ),
                            child: RangeSlider(
                              values: RangeValues(_f.minRate, _f.maxRate),
                              min: 0,
                              max: VenueFilters.rateCeiling,
                              divisions: 20,
                              activeColor: _blue,
                              onChanged: (range) => setState(
                                () => _f = _f.copyWith(
                                  minRate: range.start,
                                  maxRate: range.end,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'LKR 0',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'LKR 3,000',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'LKR 5,000+',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 7,
                            runSpacing: 6,
                            children: [
                              _ratePreset('Under LKR 2,000', 0, 2000),
                              _ratePreset('LKR 2,000–3,500', 2000, 3500),
                              _ratePreset(
                                'Premium LKR 3,500+',
                                3500,
                                VenueFilters.rateCeiling,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (surfaceOptions.isNotEmpty)
                      _panel(
                        title: 'Surface type',
                        icon: Icons.layers_outlined,
                        trailing: Text(
                          '${_f.surfaceTypes.length} SELECTED',
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: 'Choose surfaces available at the courts',
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 2,
                          children: [
                            for (final surface in surfaceOptions)
                              _chip(
                                surface,
                                _f.surfaceTypes.contains(surface),
                                () {
                                  final next = {..._f.surfaceTypes};
                                  if (!next.add(surface)) {
                                    next.remove(surface);
                                  }
                                  setState(
                                    () => _f = _f.copyWith(surfaceTypes: next),
                                  );
                                },
                                icon: Icons.layers_outlined,
                              ),
                          ],
                        ),
                      ),
                    if (amenities.isNotEmpty)
                      _panel(
                        title: 'Facilities & amenities',
                        icon: Icons.tune_rounded,
                        trailing: Text(
                          '${_f.amenities.length} ACTIVE',
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: 'Choose every facility you want at the venue',
                        child: Column(
                          children: [
                            for (final amenity in amenities)
                              _amenityRow(amenity),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x140A1E52),
                blurRadius: 14,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 9, color: _blue),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _loadingAvailability
                              ? 'Checking availability…'
                              : '$_matchCount ${_matchCount == 1 ? 'court' : 'courts'}',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _availabilityError == null
                              ? 'Matching your filters'
                              : 'Availability check failed',
                          style: TextStyle(color: _muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed:
                        _loadingAvailability || _availabilityError != null
                        ? null
                        : () => Navigator.pop(context, _f),
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      'Show results',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchSummary(String query) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080A1E52),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.search_rounded, color: _muted, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            query.isEmpty ? 'All courts and sports' : query,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(Icons.tune_rounded, color: _blue, size: 18),
      ],
    ),
  );

  Widget _dateCard(DateTime date) {
    // The preview defaults to today, but it is not an active search filter
    // until the player taps a date (or a time window). Only style a date as
    // selected when it is actually applied to the result set.
    final selected = _f.date != null && _sameDay(_f.date!, date);
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Material(
        color: selected ? _blue : const Color(0xFFF2F4FC),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _applyAvailability(date: date),
          child: SizedBox(
            width: 62,
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _dayName(date).toUpperCase(),
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: .85)
                        : _muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: selected ? Colors.white : _ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  const [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ][date.month - 1],
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: .85)
                        : _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rateHistogram() {
    const heights = [
      18.0,
      28.0,
      42.0,
      48.0,
      38.0,
      48.0,
      32.0,
      28.0,
      22.0,
      18.0,
      12.0,
      12.0,
    ];
    final lower = (_f.minRate / VenueFilters.rateCeiling * heights.length)
        .floor();
    final upper = (_f.maxRate / VenueFilters.rateCeiling * heights.length)
        .ceil();
    return SizedBox(
      height: 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < heights.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: heights[index],
                  decoration: BoxDecoration(
                    color: index >= lower && index < upper
                        ? (index % 3 == 0 ? const Color(0xFF8FB2EC) : _blue)
                        : const Color(0xFFE5EAFE),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ratePreset(String label, double min, double max) {
    final selected = _f.minRate == min && _f.maxRate == max;
    return _chip(
      label,
      selected,
      () => setState(
        () => _f = _f.copyWith(
          minRate: selected ? 0 : min,
          maxRate: selected ? VenueFilters.rateCeiling : max,
        ),
      ),
    );
  }

  Widget _amenityRow(String amenity) {
    final selected = _f.amenities.contains(amenity);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? const Color(0xFFEAF0FF) : const Color(0xFFF5F6FB),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleAmenity(amenity, !selected),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCE7FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_amenityIcon(amenity), color: _blue, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    amenity,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? _blue : const Color(0xFFD9DEEA),
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleAmenity(String amenity, bool selected) {
    setState(() {
      final next = {..._f.amenities};
      selected ? next.add(amenity) : next.remove(amenity);
      _f = _f.copyWith(amenities: next);
    });
  }

  IconData _sportIcon(String sport) {
    final value = sport.toLowerCase();
    if (value.contains('football') || value.contains('futsal')) {
      return Icons.sports_soccer_rounded;
    }
    if (value.contains('basket')) {
      return Icons.sports_basketball_rounded;
    }
    return Icons.sports_tennis_rounded;
  }

  IconData _amenityIcon(String amenity) {
    final value = amenity.toLowerCase();
    if (value.contains('park')) {
      return Icons.local_parking_rounded;
    }
    if (value.contains('light')) {
      return Icons.wb_twilight_rounded;
    }
    if (value.contains('locker') ||
        value.contains('shower') ||
        value.contains('changing')) {
      return Icons.shower_rounded;
    }
    if (value.contains('air')) {
      return Icons.ac_unit_rounded;
    }
    if (value.contains('shop') || value.contains('rental')) {
      return Icons.sports_tennis_rounded;
    }
    if (value.contains('cafe') ||
        value.contains('refresh') ||
        value.contains('food')) {
      return Icons.local_cafe_rounded;
    }
    return Icons.checkroom_rounded;
  }
}
