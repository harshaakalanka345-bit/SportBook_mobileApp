import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  
  String selectedIncident = 'Lighting / Floodlights';
  String urgencyLevel = 'Active Game Halted';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.sports_baseball, color: Colors.white, size: 14), // Using sports icon as logo approximation
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Sportsbook Help & Support / Report',
                style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.flag_outlined, color: muted, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: muted, size: 20), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildHotlineCard(),
          const SizedBox(height: 12),
          _buildQuickContacts(),
          const SizedBox(height: 24),
          _buildReportFaultPanel(),
          const SizedBox(height: 32),
          _buildFAQHeader(),
          const SizedBox(height: 16),
          _buildFAQItem('Court Cancellations & Refund Policy', Icons.event_busy_outlined),
          const SizedBox(height: 8),
          _buildFAQItem('Non-Marking Shoe Requirements', Icons.do_not_step_outlined),
          const SizedBox(height: 8),
          _buildFAQItem('Split Payment with Teammates', Icons.people_outline),
          const SizedBox(height: 8),
          _buildFAQItem('Bad Weather & Outdoor Rain Guarantee', Icons.thunderstorm_outlined),
          const SizedBox(height: 8),
          _buildFAQItem('Digital Match Pass & Gate Scanners', Icons.qr_code_scanner_rounded),
          const SizedBox(height: 24),
          _buildSuggestVenueCard(),
          const SizedBox(height: 40),
          _buildFooter(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search issues, court rules, refund policy',
          hintStyle: const TextStyle(color: muted, fontSize: 12),
          prefixIcon: const Icon(Icons.search, color: muted, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHotlineCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5EDFF), Color(0xFFD0DDFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text('24/7 COURT OPS\nHOTLINE', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, height: 1.1)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Need\nimmediate\nlights or gate\naccess?', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1)),
                      const SizedBox(height: 6),
                      const Text('Direct tie-in to CSA\nVenue Manager Desk', style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, size: 14),
                label: const Text('Call Now', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Colombo Arena Central Desk', style: TextStyle(color: muted, fontSize: 9)),
              Text('+94 11 269 5555', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContacts() {
    return Row(
      children: [
        Expanded(child: _contactCard(Icons.support_agent_rounded, 'Chat Marshal', '< 2 min resp.', const Color(0xFF0D6EFD))),
        const SizedBox(width: 8),
        Expanded(child: _contactCard(Icons.chat_bubble_outline_rounded, 'WhatsApp', 'Player Line', ink)),
        const SizedBox(width: 8),
        Expanded(child: _contactCard(Icons.email_outlined, 'Email Us', 'Formal\ninquiries', ink)),
      ],
    );
  }

  Widget _contactCard(IconData icon, String title, String subtitle, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 9, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildReportFaultPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Report Court or Venue Fault', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Spotted a broken net, slippery floor,\nfloodlight outage, or gate failure? Arena\nmarshals dispatch instantly.', style: TextStyle(color: muted, fontSize: 9, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('CURRENT MATCH VENUE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.stadium_outlined, color: AppColors.primary, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('CSA Arena - Court 1 (Badminton)', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text("Today's Match Slot: #SB-COL-3941", style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: muted, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('SELECT INCIDENT TYPE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
              Text('Tap to select', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _incidentChip('Lighting / Floodlights', Icons.bolt),
              _incidentChip('Net / Floor Hazard', Icons.sports_tennis),
              _incidentChip('Ventilation / A/C', Icons.ac_unit),
              _incidentChip('Turnstile Gate Barrier', Icons.door_front_door_outlined),
              _incidentChip('Locker & Shower', Icons.shower_outlined),
            ],
          ),
          const SizedBox(height: 20),
          const Text('URGENCY LEVEL', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => urgencyLevel = 'Active Game Halted'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: urgencyLevel == 'Active Game Halted' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: urgencyLevel == 'Active Game Halted' ? [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 6, color: urgencyLevel == 'Active Game Halted' ? const Color(0xFFDC2626) : Colors.transparent),
                          const SizedBox(width: 6),
                          Text('Active Game\nHalted', style: TextStyle(color: urgencyLevel == 'Active Game Halted' ? const Color(0xFF0D6EFD) : muted, fontSize: 10, fontWeight: FontWeight.w700, height: 1.1), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => urgencyLevel = 'General Maintenance'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: urgencyLevel == 'General Maintenance' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: urgencyLevel == 'General Maintenance' ? [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))] : null,
                      ),
                      child: Text('General\nMaintenance', style: TextStyle(color: urgencyLevel == 'General Maintenance' ? ink : muted, fontSize: 10, fontWeight: FontWeight.w600, height: 1.1), textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('VISUAL EVIDENCE (OPTIONAL)', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 16),
                ),
                const SizedBox(height: 12),
                const Text('+ Add Photo of Court Issue', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                const Text('Helps floor marshals bring proper gear', style: TextStyle(color: muted, fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Submit Report to Arena Manager', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_outline, color: AppColors.primary, size: 12),
                  SizedBox(width: 6),
                  Text('#CSA-102 (Turnstile B)', style: TextStyle(color: muted, fontSize: 9)),
                  SizedBox(width: 8),
                  Text('Resolved 4:15 PM', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _incidentChip(String label, IconData icon) {
    bool active = selectedIncident == label;
    return GestureDetector(
      onTap: () => setState(() => selectedIncident = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0D6EFD) : softBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: active ? Colors.white : ink),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: active ? Colors.white : ink, fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Frequently Asked\nQuestions', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800, height: 1.1)),
        Text('Rules &\nHelp', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.right),
      ],
    );
  }

  Widget _buildFAQItem(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 18),
        title: Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.keyboard_arrow_down, color: muted, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildSuggestVenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Suggest a New Venue in Colombo', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Know a court, pitch, or swimming pool we\nshould onboard?', style: TextStyle(color: muted, fontSize: 9, height: 1.2)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: muted, size: 16),
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
            Text('Colombo Sports Authority (CSA)', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        const Text('SportsBook Help Center â€¢ Version 2.4.0 (Build 891)', style: TextStyle(color: muted, fontSize: 8)),
        const SizedBox(height: 4),
        const Text('Authorized real-time venue telemetry & court\ncompliance', style: TextStyle(color: muted, fontSize: 8, height: 1.2), textAlign: TextAlign.center),
      ],
    );
  }
}
