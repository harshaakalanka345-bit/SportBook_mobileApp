import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'filter_screen.dart';
import '../auth/profile_screen.dart';
import '../notifications/notifications_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.search, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            const Text('Search', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: ink),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FilterScreen())),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: ink),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
              Positioned(top: 12, right: 12, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 16),
          _buildAppliedCriteria(),
          const SizedBox(height: 20),
          _buildRadarCard(),
          const SizedBox(height: 24),
          _buildConstructiveRecovery(),
          const SizedBox(height: 24),
          _buildNearbyArenas(),
          const SizedBox(height: 32),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Push to the new Filter Screen (the old Search UI)
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FilterScreen()));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: ink, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('EDGE-CASE RECOVERY UI', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
              Text('Search & Activity\nStatus', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.2)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: const [
              Icon(Icons.circle, color: AppColors.primary, size: 6),
              SizedBox(width: 4),
              Text('Interactive', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_off_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('No Courts', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_today_outlined, color: muted, size: 14),
                SizedBox(width: 4),
                Text('Bookings', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.wifi_off_rounded, color: muted, size: 14),
                SizedBox(width: 4),
                Text('Offline', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedCriteria() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.tune, color: muted, size: 12),
                  SizedBox(width: 6),
                  Text('APPLIED CRITERIA', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                ],
              ),
              Text('Clear All Filters', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('Badminton', Icons.person_outline),
              _filterChip('Colombo 07', Icons.location_on_outlined),
              _filterChip('After 22:00', Icons.access_time),
              _filterChip('< 1.0 km', Icons.radar_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRadarCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: softBlue, width: 1))),
              Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: softBlue, width: 1))),
              Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: softBlue, width: 1))),
              const Icon(Icons.linear_scale, color: AppColors.primary, size: 32),
              Positioned(
                top: 10,
                right: 20,
                child: Column(
                  children: [
                    Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: ink, borderRadius: BorderRadius.all(Radius.circular(4))), child: const Text('FUL', style: TextStyle(color: Colors.white, fontSize: 6))),
                    const Icon(Icons.circle, color: Colors.redAccent, size: 8),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 10,
                child: Column(
                  children: [
                    Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: ink, borderRadius: BorderRadius.all(Radius.circular(4))), child: const Text('FUL', style: TextStyle(color: Colors.white, fontSize: 6))),
                    const Icon(Icons.circle, color: Colors.redAccent, size: 8),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                  child: const Icon(Icons.block, color: Colors.white, size: 16),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Text('No Courts in Colombo 07', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'We couldn\'t find any open badminton slots\nmatching your exact filter (22:00-24:00,\n<1km). Night shifts at Sugathadasa &\nTorrington are locked.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Reset Filters & Show All Courts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstructiveRecovery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Constructive Recovery', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
            Text('3 SMART OPTIONS', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecoveryCard(
          icon: Icons.track_changes_outlined,
          title: 'Broaden Radius to 5.0 km',
          badge: '6 Open',
          desc: 'CSA Badminton Arena & Royal Sports\nComplex have premium synthetic courts...',
          actionWidget: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.location_on_outlined, size: 14),
              label: const Text('Quick Apply (5km Radius)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildRecoveryCard(
          icon: Icons.notifications_active_outlined,
          title: 'Notify on Cancellation',
          badge: 'Avg 8 min ping',
          desc: 'Activate an immediate WhatsApp & Push\nping if another player reschedules their\nColombo 07 slot tonight.',
          actionWidget: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 12),
                  SizedBox(width: 4),
                  Text('Send to +94 77 **** 924', style: TextStyle(color: muted, fontSize: 10)),
                ],
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.notifications_active_outlined, size: 12, color: ink),
                label: const Text('Notify Me', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: softBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildRecoveryCard(
          icon: Icons.search_rounded,
          title: 'Alternate Sports Available',
          badge: 'Tonight',
          desc: 'Squash and Tennis courts within Colombo\n07 are unreserved at 21:30 and 22:15.',
          actionWidget: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Squash (2 slots)', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Tennis (4 slots)', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryCard({required IconData icon, required String title, required String badge, required String desc, required Widget actionWidget}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle),
                child: Icon(icon, color: ink, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                          child: Text(badge, style: const TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(color: muted, fontSize: 9, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          actionWidget,
        ],
      ),
    );
  }

  Widget _buildNearbyArenas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Verified Nearby Arenas', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
            Text('Available Tomorrow', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _arenaCard('Torrington Indoor', 'From LKR 1,800/hr', '1.8 km')),
            const SizedBox(width: 12),
            Expanded(child: _arenaCard('Royal Sports Arena', 'From LKR 2,400/hr', '2.4 km')),
          ],
        ),
      ],
    );
  }

  Widget _arenaCard(String title, String price, String distance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(child: Icon(Icons.image_outlined, color: muted, size: 24)),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text(distance, style: const TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(price, style: const TextStyle(color: muted, fontSize: 9)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.primary, size: 12),
                        Text('Instant', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Icon(Icons.arrow_forward, color: muted, size: 12),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 12),
            SizedBox(width: 4),
            Text('OFFICIAL PARTNER OF COLOMBO SPORTS AUTHORITY', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        const Text('SportsBook OS v2.4.0 â€¢ High Reliability Network', style: TextStyle(color: muted, fontSize: 8)),
      ],
    );
  }
}
