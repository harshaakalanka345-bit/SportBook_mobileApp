import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';

class RateReviewScreen extends StatefulWidget {
  const RateReviewScreen({super.key, this.booking});

  final Map<String, dynamic>? booking;

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  int _rating = 0;
  bool _submitting = false;
  final _service = SupabaseService();
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  static const _ratingText = [
    'Tap a star to rate',
    'Poor',
    'Fair',
    'Good',
    'Great',
    'Outstanding Experience!',
  ];

  Future<void> _submit() async {
    if (_rating == 0) {
      toast('Please choose a star rating first.');
      return;
    }
    final ref = widget.booking?['booking_ref'] as String?;
    if (ref == null) {
      toast('No booking selected.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await _service.createReview(
        bookingRef: ref,
        venueId: widget.booking?['venue_id'] as String?,
        rating: _rating,
        comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      toast('Thanks! Your review was submitted.');
    } catch (e) {
      if (mounted) toast('Could not submit review: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rate & Review',
          style: TextStyle(
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
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
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              100,
            ), // padding for bottom button
            children: [
              _buildVerifiedBanner(),
              const SizedBox(height: 16),
              _buildBookingCard(),
              const SizedBox(height: 24),
              _buildOverallExperience(),
              const SizedBox(height: 24),
              _buildMatchReview(),
              const SizedBox(height: 40),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBanner() {
    final ref = '${widget.booking?['booking_ref'] ?? '—'}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_outlined, color: AppColors.primary, size: 13),
              SizedBox(width: 5),
              Text(
                'REVIEW FOR A BOOKING',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Text(
            'Ref $ref',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 9),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard() {
    final booking = widget.booking ?? const <String, dynamic>{};
    final venue = booking['venues'] is Map
        ? booking['venues'] as Map
        : const {};
    final venueName = '${venue['name'] ?? 'Sports venue'}';
    final sport = '${venue['sport'] ?? ''}'.trim();
    final court = '${booking['court_name'] ?? ''}'.trim();
    final date = DateTime.tryParse('${booking['date_schedule'] ?? ''}');
    final dateLabel = date == null
        ? 'Date not available'
        : '${date.day} ${_month(date.month)} ${date.year}';
    final time = '${booking['time_slot'] ?? ''}'.trim();
    final reference = '${booking['booking_ref'] ?? '—'}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.sports_tennis_rounded,
              color: AppColors.primary,
              size: 29,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [sport, court].where((value) => value.isNotEmpty).join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  venueName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$dateLabel${time.isEmpty ? '' : ' • $time'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
                const SizedBox(height: 5),
                Text(
                  'Booking ref: $reference',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _month(int month) => const [
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
  ][month - 1];
  Widget _buildOverallExperience() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR RATING',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How was ${widget.booking?['court_name'] ?? 'your court'}?',
            style: const TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _rating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppColors.primary, size: 6),
                const SizedBox(width: 6),
                Text(
                  '$_rating.0 / 5.0',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '• ${_ratingText[_rating]}',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Your Match Review',
              style: TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'PUBLIC FEEDBACK',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: softBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _comment,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: ink, fontSize: 12, height: 1.4),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell other athletes about the court, lighting, facilities…',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Text(
                    '${_comment.text.length} / 500 characters',
                    style: const TextStyle(color: muted, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: const Icon(Icons.stars, size: 18),
            label: const Text(
              'Submit Review',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: const Color(0x400D6EFD),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your feedback helps 4,200+ Colombo athletes choose\nthe best courts.',
          style: TextStyle(color: muted, fontSize: 9, height: 1.3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.verified_user_outlined, color: muted, size: 10),
            SizedBox(width: 4),
            Text(
              'COLOMBO SPORTS AUTHORITY QUALITY CONTROL OS V2.4.0',
              style: TextStyle(
                color: muted,
                fontSize: 7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
