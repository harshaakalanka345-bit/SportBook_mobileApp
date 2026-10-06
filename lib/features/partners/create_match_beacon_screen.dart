import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class CreateMatchBeaconScreen extends StatefulWidget {
  const CreateMatchBeaconScreen({super.key});

  @override
  State<CreateMatchBeaconScreen> createState() => _CreateMatchBeaconScreenState();
}

class _CreateMatchBeaconScreenState extends State<CreateMatchBeaconScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  String selectedSport = 'Badminton';
  String selectedFormat = 'Singles (1v1)';
  String selectedSkill = 'Intermediate';
  String selectedFee = '50 / 50 Split';
  String selectedStyle = 'Casual Rally / Practice';
  
  bool verifiedOnly = true;
  bool autoExpiry = true;
  bool whatsappAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, color: ink, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.circle, size: 6, color: AppColors.primary),
                SizedBox(width: 4),
                Text('BROADCAST MATCH BEACON', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
              ],
            ),
            const Text('Request Partner', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSportDiscipline(),
                  const SizedBox(height: 24),
                  _buildSkillLevel(),
                  const SizedBox(height: 24),
                  _buildVenueSlot(),
                  const SizedBox(height: 24),
                  _buildStyleFee(),
                  const SizedBox(height: 24),
                  _buildBroadcastPreferences(),
                ],
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 6, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('LIVE BEACON RADAR', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Text('420+ Active Now', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Create Match Beacon', style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Broadcast your court slot or open rally to verified\nathletes within 5km in Colombo 07.', style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
          child: Row(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.podcasts_rounded, size: 16, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Estimated Reach', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                    Text('420+ athletes matching rank', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              Row(
                children: [
                  _avatarStackItem('https://ui-avatars.com/api/?name=J&background=0D8ABC&color=fff', 0),
                  _avatarStackItem('https://ui-avatars.com/api/?name=S&background=10B981&color=fff', 1),
                  _avatarStackItem('https://ui-avatars.com/api/?name=M&background=F59E0B&color=fff', 2),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarStackItem(String url, int index) {
    return Transform.translate(
      offset: Offset(index * -8.0, 0),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildSportDiscipline() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('SELECT SPORT DISCIPLINE', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
            Text('Step 1 of 4', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _sportCard('Badminton', Icons.sports_tennis_rounded, selectedSport == 'Badminton')),
            const SizedBox(width: 8),
            Expanded(child: _sportCard('Tennis', Icons.sports_baseball_outlined, selectedSport == 'Tennis')),
            const SizedBox(width: 8),
            Expanded(child: _sportCard('Squash', Icons.directions_run_rounded, selectedSport == 'Squash')),
            const SizedBox(width: 8),
            Expanded(child: _sportCard('Padel', Icons.sports_tennis_outlined, selectedSport == 'Padel')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _formatChip('Singles\n(1v1)', Icons.person_outline)),
            const SizedBox(width: 8),
            Expanded(child: _formatChip('Doubles\n(2v2)', Icons.people_outline)),
            const SizedBox(width: 8),
            Expanded(child: _formatChip('Any\nFormat', null)),
          ],
        ),
      ],
    );
  }

  Widget _sportCard(String title, IconData icon, bool active) {
    return GestureDetector(
      onTap: () => setState(() => selectedSport = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: active ? null : Border.all(color: const Color(0xFFE9EEFF))),
        child: Column(
          children: [
            Icon(icon, size: 20, color: active ? Colors.white : ink),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: active ? Colors.white : ink, fontSize: 10, fontWeight: FontWeight.w700)),
            if (active) ...[
              const SizedBox(height: 4),
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 12),
            ]
          ],
        ),
      ),
    );
  }

  Widget _formatChip(String title, IconData? icon) {
    bool active = selectedFormat == title.replaceAll('\n', ' ');
    return GestureDetector(
      onTap: () => setState(() => selectedFormat = title.replaceAll('\n', ' ')),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: active ? const Color(0xFF3B82F6) : Colors.white, borderRadius: BorderRadius.circular(20), border: active ? null : Border.all(color: const Color(0xFFE9EEFF))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: active ? Colors.white : muted),
              const SizedBox(width: 4),
            ],
            Text(title, style: TextStyle(color: active ? Colors.white : ink, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('REQUIRED SKILL LEVEL', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
        const Text('Only players matching this rank will receive push\nbroadcasts', style: TextStyle(color: muted, fontSize: 10)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skillCard('Beginner', '1.0 - 2.5', 'Rallies & basics')),
            const SizedBox(width: 12),
            Expanded(child: _skillCard('Intermediate', '3.0 - 4.0', 'Consistent paced rally')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skillCard('Advanced', '4.5+', 'High agility & smash')),
            const SizedBox(width: 12),
            Expanded(child: _skillCard('All Welcome', '', 'Social & fun first', isGlobal: true)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle), child: const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Verified Athletes Only', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('90%+ attendance rating mandatory', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              CupertinoSwitch(value: verifiedOnly, activeColor: AppColors.primary, onChanged: (v) => setState(() => verifiedOnly = v)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skillCard(String title, String rating, String desc, {bool isGlobal = false}) {
    bool active = selectedSkill == title;
    return GestureDetector(
      onTap: () => setState(() => selectedSkill = title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: active ? const Color(0xFF0D6EFD) : Colors.white, borderRadius: BorderRadius.circular(12), border: active ? null : Border.all(color: const Color(0xFFE9EEFF))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: active ? Colors.white : ink, fontSize: 11, fontWeight: FontWeight.w800)),
                if (active)
                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 12)
                else if (isGlobal)
                  const Icon(Icons.public, color: AppColors.primary, size: 12)
                else
                  Text(rating, style: TextStyle(color: muted, fontSize: 9)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(desc, style: TextStyle(color: active ? Colors.white70 : muted, fontSize: 9)),
                if (active && rating.isNotEmpty)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(rating, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueSlot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VENUE & TIME SLOT', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.stadium_outlined, color: AppColors.primary, size: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('CSA National Arena', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                        Text('Maitland Place, Colombo 07 â€¢ C', style: TextStyle(color: muted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: const Text('Change', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('BOOKED: #SB-COL-2024', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Text('COURT 03\nCONFIRMED', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: ink),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Date', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700)),
                              Text('Today, 24 Oct', style: TextStyle(color: ink, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Window (2 hrs)', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700)),
                              Text('06:00 PM -\n08:00 PM', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleFee() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STYLE & FEE SHARING', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedStyle = 'Casual Rally / Practice'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: selectedStyle == 'Casual Rally / Practice' ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: selectedStyle == 'Casual Rally / Practice' ? [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))] : null),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 14, color: selectedStyle == 'Casual Rally / Practice' ? AppColors.primary : muted),
                        const SizedBox(width: 4),
                        Text('Casual Rally / Practice', style: TextStyle(color: selectedStyle == 'Casual Rally / Practice' ? ink : muted, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedStyle = 'Competitive Ranked'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: selectedStyle == 'Competitive Ranked' ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: selectedStyle == 'Competitive Ranked' ? [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))] : null),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 14, color: selectedStyle == 'Competitive Ranked' ? ink : muted),
                        const SizedBox(width: 4),
                        Text('Competitive Ranked', style: TextStyle(color: selectedStyle == 'Competitive Ranked' ? ink : muted, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _feeOption('50 / 50 Split', 'Partner pays LKR 800 (Host already booked)', Icons.pie_chart_outline),
        const SizedBox(height: 8),
        _feeOption('Host Pays 100%', 'Free session for your partner', Icons.card_giftcard),
        const SizedBox(height: 8),
        _feeOption('Bring Shuttles / Balls', 'In lieu of court fee payment', Icons.sports_tennis_rounded),
      ],
    );
  }

  Widget _feeOption(String title, String desc, IconData icon) {
    bool selected = selectedFee == title;
    return GestureDetector(
      onTap: () => setState(() => selectedFee = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE9EEFF))),
        child: Row(
          children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: selected ? AppColors.primary : const Color(0xFFF4F7FF), shape: BoxShape.circle), child: Icon(icon, color: selected ? Colors.white : muted, size: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text(desc, style: TextStyle(color: muted, fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle : Icons.circle, color: selected ? AppColors.primary : const Color(0xFFE9EEFF), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastPreferences() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BROADCAST PREFERENCES', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18, color: ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Auto-Expiry Timer', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('Closes beacon 30 mins before match start', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              CupertinoSwitch(value: autoExpiry, activeColor: AppColors.primary, onChanged: (v) => setState(() => autoExpiry = v)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('WhatsApp & Instant SMS Alert', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('Notify me instantly on partner accept', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              CupertinoSwitch(value: whatsappAlert, activeColor: AppColors.primary, onChanged: (v) => setState(() => whatsappAlert = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.circle, size: 6, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Badminton â€¢ CSA Arena â€¢ Today 6 PM â€¢ Inter', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                Text('READY', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match beacon broadcasted to 420+ athletes!')));
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Broadcast Match Beacon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.bolt_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.radar_rounded, size: 12, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(child: Text('Free broadcast â€¢ Instant push notifications to matching\nplayers in a 5km radius', style: TextStyle(color: muted, fontSize: 9, height: 1.3), textAlign: TextAlign.center)),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: const [
              Text('COLOMBO SPORTS AUTHORITY PARTNER â€¢ SPORTSBOOK', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
              Text('MATCHMAKER OS V2.4', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
