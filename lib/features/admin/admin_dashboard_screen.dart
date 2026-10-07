import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'admin_profile_screen.dart';
import '../notifications/notifications_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildAppBar(),
            const SizedBox(height: 24),
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            _buildCourtRadar(),
            const SizedBox(height: 24),
            _buildAccessStream(),
            const SizedBox(height: 24),
            const Center(child: Text('© COLOMBO SPORTS AUTHORITY\nSportsBook Ops v2.4.0 • Floor Terminal UI', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 9, height: 1.4))),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('FLOOR OPS', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              Text('CSA Arena • Torrington', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: const [
              Icon(Icons.circle, color: AppColors.primary, size: 6),
              SizedBox(width: 4),
              Text('SYNCED', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Builder(
          builder: (ctx) => Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                icon: const Icon(Icons.notifications_none_rounded, color: ink, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.wifi, color: AppColors.primary, size: 12),
            SizedBox(width: 4),
            Text('GATE SYNC 14ms', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Welcome, Kasun', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Shift Active • Marshal', style: TextStyle(color: muted, fontSize: 11)),
              ],
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Fast Walk-In', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 32),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _metricCard('TODAY\'S TAKE', 'LKR 148.5K', Icons.trending_up, '+14%', true),
              const SizedBox(height: 8),
              _metricCard('GATE SCANS', '128', Icons.qr_code_scanner, 'Live Sync', false),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _metricCard('OCCUPANCY', '84%', Icons.people_outline, '14/16 Slots', false),
              const SizedBox(height: 8),
              _metricCard('HAZARDS', 'Pending', Icons.warning_amber_rounded, '2 Alerts', true, isDanger: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon, String badgeText, bool hasBadge, {bool isDanger = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: softBlue)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isDanger ? Colors.redAccent : AppColors.primary, size: 16),
              if (hasBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: isDanger ? const Color(0xFFFFE5E5) : softBlue, borderRadius: BorderRadius.circular(4)),
                  child: Text(badgeText, style: TextStyle(color: isDanger ? Colors.redAccent : AppColors.primary, fontSize: 8, fontWeight: FontWeight.w700)),
                )
              else
                Text(badgeText, style: const TextStyle(color: muted, fontSize: 8)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: isDanger ? Colors.redAccent : ink, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildCourtRadar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Court Radar', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
            Row(
              children: const [
                Text('(18:00 - 20:00)', style: TextStyle(color: muted, fontSize: 9)),
                SizedBox(width: 8),
                Text('• 18:42 LIVE', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(12)),
              child: const Text('Court 1 • Parquet (PRO)', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
              child: const Text('Court 2 • BWF Mat', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary, width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(4)),
                    child: const Text('COURT 1: ACTIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                  ),
                  const Text('Ref: #SB-COL-8941', style: TextStyle(color: muted, fontSize: 8)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('REMAINING', style: TextStyle(color: muted, fontSize: 7, fontWeight: FontWeight.w800)),
                      Text('38:11', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Kasun P. + 3 athletes', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color: AppColors.primary, size: 14),
                    SizedBox(width: 8),
                    Expanded(child: Text('All 4 athletes cleared turnstiles\nTurnstile #04 North Gate • Synchronized pass', style: TextStyle(color: muted, fontSize: 9))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.timer_outlined, size: 12),
                      label: const Text('Quick Extend\n(+ 30m)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, height: 1.1), textAlign: TextAlign.center),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.redAccent),
                      label: const Text('Emergency Halt', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _miniCourtStatus('Court 2', 'Checkout in progress • Buffer ...', '04m left', softBlue, ink),
        const SizedBox(height: 8),
        _miniCourtStatus('Court 3', 'Floor Buffing & Sanitize ...', 'MAINTENANCE', const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
        const SizedBox(height: 8),
        _miniCourtStatus('Court 4', 'Torn Net Sensor - Open ...', 'HOLD SLOT', const Color(0xFFE5EDFF), const Color(0xFF0D6EFD)),
      ],
    );
  }

  Widget _miniCourtStatus(String title, String desc, String badge, Color badgeBg, Color badgeFg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.primary, size: 6),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Expanded(child: Text(desc, style: const TextStyle(color: muted, fontSize: 9), overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
            child: Text(badge, style: TextStyle(color: badgeFg, fontSize: 8, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessStream() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Access Stream', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Live Log', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const Icon(Icons.filter_list, color: AppColors.primary, size: 16),
          ],
        ),
        const SizedBox(height: 12),
        _accessLogItem(Icons.sensor_door_outlined, 'Kasun P. (Athlete)', '1m', 'Turnstile #04 North • Pass Q...', 'CHECKED IN', const Color(0xFF0D6EFD)),
        const SizedBox(height: 8),
        _accessLogItem(Icons.group_outlined, 'Junior Clinic Squad (4p)', '3m', 'Gate A Main • Manual PIN #49...', 'PIN VERIFIED', ink),
        const SizedBox(height: 8),
        _accessLogItem(Icons.lock_outline, 'Smart Locker #14', '7m', 'Auto-paired to booking #8941', 'PAIRED', ink),
        const SizedBox(height: 8),
        _accessLogItem(Icons.warning_amber_rounded, 'Scan Rejected', '14m', 'Turnstile #02 South • Expired sl...', 'WARNING', Colors.redAccent, iconColor: Colors.redAccent),
      ],
    );
  }

  Widget _accessLogItem(IconData icon, String title, String time, String desc, String badge, Color badgeColor, {Color iconColor = AppColors.primary}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Icon(Icons.circle, color: muted, size: 3),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: muted, fontSize: 9)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: muted, fontSize: 9)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(color: badgeColor == Colors.redAccent ? const Color(0xFFFFE5E5) : softBlue, borderRadius: BorderRadius.circular(4)),
            child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
