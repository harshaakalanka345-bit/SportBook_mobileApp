import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/location_service.dart';
import '../../core/supabase_service.dart';
import '../../core/sports.dart';
import '../../core/venue_image.dart';
import '../booking/booking_flow/booking_step1_screen.dart';
import '../booking/booking_flow/booking_flow_popup.dart';
import '../auth/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import 'venue_detail_screen.dart';
import 'search_screen.dart';
import 'location_access_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SupabaseService();
  String _selectedSport = 'Badminton';
  Map<String, dynamic>? _lastBooking;
  String _playerName = 'there';
  String _locationLabel = 'ALL LOCATIONS';
  String? _locationSearchText;
  AppLocation? _currentLocation;
  late Future<List<Map<String, dynamic>>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _refreshVenues();
    _service
        .getProfile()
        .then((profile) {
          final name = '${profile?['full_name'] ?? ''}'.trim();
          if (mounted && name.isNotEmpty) {
            setState(() => _playerName = name.split(RegExp(r'\s+')).first);
          }
        })
        .catchError((_) {});
    _service
        .getUserBookings()
        .then((list) {
          Map<String, dynamic>? last;
          for (final booking in list.cast<Map<String, dynamic>>()) {
            if ('${booking['status'] ?? ''}'.toLowerCase() != 'cancelled') {
              last = booking;
              break;
            }
          }
          if (mounted) setState(() => _lastBooking = last);
        })
        .catchError((_) {});
  }

  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F3FF);
  Future<List<Map<String, dynamic>>> _loadVenues() {
    return _service.getVenues(sport: _selectedSport).then(_venuesForLocation);
  }

  void _refreshVenues() {
    _venuesFuture = _loadVenues();
  }

  List<Map<String, dynamic>> _venuesForLocation(
    List<Map<String, dynamic>> venues,
  ) {
    final query = _locationSearchText?.trim().toLowerCase();
    final current = _currentLocation;
    if ((query == null || query.isEmpty) && current == null) return venues;
    final filtered = venues.where((venue) {
      if (query != null && query.isNotEmpty) {
        final text =
            '${venue['name'] ?? ''} ${venue['area'] ?? ''} ${venue['address'] ?? ''}'
                .toLowerCase();
        return query
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .every(text.contains);
      }
      final latitude = _number(venue['latitude'] ?? venue['lat']);
      final longitude = _number(
        venue['longitude'] ?? venue['lng'] ?? venue['lon'],
      );
      if (latitude == null || longitude == null || current == null) return true;
      return _distanceKm(
            current.latitude,
            current.longitude,
            latitude,
            longitude,
          ) <=
          25;
    }).toList();
    return filtered;
  }

  double? _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value');

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const radius = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(_refreshVenues);
            await _venuesFuture;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildBookingCard(),
                    const SizedBox(height: 26),
                    _buildCategories(),
                    const SizedBox(height: 28),
                    const SizedBox(height: 28),
                    _buildNearbyHeader(),
                    const SizedBox(height: 14),
                    _buildVenues(),
                    const SizedBox(height: 26),
                    const _PartnerFooter(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_tennis_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPORTSBOOK',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Court Dashboard',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: _muted,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _changeLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _locationLabel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _muted,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.popUntil((route) => route.isFirst);
                  // Optionally, you might want to switch tabs instead of pushing a new screen if it's a bottom nav bar.
                  // Wait, how is Search navigated to? Let's just push it for now if it's not available.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE4E9FF),
                ),
                icon: const Icon(Icons.search_rounded, color: _ink),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hello, $_playerName 👋',
              style: const TextStyle(
                color: _ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Ready for today's match?",
              style: TextStyle(color: _muted, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLocation() async {
    final selection = await Navigator.push<LocationSelection>(
      context,
      MaterialPageRoute(builder: (_) => const LocationAccessScreen()),
    );
    if (!mounted || selection == null) return;
    setState(() {
      _locationLabel = selection.label;
      _locationSearchText = selection.searchText;
      _currentLocation = selection.location;
      _refreshVenues();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Showing courts near ${selection.label}.')),
    );
  }

  Widget _buildBookingCard() {
    final booking = _lastBooking;
    final venue = booking?['venues'] is Map ? booking!['venues'] as Map : null;
    final venueName = '${venue?['name'] ?? ''}'.trim();
    final date = DateTime.tryParse('${booking?['date_schedule'] ?? ''}');
    final dateLabel = date == null
        ? ''
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final summary = [
      if ('${booking?['court_name'] ?? ''}'.trim().isNotEmpty)
        '${booking?['court_name']}',
      if (dateLabel.isNotEmpty) dateLabel,
    ].join(' • ');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C001844),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                booking == null
                    ? Icons.sports_tennis_rounded
                    : Icons.history_rounded,
                color: AppColors.primary,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking == null
                      ? 'Ready to book a court?'
                      : 'Your latest booking',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (booking != null && '${booking['status'] ?? ''}'.isNotEmpty)
                Text(
                  '${booking['status']}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (booking != null) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.sports_tennis_rounded,
                    color: AppColors.primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName.isEmpty ? 'Sports venue' : venueName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.isEmpty ? 'Booking details' : summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking == null ? 'GET STARTED' : 'BOOK AGAIN',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking == null
                            ? 'Find a venue and choose a time'
                            : (venueName.isEmpty
                                  ? 'Open your latest venue'
                                  : venueName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _SmallBlueButton(
                  label: booking == null ? 'Browse' : 'Re-book',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    final savedVenue = booking?['venues'];
                    if (savedVenue is Map && savedVenue['id'] != null) {
                      showBookingStepPopup(
                        context,
                        BookingStep1Screen(
                          venue: Map<String, dynamic>.from(savedVenue),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Categories',
                style: TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${kSports.length} SPORTS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kSports.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final sport = kSports[index];
              final selected = _selectedSport == sport;
              return SizedBox(
                width: 150,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSport = sport);
                    _refreshVenues();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: Color(0x300066FF),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sportIcon(sport),
                          color: selected ? Colors.white : AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sport,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected ? Colors.white : _ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Explore venues',
                                style: TextStyle(
                                  color: selected ? Colors.white70 : _muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby Courts',
                style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Browse venues and check court times',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          child: const Text(
            'See all →',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenues() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _venuesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: CircularProgressIndicator(),
            ),
          );
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Could not connect to the court service.',
                style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${snapshot.error}',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => setState(_refreshVenues),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry courts'),
              ),
            ],
          );
        }
        final venues = snapshot.data ?? [];
        if (venues.isEmpty)
          return Text(
            _locationSearchText == null
                ? 'No courts found for this sport.'
                : 'No courts found near $_locationLabel.',
            style: const TextStyle(color: _muted),
          );
        return Column(
          children: [
            for (final venue in venues)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _VenueCard(
                  venue: venue,
                  onBook: () => _bookVenue(venue),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _bookVenue(Map<String, dynamic> venue) async {
    showBookingStepPopup(context, BookingStep1Screen(venue: venue));
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.onBook});

  final Map<String, dynamic> venue;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final rate = venue['hourly_rate'];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VenueDetailScreen(venue: venue)),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C001844),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: VenueImage(venue: venue),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue['name'] ?? 'Court venue',
                          style: const TextStyle(
                            color: _DashboardScreenState._ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EAFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          venue['environment'] ?? 'Environment not listed',
                          style: const TextStyle(
                            color: _DashboardScreenState._muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue['address'] ?? venue['area'] ?? 'Address not listed',
                    style: const TextStyle(
                      color: _DashboardScreenState._muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HOURLY RATE',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            rate == null
                                ? 'Rate not listed'
                                : 'LKR $rate / hour',
                            style: const TextStyle(
                              color: _DashboardScreenState._ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      _SmallBlueButton(
                        label: 'Book Slot',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: onBook,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBlueButton extends StatelessWidget {
  const _SmallBlueButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Text(label),
    label: Icon(icon, size: 18),
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}

class _PartnerFooter extends StatelessWidget {
  const _PartnerFooter();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      Text(
        'SPORTSBOOK • COURTS, BOOKINGS & PLAYING PARTNERS',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      SizedBox(height: 7),
      Text(
        'Browse venues, check court times and book online',
        style: TextStyle(color: Color(0xFF9AA0AF), fontSize: 12),
      ),
    ],
  );
}
