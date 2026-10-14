import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../booking/booking_flow/booking_step1_screen.dart';import '../booking/booking_flow/booking_flow_popup.dart';

import '../../core/toast.dart';
import '../../core/actions.dart';
import '../../core/supabase_service.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({super.key, required this.venue});
  
  final Map<String, dynamic> venue;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F3FF);

  final _service = SupabaseService();
  bool _favorite = false;

  String get _venueName => '${widget.venue['name'] ?? 'this venue'}';
  String get _venueAddress => '${widget.venue['address'] ?? widget.venue['area'] ?? ''}'.trim();
  String get _venueQuery => [widget.venue['name'], widget.venue['address'] ?? widget.venue['area']].where((e) => e != null && '$e'.isNotEmpty).join(', ');

  @override
  void initState() {
    super.initState();
    final id = widget.venue['id'] as String?;
    if (id != null) {
      _service.isFavorite(id).then((v) {
        if (mounted) setState(() => _favorite = v);
      }).catchError((_) {});
    }
  }

  Future<void> _toggleFavorite() async {
    final id = widget.venue['id'] as String?;
    if (id == null) return;
    try {
      final now = await _service.toggleFavorite(id);
      if (mounted) setState(() => _favorite = now);
      toast(now ? 'Saved to your favourites' : 'Removed from favourites');
    } catch (e) {
      toast('Could not update favourites: $e');
    }
  }

  void _book() => showBookingStepPopup(context, BookingStep1Screen(venue: widget.venue));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  _buildImageBanner(),
                  _buildTitleCard(),
                  _buildAvailableDisciplines(),
                  _buildOpenStatus(),
                  _buildLocationCard(),
                  _buildLiveCourtAvailability(),
                  _buildArenaAmenities(),
                  _buildVenueGuidelines(),
                  _buildFooterProfile(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomFixedBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPORTSBOOK', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                Text('Venue Detail', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(onPressed: _toggleFavorite, icon: Icon(_favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _favorite ? AppColors.primary : _ink)),
          IconButton(onPressed: () => shareText('Check out $_venueName on SportsBook${_venueAddress.isEmpty ? '' : ' - $_venueAddress'}.'), icon: const Icon(Icons.share_outlined, color: _ink)),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=User&background=0D8ABC&color=fff'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBanner() {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Image.network(
            'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=900&q=80',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.primary),
                SizedBox(width: 4),
                Text('INDOOR & OUTDOOR', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_outlined, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text('1/6 Photos', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.grid_view_rounded, size: 12, color: AppColors.primary),
                SizedBox(width: 4),
                Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Row(
            children: [
              Container(width: 16, height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleCard() {
    final name = widget.venue['name'] ?? 'CSA National Arena';
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE6EEFF), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: const [
                    Icon(Icons.verified, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Verified\nFacility', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF0F8FF), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: const [
                    Icon(Icons.flash_on_rounded, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Fast\nConfirmation', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.star_rounded, color: Color(0xFFFFB020), size: 16),
                        SizedBox(width: 4),
                        Text('4.8', style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
                        SizedBox(width: 4),
                        Text('(184\nreviews)', style: TextStyle(color: _muted, fontSize: 10)),
                        SizedBox(width: 12),
                        Text('•', style: TextStyle(color: _muted)),
                        SizedBox(width: 12),
                        Text('Colombo\n07', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('RATE', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
                  Text('LKR 1,500', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('/ hour', style: TextStyle(color: _muted, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableDisciplines() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('AVAILABLE DISCIPLINES', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
              Text('4 Sports Configured', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _disciplineChip('Badminton(4)', Icons.sports_tennis_rounded, true),
                _disciplineChip('Tennis(2)', Icons.sports_tennis_rounded, false),
                _disciplineChip('Table Tennis', Icons.sports_tennis_rounded, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disciplineChip(String label, IconData icon, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: active ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: active ? Colors.white : _ink),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: active ? Colors.white : _ink, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOpenStatus() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('Open\nNow', style: TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text('• Closes at\n  11:00 PM', style: TextStyle(color: _muted, fontSize: 11)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Moderate\ntraffic', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFF), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Mon - Fri', style: TextStyle(color: _muted, fontSize: 11)),
                      SizedBox(height: 4),
                      Text('06:00 AM -\n11:00 PM', style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFF), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Sat - Sun', style: TextStyle(color: _muted, fontSize: 11)),
                      SizedBox(height: 4),
                      Text('06:00 AM -\n11:30 PM', style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFE9EEFF), shape: BoxShape.circle),
                child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_venueAddress.isEmpty ? 'Address not provided' : _venueAddress, style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('${widget.venue['area'] ?? ''}', style: const TextStyle(color: _muted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFD3E1FF), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sports_tennis_rounded, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text(_venueName.toUpperCase(), style: const TextStyle(color: _ink, fontSize: 8, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => openDirections(_venueQuery),
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Get Directions'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE9EEFF),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(64, 48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => copyText(_venueAddress.isEmpty ? _venueName : '$_venueName, $_venueAddress', message: 'Address copied'),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: _ink,
                  elevation: 0,
                  minimumSize: const Size(64, 48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCourtAvailability() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Court Availability', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('Instant booking with active nodes', style: TextStyle(color: _muted, fontSize: 10)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE9EEFF), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('Today, Oct 24', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _courtRow('Court 1', 'BWF Approved', 'Indoor Wooden Parquet • 5x blocks booked', 'LKR 2,000', 'Next Slot: 4:00 PM', true),
          _courtRow('Court 2', 'Synthetic Pro Mat', 'Non-Slip Cushion Matting', 'LKR 1,800', 'Next Slot: 4:30 PM', true),
          _courtRow('Court 3', 'Ready', 'Indoor Teak Wood • Climate Controlled', 'LKR 2,000', 'Available Now', true, isAvailableNow: true),
          _courtRow('Tennis Court A', 'Floodlit', 'US Open Pro Hard Court', 'LKR 3,000', 'Next Slot: 6:00 PM', true),
          _courtRow('Tennis Court B', 'Clay', 'Red Clay Outdoor Court', 'LKR 3,000', 'Booked until 7:30 PM', false),
        ],
      ),
    );
  }

  Widget _courtRow(String name, String tag, String desc, String price, String statusText, bool canBook, {bool isAvailableNow = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE9EEFF), borderRadius: BorderRadius.circular(8)),
                          child: Text(tag, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(color: _muted, fontSize: 10)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                  const Text('/hr', style: TextStyle(color: _muted, fontSize: 9)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isAvailableNow ? Icons.check_circle_outline : (canBook ? Icons.access_time_rounded : Icons.schedule_rounded), size: 14, color: isAvailableNow || canBook ? AppColors.primary : _muted),
                  const SizedBox(width: 6),
                  Text(statusText, style: TextStyle(color: isAvailableNow || canBook ? AppColors.primary : _muted, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              FilledButton(
                onPressed: canBook ? _book : null,
                style: FilledButton.styleFrom(
                  backgroundColor: canBook ? AppColors.primary : const Color(0xFFE5E7EB),
                  foregroundColor: canBook ? Colors.white : _ink,
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(canBook ? 'Book Slot' : 'Notify Me'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArenaAmenities() {
    final amenities = [
      {'icon': Icons.ac_unit_rounded, 'title': 'Air\nConditioned', 'desc': 'Indoor Arena'},
      {'icon': Icons.lightbulb_outline_rounded, 'title': 'LED\nFloodlights', 'desc': 'Tournament grade'},
      {'icon': Icons.local_parking_rounded, 'title': 'Free Parking', 'desc': '60+ secure spots'},
      {'icon': Icons.shower_rounded, 'title': 'Hot Showers', 'desc': 'Lockers & usage'},
      {'icon': Icons.shopping_bag_outlined, 'title': 'Pro Shop', 'desc': 'Rackets & gear rent'},
      {'icon': Icons.weekend_outlined, 'title': 'Player Lounge', 'desc': 'Hydro vendor'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Arena Amenities', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final item = amenities[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(8)),
                      child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item['title'] as String, style: const TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w800, height: 1.1)),
                          const SizedBox(height: 2),
                          Text(item['desc'] as String, style: const TextStyle(color: _muted, fontSize: 8)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVenueGuidelines() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 16, color: _ink),
              SizedBox(width: 8),
              Text('Venue Guidelines & Rules', style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          _bullet('Non-marking shoes strictly mandatory on indoor wooden & synthetic courts. Shoe rentals available at the pro shop for LKR 300.'),
          _bullet('Arrive at least 10 minutes prior to your reserved slot for court orientation and keycard access.'),
          _bullet('Maximum 6 players per court at any given hour.'),
          _bullet('Free cancellation up to 2 hours before the start of scheduled booking time.'),
          _bullet('Outside food prohibited; sealed energy beverages and water bottles permitted.'),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 4, right: 8), child: Icon(Icons.circle, size: 4, color: AppColors.primary)),
          Expanded(child: Text(text, style: const TextStyle(color: _muted, fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildFooterProfile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Center(child: Text('CSA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Colombo Sports Association', style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('Facility Admin • Responds in ~5 mins', style: TextStyle(color: _muted, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFE9EEFF), shape: BoxShape.circle),
            child: const Icon(Icons.message_rounded, color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFixedBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STARTING FROM', style: TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w800)),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'LKR ', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                    TextSpan(text: '1,500', style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w800)),
                    TextSpan(text: ' / hr', style: TextStyle(color: _muted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                showBookingStepPopup(context, BookingStep1Screen(venue: widget.venue));
              },
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('Book Court Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
