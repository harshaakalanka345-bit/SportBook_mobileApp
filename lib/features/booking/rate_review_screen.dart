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
  
  bool _publishAsVerified = true;
  int _rating = 0;
  bool _submitting = false;
  final _service = SupabaseService();
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  static const _ratingText = ['Tap a star to rate', 'Poor', 'Fair', 'Good', 'Great', 'Outstanding Experience!'];

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
  
  final List<String> _selectedHighlights = [
    'Clean parquet floor',
    'Great LED lighting',
    'Spacious lockers',
    'Clear line markings',
    'Fast turnstile QR',
    'Ample car parking'
  ];
  
  final List<String> _unselectedHighlights = [
    'Slippery mat',
    'AC too cold'
  ];

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
        title: const Text('Rate & Review', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // padding for bottom button
            children: [
              _buildVerifiedBanner(),
              const SizedBox(height: 16),
              _buildBookingCard(),
              const SizedBox(height: 24),
              _buildOverallExperience(),
              const SizedBox(height: 24),
              _buildFacilitySpecifics(),
              const SizedBox(height: 24),
              _buildHighlights(),
              const SizedBox(height: 24),
              _buildMatchReview(),
              const SizedBox(height: 24),
              _buildPhotos(),
              const SizedBox(height: 24),
              _buildPublishToggle(),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: const [
              Icon(Icons.verified, color: AppColors.primary, size: 12),
              SizedBox(width: 4),
              Text('VERIFIED MATCH BOOKING', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle),
          child: const Icon(Icons.close, color: muted, size: 14),
        ),
      ],
    );
  }

  Widget _buildBookingCard() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?q=80&w=200&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                child: const Text('COURT 1', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.circle, color: AppColors.primary, size: 6),
                  SizedBox(width: 4),
                  Text('BADMINTON • TEAK COURT', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('CSA National Arena', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Row(
                children: const [
                  Icon(Icons.access_time, color: muted, size: 10),
                  SizedBox(width: 4),
                  Text('Today, 24 Oct • 06:00 – 08:00 PM', style: TextStyle(color: muted, fontSize: 9)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(4)),
                child: const Text('REF: #SB-COL-2024-8941', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverallExperience() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text('OVERALL MATCH EXPERIENCE', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('How was ${widget.booking?['court_name'] ?? 'your court'}?', style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => InkWell(
              customBorder: const CircleBorder(),
              onTap: () => setState(() => _rating = index + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(index < _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.primary, size: 36),
              ),
            )),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppColors.primary, size: 6),
                const SizedBox(width: 6),
                Text('$_rating.0 / 5.0', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Text('• ${_ratingText[_rating]}', style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitySpecifics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Court & Facility Specifics', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('DETAILED SCORE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        _buildScoreRow(Icons.layers_outlined, 'Court Surface Quality', 'Teak timber grip & tension', '5.0'),
        const SizedBox(height: 8),
        _buildScoreRow(Icons.lightbulb_outline, 'Lighting & Anti-Glare', 'Smash trajectory visibility', '5.0'),
        const SizedBox(height: 8),
        _buildScoreRow(Icons.people_outline, 'Staff & Amenities', 'Restrooms & marshals', '5.0'),
      ],
    );
  }

  Widget _buildScoreRow(IconData icon, String title, String subtitle, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFD0DDFB), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: muted, fontSize: 9)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(score, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('What stood out most?', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('Select highlights', style: TextStyle(color: muted, fontSize: 9)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedHighlights.map((h) => _buildChip(h, true)),
            ..._unselectedHighlights.map((h) => _buildChip(h, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0D6EFD) : softBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? Icons.check : Icons.add, color: isSelected ? Colors.white : muted, size: 12),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : ink, fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600)),
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
            Text('Your Match Review', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('PUBLIC FEEDBACK', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _comment,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: ink, fontSize: 12, height: 1.4),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Tell other athletes about the court, lighting, facilities…', counterText: ''),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Text('${_comment.text.length} / 500 characters', style: const TextStyle(color: muted, fontSize: 9)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Court Evidence & Photos', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('2 ATTACHED', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Show surface grip condition, net tension, or lighting\nfixtures to fellow players.', style: TextStyle(color: muted, fontSize: 9, height: 1.3)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPhotoItem('court1.jpg', 'https://images.unsplash.com/photo-1599839619722-39751411ea63?q=80&w=200&auto=format&fit=crop'),
            const SizedBox(width: 12),
            _buildPhotoItem('gate_qr.jpg', 'https://images.unsplash.com/photo-1629858332997-6019b7d15a51?q=80&w=200&auto=format&fit=crop'),
            const SizedBox(width: 12),
            _buildAddPhotoBtn(),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String filename, String url) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 10),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
              child: Text(filename, style: const TextStyle(color: Colors.white, fontSize: 6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoBtn() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 14),
          ),
          const SizedBox(height: 4),
          const Text('Add Photo', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w700)),
          const Text('Max 10MB', style: TextStyle(color: muted, fontSize: 7)),
        ],
      ),
    );
  }

  Widget _buildPublishToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: softBlue),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Center(child: Text('KP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Publish as Verified Kasun P.', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Boosts your Colombo Athlete Trust Score', style: TextStyle(color: muted, fontSize: 9)),
              ],
            ),
          ),
          Switch(
            value: _publishAsVerified,
            onChanged: (val) => setState(() => _publishAsVerified = val),
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
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
            label: const Text('Submit Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
            Text('COLOMBO SPORTS AUTHORITY QUALITY CONTROL OS V2.4.0', style: TextStyle(color: muted, fontSize: 7, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
