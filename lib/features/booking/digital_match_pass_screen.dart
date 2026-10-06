import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class DigitalMatchPassScreen extends StatelessWidget {
  const DigitalMatchPassScreen({super.key, required this.bookingRef});

  final String bookingRef;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Digital Match\nPass', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: ink), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: ink), onPressed: () {}),
          Container(
            margin: const EdgeInsets.only(right: 16, left: 4),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 16),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _buildSecurityToken(),
            const SizedBox(height: 16),
            _buildMatchPassCard(),
            const SizedBox(height: 16),
            _buildChecklist(),
            const SizedBox(height: 16),
            _buildRoster(),
            const SizedBox(height: 16),
            _buildNavigationCard(),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityToken() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.circle, size: 10, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('LIVE SECURITY TOKEN', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                ],
              ),
              Row(
                children: const [
                  Text('REFRESHES IN ', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
                  Text('27s', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.light_mode_outlined, size: 14, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Turn up screen brightness at Gate B turnstile\nscanner.', style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchPassCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE9EEFF)), boxShadow: [BoxShadow(color: const Color(0x0A000000), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('OFFICIAL MATCH PASS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Row(children: const [Icon(Icons.verified_outlined, size: 12, color: Colors.white), SizedBox(width: 4), Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))])),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('CSA National Arena', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                    SizedBox(width: 4),
                    Text('Maitland Place, Colombo 07', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('SPORT & COURT', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800)),
                          Text('Badminton â€¢ Court 1', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                          Text('Indoor Wooden Parquet', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('BOOKING REF', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800)),
                        Text(bookingRef, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('DATE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('Thu, 24 Oct 2024', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('TIME SLOT', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('06:00 PM - 08:00 PM', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('2 Hours Duration', style: TextStyle(color: muted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('TURNSTILE GATE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('Gate B (South\nEntrance)', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('LEAD HOST', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('Kasun Perera', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('4 Players Confirmed', style: TextStyle(color: AppColors.primary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const Divider(color: Color(0xFFE9EEFF), height: 1, thickness: 1, indent: 20, endIndent: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 16, height: 32, decoration: const BoxDecoration(color: Color(0xFFFAF8FF), borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)))),
                  Container(width: 16, height: 32, decoration: const BoxDecoration(color: Color(0xFFFAF8FF), borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: softBlue.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.qr_code_2_rounded, size: 160, color: ink)),
                      // Frame corners
                      Positioned(top: 0, left: 0, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.primary, width: 2), left: BorderSide(color: AppColors.primary, width: 2))))),
                      Positioned(top: 0, right: 0, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.primary, width: 2), right: BorderSide(color: AppColors.primary, width: 2))))),
                      Positioned(bottom: 0, left: 0, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.primary, width: 2), left: BorderSide(color: AppColors.primary, width: 2))))),
                      Positioned(bottom: 0, right: 0, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.primary, width: 2), right: BorderSide(color: AppColors.primary, width: 2))))),
                      Center(child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Center(child: Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 20)))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('MANUAL TURNSTILE PIN:  ', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('8492', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      SizedBox(width: 8),
                      Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Hold QR code 10cm above turnstile scanner\nat Gate B, or show code to court marshal.', style: TextStyle(color: muted, fontSize: 10, height: 1.4), textAlign: TextAlign.center),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFFF0F2FF), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('Kinetic Turnstile Pass', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
                Text('SESSION #8941-K', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.checklist_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Court Access Checklist', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('Requirements for seamless venue entry', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _checklistItem(Icons.do_not_step_outlined, 'Non-marking footwear mandatory', 'Parquet courts require clean indoor rubber gum soles.'),
          const SizedBox(height: 12),
          _checklistItem(Icons.lock_outline_rounded, 'Lockers #14 & #15 Assigned', 'Electronic keyless access code matches your Entry PIN (8492).', highlight: '8492'),
          const SizedBox(height: 12),
          _checklistItem(Icons.water_drop_outlined, 'Hydration & Towels Included', 'Collect 2x microfibre towels & electrolyte refills at reception desk.'),
        ],
      ),
    );
  }

  Widget _checklistItem(IconData icon, String title, String desc, {String? highlight}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                if (highlight != null)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: desc.split(highlight)[0], style: const TextStyle(color: muted, fontSize: 10, height: 1.3)),
                        TextSpan(text: highlight, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, height: 1.3)),
                        TextSpan(text: desc.split(highlight)[1], style: const TextStyle(color: muted, fontSize: 10, height: 1.3)),
                      ],
                    ),
                  )
                else
                  Text(desc, style: const TextStyle(color: muted, fontSize: 10, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoster() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.group_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Roster Invites (3 of 4 Ready)', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: const Text('Full Court', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _rosterItem('KP', 'Kasun\n(You)', true),
              const SizedBox(width: 12),
              _rosterItem('DK', 'Dimuth', false),
              const SizedBox(width: 12),
              _rosterItem('SM', 'Sahan', false),
              const SizedBox(width: 12),
              _rosterItem('NR', 'Nuwan\n(Pending)', false, pending: true),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.share_outlined, size: 14, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Dispatch Match Pass to Team WhatsApp', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rosterItem(String initials, String name, bool active, {bool pending = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: pending ? const Color(0xFFF4F4F6) : softBlue, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 16, height: 16, decoration: BoxDecoration(color: pending ? muted : AppColors.primary, shape: BoxShape.circle), alignment: Alignment.center, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800))),
            const SizedBox(width: 4),
            Text(name, style: TextStyle(color: ink, fontSize: 10, fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.navigation_rounded, size: 20, color: AppColors.primary)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Navigate to Arena Turnstiles', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('0.8 km â€¢ 4 min drive via Maitland\nCrescent', style: TextStyle(color: muted, fontSize: 10, height: 1.3)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: muted),
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
            Icon(Icons.support_agent_rounded, size: 14, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Need entry help? Call Arena Desk (Maitland Place)', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('COLOMBO SPORTS AUTHORITY\PARTNER', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.circle, size: 4, color: muted)),
            Text('KINETIC ACCESS\nV2.4', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          ],
        ),
      ],
    );
  }
}
