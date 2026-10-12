import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import '../../core/venue_filters.dart';
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
  static const softBlue = Color(0xFFF0F2FF);

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
      final v = await _service.getVenues();
      if (mounted) setState(() => _venues = v);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _results => _venues.where((v) => _filters.matches(v, _query.text)).toList();

  Future<void> _openFilters() async {
    final result = await Navigator.push<VenueFilters>(
      context,
      MaterialPageRoute(builder: (_) => FilterScreen(venues: _venues, initial: _filters)),
    );
    if (result != null) setState(() => _filters = result);
  }

  Future<void> _notifyMe() async {
    final sport = _filters.sport ?? 'Any sport';
    final area = _filters.area ?? 'Any area';
    try {
      await _service.addSlotAlert(sport: sport, area: area);
      toast('Alert saved: $sport in $area. (Notifications are not delivered yet.)');
    } catch (e) {
      toast('Could not create the alert: $e');
    }
  }

  List<(String, VoidCallback)> get _chips => [
        if (_filters.sport != null) (_filters.sport!, () => setState(() => _filters = _filters.copyWith(sport: null))),
        if (_filters.environment != null) (_filters.environment!, () => setState(() => _filters = _filters.copyWith(environment: null))),
        if (_filters.area != null) (_filters.area!, () => setState(() => _filters = _filters.copyWith(area: null))),
        if (_filters.minRate > 0 || _filters.maxRate < VenueFilters.rateCeiling)
          (
            'LKR ${_filters.minRate.round()}-${_filters.maxRate >= VenueFilters.rateCeiling ? '${VenueFilters.rateCeiling.round()}+' : _filters.maxRate.round()}',
            () => setState(() => _filters = _filters.copyWith(minRate: 0, maxRate: VenueFilters.rateCeiling)),
          ),
        for (final a in _filters.amenities) (a, () => setState(() => _filters = _filters.copyWith(amenities: {..._filters.amenities}..remove(a)))),
      ];

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        titleSpacing: 20,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.search, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          const Text('Search', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          Stack(alignment: Alignment.topRight, children: [
            IconButton(icon: const Icon(Icons.tune_rounded, color: ink), onPressed: _venues.isEmpty ? null : _openFilters),
            if (_filters.activeCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text('${_filters.activeCount}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ),
          ]),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: ink),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 20, left: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search courts, areas or sports…',
                prefixIcon: const Icon(Icons.search_rounded, color: muted),
                suffixIcon: _query.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(_query.clear)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            if (_chips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('APPLIED FILTERS', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                    GestureDetector(
                      onTap: () => setState(() => _filters = const VenueFilters()),
                      child: const Text('Clear all', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final c in _chips) InputChip(label: Text(c.$1, style: const TextStyle(fontSize: 11)), onDeleted: c.$2, backgroundColor: Colors.white, side: BorderSide.none),
                  ]),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            if (_loading)
              const Padding(padding: EdgeInsets.only(top: 60), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              _message(Icons.cloud_off, 'Could not load courts', _error!, [FilledButton(onPressed: _load, child: const Text('Retry'))])
            else if (results.isEmpty)
              _message(
                Icons.search_off_rounded,
                'No courts match',
                _venues.isEmpty ? 'There are no registered courts yet.' : 'Nothing matches your search and filters. Try widening them, or get an alert when a matching court is listed.',
                [
                  if (!_filters.isEmpty || _query.text.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        _filters = const VenueFilters();
                        _query.clear();
                      }),
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Reset search & filters'),
                    ),
                  OutlinedButton.icon(onPressed: _notifyMe, icon: const Icon(Icons.notifications_active_outlined, size: 18), label: const Text('Notify me')),
                ],
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('${results.length} ${results.length == 1 ? 'court' : 'courts'} found', style: const TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              for (final v in results) _venueCard(v),
            ],
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, List<Widget> actions) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(children: [
          Icon(icon, size: 44, color: muted),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12, height: 1.4)),
          const SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: actions),
        ]),
      );

  Widget _venueCard(Map<String, dynamic> v) {
    final amenities = ((v['amenities'] as List?) ?? const []).take(3).join(' • ');
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(venue: v))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x0C001844), blurRadius: 10, offset: Offset(0, 4))]),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFE2EAFF), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${v['name']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('${v['sport']} • ${v['environment']} • ${v['area']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12)),
              if (amenities.isNotEmpty) Text(amenities, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('LKR ${(v['hourly_rate'] as num?)?.toStringAsFixed(0) ?? '-'}', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
            const Text('/ hr', style: TextStyle(color: muted, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}
