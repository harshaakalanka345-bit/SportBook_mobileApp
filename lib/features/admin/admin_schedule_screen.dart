import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'walk_in_booking_modal.dart';
import 'admin_profile_screen.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  
  bool _surgeEnabled = true;

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
            _buildLocationRow(),
            const SizedBox(height: 16),
            _buildDateTabs(),
            const SizedBox(height: 16),
            _buildCourtTabs(),
            const SizedBox(height: 20),
            _buildCourtInfoCard(),
            const SizedBox(height: 24),
            _buildTimeSlotsHeader(),
            const SizedBox(height: 16),
            _buildCompletedSlot(),
            const SizedBox(height: 16),
            _buildOpenSlot(),
            const SizedBox(height: 16),
            _buildInProgressSlot(),
            const SizedBox(height: 16),
            _buildBlockedSlot(),
            const SizedBox(height: 24),
            _buildQuickReservationBtn(),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'COLOMBO SPORTS AUTHORITY • SPORTSBOOK OPS\nOS V2.4.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w700, height: 1.5),
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
          child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('SPORTSBOOK OPS', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800)),
              Text('Schedule', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
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
              Text('LIVE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
        const SizedBox(width: 4),
        const Text('CSA National\nArena', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800, height: 1.1)),
        const SizedBox(width: 8),
        const Icon(Icons.circle, color: muted, size: 4),
        const SizedBox(width: 8),
        const Text('Torrington', style: TextStyle(color: muted, fontSize: 11)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: const [
              Icon(Icons.circle, color: Colors.green, size: 6),
              SizedBox(width: 4),
              Text('SYNC\n12MS', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800, height: 1.1)),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
          child: const Icon(Icons.tune, color: muted, size: 16),
        ),
      ],
    );
  }

  Widget _buildDateTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _dateTab('WED', '23', false),
          _dateTab('• TODAY', '24 Oct', true),
          _dateTab('FRI', '25', false),
          _dateTab('SAT', '26', false),
          _dateTab('SUN', '27', false),
        ],
      ),
    );
  }

  Widget _dateTab(String day, String date, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0D6EFD) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: isSelected ? Colors.white : muted, fontSize: 9, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(date, style: TextStyle(color: isSelected ? Colors.white : ink, fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildCourtTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: const [
                Icon(Icons.sports_tennis, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text('Court 1 • Parquet (PRO)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: const [
                Icon(Icons.sports_gymnastics, color: ink, size: 14),
                SizedBox(width: 6),
                Text('Court 2 • Mat', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• COURT 1 • ACTIVE ARENA', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Teak Flooring • Peak\nWindow', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.2)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFD0DDFB), borderRadius: BorderRadius.circular(12)),
                    child: const Text('80% BOOKED', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 4),
                  const Text('4 of 5 Slots Filled', style: TextStyle(color: muted, fontSize: 9)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('High friction standard • FIBA\nLevel 1 certified', style: TextStyle(color: muted, fontSize: 11, height: 1.3)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cleaning_services_outlined, size: 14, color: ink),
                  label: const Text('Block for Clean', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bolt, size: 14),
                  label: const Text('Set Surge Rate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
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

  Widget _buildTimeSlotsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Time Slots', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
              child: const Text('5 Scheduled', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.filter_list, color: AppColors.primary, size: 14),
            SizedBox(width: 4),
            Text('Filter', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedSlot() {
    return _buildSlotCard(
      icon: Icons.history,
      iconBg: softBlue,
      iconColor: muted,
      time: '08:00 –\n10:00',
      duration: '(2\nhrs)',
      statusPill: _buildStatusPill('COMPLETED', const Color(0xFFE2E8F0), muted, Icons.check_circle_outline),
      details: const Text('Rate: LKR 2,000/hr • Host:\nSahan P.', style: TextStyle(color: muted, fontSize: 11, height: 1.3)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: const [
            Icon(Icons.directions_walk, color: muted, size: 14),
            SizedBox(width: 8),
            Expanded(child: Text('Turnstile cleared • 4/4\nchecked out', style: TextStyle(color: muted, fontSize: 9))),
            Text('#SB-COL-\n8910', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w700), textAlign: TextAlign.right),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenSlot() {
    return _buildSlotCard(
      icon: Icons.lock_open,
      iconBg: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF16A34A),
      time: '14:00 –\n16:00',
      duration: '(2\nhrs)',
      statusPill: _buildStatusPill('OPEN\nAVAILABLE', const Color(0xFFDCFCE7), const Color(0xFF16A34A), Icons.circle, iconSize: 6),
      details: const Text('Standard Rate: LKR\n2,200/hr', style: TextStyle(color: muted, fontSize: 11, height: 1.3)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Base Total Revenue Potential:', style: TextStyle(color: muted, fontSize: 10)),
              Text('LKR 4,400', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_outline, size: 14, color: ink),
                  label: const Text('Lock Slot', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 14, color: AppColors.primary),
                  label: const Text('Reserve Walk-in', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: softBlue,
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

  Widget _buildInProgressSlot() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(top: BorderSide(color: Color(0xFF0D6EFD), width: 3)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person_outline, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('18:00 –\n20:00', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800, height: 1.1)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Kasun Perera', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(4)),
                          child: const Text('GOLD', style: TextStyle(color: Color(0xFFD97706), fontSize: 8, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: AppColors.primary, size: 4),
                      SizedBox(width: 4),
                      Text('LIVE', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(16)),
                    child: const Text('IN\nPROGRESS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800, height: 1.1), textAlign: TextAlign.center),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Booking Subtotal', style: TextStyle(color: muted, fontSize: 10)),
                    Text('LKR 5,825 Total', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Base 5,000 + Surge 500 + Municipal Tax 325', style: TextStyle(color: muted, fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.bolt, color: Color(0xFFD97706), size: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Peak Floodlit Surge (+LKR 500)', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Dynamic rate enforced for night\ngames', style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                ),
                Switch(
                  value: _surgeEnabled,
                  onChanged: (val) => setState(() => _surgeEnabled = val),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF0D6EFD),
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
                  icon: const Icon(Icons.qr_code_scanner, size: 14, color: ink),
                  label: const Text('Inspect Ticket', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.more_time, size: 14),
                  label: const Text('Extend Slot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
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

  Widget _buildBlockedSlot() {
    return _buildSlotCard(
      icon: Icons.build_outlined,
      iconBg: const Color(0xFFFFF7ED),
      iconColor: const Color(0xFFEA580C),
      time: '21:00 – 23:00',
      duration: '(2 hrs)',
      statusPill: _buildStatusPill('BLOCKED', const Color(0xFFFFF7ED), const Color(0xFFEA580C), Icons.block, iconSize: 10),
      details: const Text('Halogen Floodlight\nMaintenance', style: TextStyle(color: muted, fontSize: 11, height: 1.3)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Color(0xFFD97706), size: 14),
                SizedBox(width: 8),
                Expanded(child: Text('Light bulb replacement scheduled • Work\nTicket #409', style: TextStyle(color: Color(0xFFB45309), fontSize: 9))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_open, size: 14, color: ink),
              label: const Text('Unblock Slot & Restore Live Sync', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: softBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard({required IconData icon, required Color iconBg, required Color iconColor, required String time, required String duration, required Widget statusPill, required Widget details, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(time, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800, height: 1.1)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(duration, style: const TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700, height: 1.1)),
                    ),
                  ],
                ),
              ),
              statusPill,
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: details,
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusPill(String text, Color bg, Color fg, IconData icon, {double iconSize = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: iconSize),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: fg, fontSize: 8, fontWeight: FontWeight.w800, height: 1.1), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQuickReservationBtn() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: const WalkInBookingModal(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: const Text('Quick Walk-in Reservation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: const Color(0x400D6EFD),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bolt, color: Colors.green, size: 12),
            SizedBox(width: 4),
            Text('Instant turnstile credential issued via\nSMS/WhatsApp', style: TextStyle(color: muted, fontSize: 9, height: 1.3)),
          ],
        ),
      ],
    );
  }
}
