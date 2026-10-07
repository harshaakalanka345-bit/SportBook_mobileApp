import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'admin_profile_screen.dart';

class AdminIncidentsScreen extends StatelessWidget {
  const AdminIncidentsScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildAppBar(),
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 20),
            _buildCriticalIncidentCard(),
            const SizedBox(height: 16),
            _buildHazardCard(),
            const SizedBox(height: 16),
            _buildReliefProtocolCard(),
            const SizedBox(height: 24),
            _buildClearButton(),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '© COLOMBO SPORTS AUTHORITY\nSafety & Arena Floor Compliance Protocols 7.4.0 •\nTelemetry Node #CSA-LK-01',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 8, height: 1.5, fontWeight: FontWeight.w600),
              ),
            ),
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
          child: const Icon(Icons.warning_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('COLOMBO SPORTS OPS', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              Text('Incidents', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: const [
              Icon(Icons.circle, color: AppColors.primary, size: 6),
              SizedBox(width: 4),
              Text('FLOOR LIVE', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Facility Incident Desk', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
            Row(
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 6),
                SizedBox(width: 4),
                Text('Sys Live', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: const [
            Icon(Icons.business, color: muted, size: 12),
            SizedBox(width: 4),
            Text('CSA National Arena • Active Shift Marshal: Son Floor', style: TextStyle(color: muted, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(20)),
            child: const Text('Active / Halts (2)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Text('In Progress (1)', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: muted, size: 14),
                SizedBox(width: 6),
                Text('Resolved', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalIncidentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: Colors.redAccent, width: 4)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.redAccent, size: 8),
                  const SizedBox(width: 6),
                  const Text('GAME HALTED • CRITICAL', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w800)),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.access_time, color: muted, size: 10),
                  SizedBox(width: 4),
                  Text('8m ago', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('CSA Arena • Court 1', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(4)),
                child: const Text('#SB-COL-8941', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Badminton - Premium Teak Parquet Floor', style: TextStyle(color: muted, fontSize: 10)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Headlight Unit 3 flickering severely; blinding players on smash baseline. Match suspended by umpire.', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w600, height: 1.3))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: NetworkImage('https://ui-avatars.com/api/?name=Kasun+Perera&background=0D8ABC&color=fff'), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Kasun Perera', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                    Text('Gold Tier Athlete', style: TextStyle(color: AppColors.primary, fontSize: 9)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone_in_talk, size: 12, color: AppColors.primary),
                label: const Text('Direct Dial', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: softBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('USER UPLOADED EVIDENCE (1 FILE)', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
              Text('Verified Timestamp', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600&auto=format&fit=crop'), // Faint light/court image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: const Text('Court 1 • High Luminaire Row B', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.zoom_in, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.build, size: 14),
                  label: const Text('Dispatch Tech', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                  label: const Text('Move to Court 3', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHazardCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 4)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.water_drop, color: Color(0xFFF59E0B), size: 10),
                  SizedBox(width: 6),
                  Text('FLOOR HAZARD • MOPPING', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9, fontWeight: FontWeight.w800)),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.access_time, color: muted, size: 10),
                  SizedBox(width: 4),
                  Text('22m ago', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Liberty Courts • Court 2', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Synthetic Indoor Shoe Rubber Burn/Sweat', style: TextStyle(color: muted, fontSize: 10)),
          const SizedBox(height: 12),
          const Text('Slippery condensation spotted along left doubles boundary line near baseline corner.', style: TextStyle(color: ink, fontSize: 10, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Color(0xFF0D6EFD), shape: BoxShape.circle),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Marshal Suresh B. on site', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
                      Text('ETA completion: ~3 mins', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Phase 1: Logged', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 2, color: softBlue)),
              const SizedBox(width: 8),
              const Text('Phase 2: Cleaning In Progress', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReliefProtocolCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0DDFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              const Text('Instant Relief Protocol', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                child: const Text('AUTO', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Recommend compensation relief for booking\n#SB-COL-8941', style: TextStyle(color: muted, fontSize: 10, height: 1.3)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Credit 20% Player Wallet', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                      Text('Instant wallet top-up to offset lost time', style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                  child: const Text('1-Tap Grant', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.more_time, color: AppColors.primary, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Free 30m Extended Slot', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                      Text('Applies automatically to digital pass', style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Issue Pass', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.lock_open, size: 16),
        label: const Text('Mark Cleared & Lift Slot Locks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0D6EFD),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
          shadowColor: const Color(0x400D6EFD),
        ),
      ),
    );
  }
}
