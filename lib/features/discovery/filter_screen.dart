import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/venue_filters.dart';

/// Filter picker for venue search. Pops with the chosen [VenueFilters].
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, required this.venues, required this.initial});

  /// Used to offer the areas and amenities that actually exist.
  final List<Map<String, dynamic>> venues;
  final VenueFilters initial;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);

  late VenueFilters _f;

  @override
  void initState() {
    super.initState();
    _f = widget.initial;
  }

  List<String> _distinct(String key) => widget.venues.map((v) => v[key]).whereType<String>().toSet().toList()..sort();

  List<String> get _amenityOptions {
    final s = <String>{};
    for (final v in widget.venues) {
      for (final a in (v['amenities'] as List?) ?? const []) {
        s.add('$a');
      }
    }
    return s.toList()..sort();
  }

  int get _matchCount => widget.venues.where((v) => _f.matches(v, '')).length;

  Widget _section(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          child,
        ]),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : _ink, fontWeight: FontWeight.w600),
        onSelected: (_) => onTap(),
      );

  @override
  Widget build(BuildContext context) {
    final sports = _distinct('sport');
    final areas = _distinct('area');
    final amenities = _amenityOptions;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: _ink), onPressed: () => Navigator.pop(context)),
        title: const Text('Filters', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _f = const VenueFilters()),
            child: const Text('Reset', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _section(
            'SPORT',
            Wrap(spacing: 8, runSpacing: 8, children: [
              _chip('Any', _f.sport == null, () => setState(() => _f = _f.copyWith(sport: null))),
              for (final s in sports) _chip(s, _f.sport == s, () => setState(() => _f = _f.copyWith(sport: s))),
            ]),
          ),
          _section(
            'ENVIRONMENT',
            Wrap(spacing: 8, runSpacing: 8, children: [
              _chip('Any', _f.environment == null, () => setState(() => _f = _f.copyWith(environment: null))),
              for (final e in const ['Indoor', 'Outdoor']) _chip(e, _f.environment == e, () => setState(() => _f = _f.copyWith(environment: e))),
            ]),
          ),
          _section(
            'AREA',
            Wrap(spacing: 8, runSpacing: 8, children: [
              _chip('Any', _f.area == null, () => setState(() => _f = _f.copyWith(area: null))),
              for (final a in areas) _chip(a, _f.area == a, () => setState(() => _f = _f.copyWith(area: a))),
            ]),
          ),
          _section(
            'HOURLY RATE  (LKR ${_f.minRate.round()} - ${_f.maxRate >= VenueFilters.rateCeiling ? '${VenueFilters.rateCeiling.round()}+' : _f.maxRate.round()})',
            RangeSlider(
              values: RangeValues(_f.minRate, _f.maxRate),
              min: 0,
              max: VenueFilters.rateCeiling,
              divisions: 20,
              activeColor: AppColors.primary,
              onChanged: (r) => setState(() => _f = _f.copyWith(minRate: r.start, maxRate: r.end)),
            ),
          ),
          if (amenities.isNotEmpty)
            _section(
              'AMENITIES',
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final a in amenities)
                  FilterChip(
                    label: Text(a),
                    selected: _f.amenities.contains(a),
                    selectedColor: const Color(0xFFDCE7FF),
                    checkmarkColor: AppColors.primary,
                    onSelected: (v) => setState(() {
                      final next = {..._f.amenities};
                      v ? next.add(a) : next.remove(a);
                      _f = _f.copyWith(amenities: next);
                    }),
                  ),
              ]),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: () => Navigator.pop(context, _f),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Text('Show $_matchCount ${_matchCount == 1 ? 'court' : 'courts'}', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
