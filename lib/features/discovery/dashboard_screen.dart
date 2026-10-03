import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SupabaseService();
  String _selectedSport = 'Badminton';

  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F3FF);
  static const _venueImages = [
    'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=900&q=80',
  ];

  Future<List<Map<String, dynamic>>> _loadVenues() {
    return _service.getVenues(sport: _selectedSport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
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
                    _buildOffer(),
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
                child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 23),
              ),
              const SizedBox(width: 9),
              const Text(
                'SPORTSBOOK',
                style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.6),
              ),
              const Text(
                'Court Dashboard',
                style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: _muted)),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 21),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              const Text('COLOMBO 07, CINNAMON GARDENS', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, color: _muted, size: 18),
              const Spacer(),
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFE4E9FF)),
                icon: const Icon(Icons.search_rounded, color: _ink),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Hello, Kasun 👋', style: TextStyle(color: _ink, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.7)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Ready for today's match?", style: TextStyle(color: _muted, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x0C001844), blurRadius: 14, offset: Offset(0, 5))]),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE6ECFF), borderRadius: BorderRadius.circular(18)), child: const Text('⟳ QUICK RE-BOOK', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))),
              const Spacer(),
              const Text('Played 2 days ago', style: TextStyle(color: _muted, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xFFE8EDFF), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 30)),
              const SizedBox(width: 14),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CSA National Arena', style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Court 1 (Indoor Teak Wood)', style: TextStyle(color: _muted, fontSize: 14))]),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('FAST AVAILABILITY', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Today, 6:00 PM • LKR 2,500', style: TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w600))])), _SmallBlueButton(label: 'Re-book', icon: Icons.arrow_forward_rounded, onPressed: () {})]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      ('Badminton', '14 Venues', Icons.sports_tennis_rounded),
      ('Tennis', '8 Venues', Icons.sports_tennis_rounded),
      ('Squash', '5 Venues', Icons.sports_handball_rounded),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Categories', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w700)), const Spacer(), const Text('5 SPORTS ACTIVE', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 13),
      Row(children: categories.map((category) {
        final selected = _selectedSport == category.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedSport = category.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: selected
                      ? const [BoxShadow(color: Color(0x300066FF), blurRadius: 10, offset: Offset(0, 5))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category.$3, color: selected ? Colors.white : AppColors.primary, size: 18),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.$1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? Colors.white : _ink, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(category.$2, style: TextStyle(color: selected ? Colors.white70 : _muted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList()),
    ]);
  }

  Widget _buildOffer() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x350066FF), blurRadius: 15, offset: Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)), child: const Text('⚡ WEEKEND SPECIAL', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Text('25% OFF', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)))]),
        const SizedBox(height: 18),
        const Text('Weekend Smash Deal ⚡', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Flat 25% OFF on morning slots before 10 AM at\nselect arenas.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
        const SizedBox(height: 15),
        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)), child: const Text('MORNING SMASH', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),), const Spacer(), TextButton.icon(onPressed: () {}, icon: const Text('Claim Offer', style: TextStyle(color: Colors.white)), label: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18))]),
      ]),
    );
  }

  Widget _buildNearbyHeader() {
    return const Row(children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nearby Courts', style: TextStyle(color: _ink, fontSize: 22, fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('Real-time availability in Colombo', style: TextStyle(color: _muted, fontSize: 14))]), Spacer(), Text('▧ Map View', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700))]);
  }

  Widget _buildVenues() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadVenues(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()));
        if (snapshot.hasError) return Text('Unable to load courts: ${snapshot.error}', style: const TextStyle(color: _muted));
        final venues = snapshot.data ?? [];
        if (venues.isEmpty) return const Text('No courts found for this sport.', style: TextStyle(color: _muted));
        return Column(children: venues.take(3).toList().asMap().entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _VenueCard(venue: entry.value, imageUrl: _venueImages[entry.key % _venueImages.length], onBook: () => _bookVenue(entry.value)))).toList());
      },
    );
  }

  Future<void> _bookVenue(Map<String, dynamic> venue) async {
    final rate = (venue['hourly_rate'] as num?)?.toDouble() ?? 1500;
    try {
      await _service.createBooking(venueId: venue['id'] ?? 'ven-01', bookingRef: 'SB-${DateTime.now().millisecondsSinceEpoch}', courtName: '${venue['name']} - Court 1', dateSchedule: DateTime.now().toIso8601String().split('T').first, timeSlot: '06:00 PM - 07:00 PM', totalPaid: rate, qrPin: '8492');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Court booked successfully!'), backgroundColor: Colors.green));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking error: $error')));
    }
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.imageUrl, required this.onBook});

  final Map<String, dynamic> venue;
  final String imageUrl;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final rate = venue['hourly_rate'] ?? 1500;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0C001844), blurRadius: 12, offset: Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 150, width: double.infinity, child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const ColoredBox(color: Color(0xFFDCE7FF), child: Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 48)))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 14, 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(venue['name'] ?? 'Court venue', style: const TextStyle(color: _DashboardScreenState._ink, fontSize: 18, fontWeight: FontWeight.w700))), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE5EAFF), borderRadius: BorderRadius.circular(12)), child: Text(venue['environment'] ?? 'Indoor', style: const TextStyle(color: _DashboardScreenState._muted, fontSize: 11, fontWeight: FontWeight.w600)))]),
          const SizedBox(height: 4),
          Text(venue['address'] ?? venue['area'] ?? 'Colombo 07', style: const TextStyle(color: _DashboardScreenState._muted, fontSize: 14)),
          const SizedBox(height: 16),
          Row(children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('NEXT AVAILABLE', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('6:00 PM • ', style: TextStyle(color: _DashboardScreenState._ink, fontSize: 15, fontWeight: FontWeight.w700))]), Text('LKR $rate/hr', style: const TextStyle(color: _DashboardScreenState._ink, fontSize: 13, fontWeight: FontWeight.w700)), const Spacer(), _SmallBlueButton(label: 'Book Slot', icon: Icons.arrow_forward_rounded, onPressed: onBook)]),
        ])),
      ]),
    );
  }
}

class _SmallBlueButton extends StatelessWidget {
  const _SmallBlueButton({required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(onPressed: onPressed, icon: Text(label), label: Icon(icon, size: 18), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const StadiumBorder(), textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));
}

class _PartnerFooter extends StatelessWidget {
  const _PartnerFooter();

  @override
  Widget build(BuildContext context) => const Column(children: [Text('✦  OFFICIAL PARTNER OF COLOMBO SPORTS AUTHORITY', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3)), SizedBox(height: 7), Text('SportsBook version 2.4.0 • Real-time Sync Active', style: TextStyle(color: Color(0xFF9AA0AF), fontSize: 12))]);
}
