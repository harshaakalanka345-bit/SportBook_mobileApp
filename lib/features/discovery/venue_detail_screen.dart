import 'package:flutter/material.dart';

import '../../core/actions.dart';
import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import '../../core/venue_image.dart';
import '../auth/profile_screen.dart';
import '../booking/booking_flow/booking_flow_popup.dart';
import '../booking/booking_flow/booking_step1_screen.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({super.key, required this.venue});

  final Map<String, dynamic> venue;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);
  final _service = SupabaseService();
  bool _favorite = false;
  late Future<List<Map<String, dynamic>>> _courtsFuture;

  String get _name => '${widget.venue['name'] ?? 'Sports venue'}';
  String get _address => '${widget.venue['address'] ?? ''}'.trim();
  String get _area => '${widget.venue['area'] ?? ''}'.trim();
  String get _directionsQuery => [
    _name,
    _address.isEmpty ? _area : _address,
  ].where((value) => value.isNotEmpty).join(', ');

  @override
  void initState() {
    super.initState();
    final id = widget.venue['id']?.toString();
    _courtsFuture = id == null
        ? Future.value(const [])
        : _service.getVenueCourts(id);
    if (id != null) {
      _service
          .isFavorite(id)
          .then((value) {
            if (mounted) setState(() => _favorite = value);
          })
          .catchError((_) {});
    }
  }

  Future<void> _toggleFavorite() async {
    final id = widget.venue['id']?.toString();
    if (id == null) {
      toast('This venue cannot be saved right now.');
      return;
    }
    try {
      final saved = await _service.toggleFavorite(id);
      if (mounted) setState(() => _favorite = saved);
      toast(saved ? 'Saved to your favourites' : 'Removed from favourites');
    } catch (error) {
      toast('Could not update favourites: $error');
    }
  }

  void _book() =>
      showBookingStepPopup(context, BookingStep1Screen(venue: widget.venue));

  String _money(dynamic value) {
    final amount = value is num ? value : num.tryParse('$value');
    if (amount == null) return 'Rate not set';
    final whole = amount.toStringAsFixed(
      amount == amount.roundToDouble() ? 0 : 2,
    );
    final formatted = whole.replaceAllMapped(
      RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return 'LKR $formatted';
  }

  List<String> get _amenities {
    final raw = widget.venue['amenities'];
    if (raw is List) {
      return raw
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String _hours(String key) {
    final raw = '${widget.venue[key] ?? ''}'.trim();
    if (raw.isEmpty) return '';
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1].substring(0, 2));
    if (hour == null || minute == null) return raw;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final rate = widget.venue['hourly_rate'];
    final sport = '${widget.venue['sport'] ?? ''}'.trim();
    final environment = '${widget.venue['environment'] ?? ''}'.trim();
    final opening = _hours('opening_time');
    final closing = _hours('closing_time');
    final hours = opening.isNotEmpty && closing.isNotEmpty
        ? '$opening – $closing'
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFFFAF8FF),
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: _ink),
              ),
              title: const Text(
                'Venue details',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: _favorite ? 'Remove saved venue' : 'Save venue',
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _favorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'Profile',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  icon: const Icon(Icons.person_outline_rounded, color: _ink),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        height: 225,
                        width: double.infinity,
                        child: VenueImage(venue: widget.venue),
                      ),
                    ),
                    const SizedBox(height: 19),
                    Text(
                      _name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (sport.isNotEmpty)
                          _tag(Icons.sports_tennis_rounded, sport),
                        if (environment.isNotEmpty)
                          _tag(Icons.roofing_outlined, environment),
                        if (_area.isNotEmpty)
                          _tag(Icons.location_on_outlined, _area),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _card(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hourly rate',
                                  style: TextStyle(color: _muted, fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  rate == null
                                      ? 'Rate not listed'
                                      : '${_money(rate)} / hour',
                                  style: const TextStyle(
                                    color: _ink,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.info_outline_rounded,
                            color: _muted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (hours.isNotEmpty) ...[
                      _card(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Venue hours',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    hours,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _locationCard(),
                    const SizedBox(height: 23),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Courts at this venue',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            final id = widget.venue['id']?.toString();
                            _courtsFuture = id == null
                                ? Future.value(const [])
                                : _service.getVenueCourts(id);
                          }),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Choose a court to check its date and time slots.',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _courts(),
                    if (_amenities.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      const Text(
                        'Amenities',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final amenity in _amenities)
                            _tag(Icons.check_circle_outline_rounded, amenity),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => shareText(
                        '$_name${_address.isEmpty ? '' : ', $_address'}',
                        subject: '$_name on SportsBook',
                      ),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share venue'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
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
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FROM',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      rate == null ? 'Rate not listed' : '${_money(rate)} / hr',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _book,
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('Choose date & court'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: _softBlue,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE9EEFF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _locationCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _address.isNotEmpty
                        ? _address
                        : (_area.isNotEmpty ? _area : 'Address not provided'),
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_address.isNotEmpty &&
                      _area.isNotEmpty &&
                      _address != _area) ...[
                    const SizedBox(height: 3),
                    Text(
                      _area,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _directionsQuery.isEmpty
                    ? null
                    : () => openDirections(_directionsQuery),
                icon: const Icon(Icons.directions_rounded, size: 17),
                label: const Text('Directions'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  copyText(_directionsQuery, message: 'Address copied'),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _courts() => FutureBuilder<List<Map<String, dynamic>>>(
    future: _courtsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      if (snapshot.hasError)
        return _card(
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded, color: _muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Court list could not load. ${snapshot.error}',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      final uniqueByName = <String, Map<String, dynamic>>{};
      for (final court in snapshot.data ?? const <Map<String, dynamic>>[]) {
        final name = '${court['name'] ?? ''}'.trim();
        final key = name.isEmpty
            ? '${court['id'] ?? uniqueByName.length}'
            : name.toLowerCase();
        uniqueByName.putIfAbsent(key, () => court);
      }
      final courts = uniqueByName.values.toList();
      if (courts.isEmpty)
        return _card(
          child: const Row(
            children: [
              Icon(Icons.sports_tennis_rounded, color: _muted),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No court details have been added for this venue yet.',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      return Column(children: [for (final court in courts) _courtCard(court)]);
    },
  );

  Widget _courtCard(Map<String, dynamic> court) {
    final name = '${court['name'] ?? 'Court'}';
    final type = '${court['type'] ?? ''}'.trim();
    final courtRate = court['hourly_rate'] ?? widget.venue['hourly_rate'];
    final active = court['is_active'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_tennis_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (type.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      type,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ),
                if (courtRate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '${_money(courtRate)} / hour',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: active == false ? null : _book,
            child: Text(active == false ? 'Unavailable' : 'Choose'),
          ),
        ],
      ),
    );
  }
}
