import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  static const _ink = Color(0xFF11182D);
  static const _softBlue = Color(0xFFF0F2FF);

  final _service = SupabaseService();
  final _images = const [
    'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=900&q=80',
  ];

  Future<List<Map<String, dynamic>>> _loadVenues() async {
    final venues = await _service.getVenues(sport: 'Badminton');
    return venues.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadVenues(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Unable to load courts: ${snapshot.error}'));
                  }
                  final venues = snapshot.data ?? [];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _buildSummary(),
                      const SizedBox(height: 14),
                      if (venues.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Text('No courts available for these filters.'),
                        )
                      else
                        ...venues.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ResultCard(
                              venue: entry.value,
                              imageUrl: _images[entry.key % _images.length],
                              onBook: () => _bookVenue(entry.value),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text('View More  18'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF252D43),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _ResultsFooter(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE9EEFF),
              foregroundColor: _ink,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 7),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPORTSBOOK', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                Text('Select Your Slot', style: TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w600, height: 1.1)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.person_outline_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 9),
              const Expanded(child: Text('Badminton in Colombo 07', style: TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w600))),
              const Icon(Icons.tune_rounded, color: AppColors.primary, size: 21),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: const [
            _SummaryChip(label: '7 FILTERS APPLIED', strong: true),
            _SummaryChip(label: 'Today, 5-10 PM'),
            _SummaryChip(label: 'Indoor Parquet'),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '● ', style: TextStyle(color: AppColors.primary)),
                    TextSpan(text: '18 Available\nCourts', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.swap_vert_rounded, size: 16), label: const Text('Nearest'), style: _outlineStyle),
            const SizedBox(width: 7),
            FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.map_outlined, size: 16), label: const Text('Map'), style: _mapStyle),
          ],
        ),
      ],
    );
  }

  Future<void> _bookVenue(Map<String, dynamic> venue) async {
    final rate = (venue['hourly_rate'] as num?)?.toDouble() ?? 1500;
    try {
      await _service.createBooking(
        venueId: venue['id'] ?? 'ven-01',
        bookingRef: 'SB-${DateTime.now().millisecondsSinceEpoch}',
        courtName: '${venue['name']} - Court 1',
        dateSchedule: DateTime.now().toIso8601String().split('T').first,
        timeSlot: '06:00 PM - 07:00 PM',
        totalPaid: rate,
        qrPin: '8492',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Court booked successfully!'), backgroundColor: Colors.green));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking error: $error')));
    }
  }

  static final _outlineStyle = OutlinedButton.styleFrom(foregroundColor: _ink, side: const BorderSide(color: Color(0xFFE1E5F3)), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const StadiumBorder(), textStyle: const TextStyle(fontSize: 11));
  static final _mapStyle = FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const StadiumBorder(), textStyle: const TextStyle(fontSize: 11));
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.venue, required this.imageUrl, required this.onBook});

  final Map<String, dynamic> venue;
  final String imageUrl;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final rate = venue['hourly_rate'] ?? 1500;
    final name = venue['name'] ?? 'Badminton Arena';
    final area = venue['area'] ?? 'Colombo 07';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), boxShadow: const [BoxShadow(color: Color(0x0C001844), blurRadius: 12, offset: Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(height: 145, width: double.infinity, child: Stack(fit: StackFit.expand, children: [Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFFDCE7FF), child: Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 48))), const Positioned(top: 10, left: 10, child: _ImageBadge(label: 'TOP PICK')), const Positioned(bottom: 9, left: 9, child: _RatingBadge()), Positioned(top: 9, right: 9, child: Container(width: 33, height: 33, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.favorite_border_rounded, color: _SearchResultsColors.ink, size: 19)))]))),
        const SizedBox(height: 11),
        Text('$name - Court 1', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _SearchResultsColors.ink, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('⌖  ${area == 'Colombo 07' ? '0.8 km' : '1.5 km'}  •  ${venue['address'] ?? area}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _SearchResultsColors.muted, fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(spacing: 5, children: const [_AmenityTag(label: '❄ Air Conditioned'), _AmenityTag(label: 'P Free Area Parking'), _AmenityTag(label: '♨ Showers & Lockers')]),
        const SizedBox(height: 11),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9), decoration: BoxDecoration(color: _SearchResultsColors.softBlue, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Text('◷ TONIGHT\'S AVAILABLE SLOTS', style: TextStyle(color: _SearchResultsColors.muted, fontSize: 9, fontWeight: FontWeight.w700)), const Spacer(), const Text('Fast Reserve', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700))])),
        const SizedBox(height: 9),
        Row(children: [_TimeSlot(label: '06:00 PM', price: 'LKR $rate'), _TimeSlot(label: '07:30 PM', price: 'LKR $rate'), _TimeSlot(label: '09:00 PM', price: 'LKR 2,200')]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('STANDARD RATE', style: TextStyle(color: _SearchResultsColors.muted, fontSize: 9, fontWeight: FontWeight.w700)), Text('LKR $rate', style: const TextStyle(color: _SearchResultsColors.ink, fontSize: 18, fontWeight: FontWeight.w800))])), FilledButton.icon(onPressed: onBook, icon: const Text('Book Slot'), label: const Icon(Icons.arrow_forward_rounded, size: 17), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const StadiumBorder(), textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))]),
      ]),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, this.strong = false});

  final String label;
  final bool strong;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: strong ? const Color(0xFFDCE5FF) : _SearchResultsColors.softBlue, borderRadius: BorderRadius.circular(18)), child: Text(label, style: TextStyle(color: strong ? AppColors.primary : _SearchResultsColors.muted, fontSize: 11, fontWeight: FontWeight.w600)));
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)));
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge();

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: const Color(0xB900162F), borderRadius: BorderRadius.circular(12)), child: const Text('★ 4.9  (128 reviews)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)));
}

class _AmenityTag extends StatelessWidget {
  const _AmenityTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: _SearchResultsColors.softBlue, borderRadius: BorderRadius.circular(6)), child: Text(label, style: const TextStyle(color: _SearchResultsColors.muted, fontSize: 9)));
}

class _TimeSlot extends StatelessWidget {
  const _TimeSlot({required this.label, required this.price});

  final String label;
  final String price;

  @override
  Widget build(BuildContext context) => Expanded(child: Container(margin: const EdgeInsets.only(right: 5), padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)), child: Column(children: [Text(label, style: const TextStyle(color: _SearchResultsColors.ink, fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(price, style: const TextStyle(color: _SearchResultsColors.muted, fontSize: 9))])));
}

class _ResultsFooter extends StatelessWidget {
  const _ResultsFooter();

  @override
  Widget build(BuildContext context) => const Column(children: [Text('◎  Live Availability Radar Active • Colombo Sports Authority\nPartner', textAlign: TextAlign.center, style: TextStyle(color: _SearchResultsColors.muted, fontSize: 11, height: 1.5)), SizedBox(height: 12), Text('VERSION 2.4.0 • UPDATED JUST NOW', style: TextStyle(color: Color(0xFF9AA0AF), fontSize: 9, letterSpacing: 0.3))]);
}

class _SearchResultsColors {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
}
