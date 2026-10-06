import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ModifySlotScreen extends StatelessWidget {
  const ModifySlotScreen({super.key});

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
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: ink), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.change_circle_outlined, color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            const Text('Modify Slot', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.person_outline, color: Colors.white, size: 16)),
          IconButton(icon: const Icon(Icons.close_rounded, color: ink), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _buildCurrentReservation(),
            const SizedBox(height: 32),
            const Text('Select a New Date & Time Slot', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Choose an alternate slot at CSA National Arena or change\ncourt duration.', style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
            const SizedBox(height: 24),
            _buildCalendar(),
            const SizedBox(height: 24),
            _buildMorningSlots(),
            const SizedBox(height: 24),
            _buildEveningSlots(),
            const SizedBox(height: 32),
            _buildSummary(),
            const SizedBox(height: 24),
            _buildPolicyBox(),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildCurrentReservation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: Row(children: const [Icon(Icons.circle, size: 6, color: AppColors.primary), SizedBox(width: 6), Text('CURRENT RESERVATION', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800))])),
              const Text('#SB-COL-2024-8941', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('CSA National Arena', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('Court 1 â€¢ Teak Flooring â€¢ Olympic Grade', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Today, 24 Oct 2024 â€¢ 06:00 PM -', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                      Text('08:00 PM', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: const Text('2.0\nhrs', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Amount Paid', style: TextStyle(color: muted, fontSize: 11)),
              Text.rich(TextSpan(children: [TextSpan(text: 'LKR 5,825 ', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)), TextSpan(text: '(Paid in Full)', style: TextStyle(color: muted, fontSize: 10))])),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: const [
                Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Free Reschedule Window Active â€¢ Ends at 4:00 PM', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        Row(
          children: [
            const Text('October 2024', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            const Text('/ Nov', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(width: 28, height: 28, decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle), child: const Icon(Icons.chevron_left_rounded, color: ink, size: 18)),
            const SizedBox(width: 8),
            Container(width: 28, height: 28, decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle), child: const Icon(Icons.chevron_right_rounded, color: ink, size: 18)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dateBox('TODAY', '24', 'Thu', false),
            _dateBox('FRI', '25', '4 slots', true),
            _dateBox('SAT', '26', '6 slots', false),
            _dateBox('SUN', '27', '8 slots', false),
          ],
        ),
      ],
    );
  }

  Widget _dateBox(String day, String date, String subtitle, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: active ? null : Border.all(color: const Color(0xFFE9EEFF)),
        boxShadow: active ? [const BoxShadow(color: Color(0x330044FF), blurRadius: 10, offset: Offset(0, 4))] : null,
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: active ? Colors.white : muted, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: active ? Colors.white : ink, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          if (active)
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 9)))
          else
            Text(subtitle, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMorningSlots() {
    return Column(
      children: [
        Row(
          children: const [
            Icon(Icons.wb_sunny_outlined, size: 14, color: muted),
            SizedBox(width: 8),
            Text('MORNING & AFTERNOON', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 16),
        _slotItem('08:00 AM - 10:00 AM', 'Court 1 â€¢ 2.0 hrs', null, isBooked: true),
        const SizedBox(height: 12),
        _slotItem('10:00 AM - 12:00 PM', 'Court 1 â€¢ 2.0 hrs', 'LKR 5,500', isAvailable: true),
        const SizedBox(height: 12),
        _slotItem('02:00 PM - 04:00 PM', 'Court 1 â€¢ 2.0 hrs', 'LKR 5,500', isAvailable: true),
      ],
    );
  }

  Widget _buildEveningSlots() {
    return Column(
      children: [
        Row(
          children: const [
            Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
            SizedBox(width: 8),
            Text('EVENING PRIME SLOTS', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Color(0x330044FF), blurRadius: 10, offset: Offset(0, 4))]),
          child: Row(
            children: [
              Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 16)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('05:00 PM - 07:00\nPM', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, height: 1.2)),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text('Selected', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Court 1 â€¢ Teak Olympic â€¢ 2.0 hrs', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              const Text('LKR\n5,825', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _slotItem('07:00 PM - 09:00 PM', 'Court 1 â€¢ 2.0 hrs', null, isBooked: true),
        const SizedBox(height: 12),
        _slotItem('08:00 PM - 10:00 PM', 'Court 1 â€¢ 2.0 hrs', 'LKR 5,825', isAvailable: true),
      ],
    );
  }

  Widget _slotItem(String time, String desc, String? price, {bool isBooked = false, bool isAvailable = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: TextStyle(color: isBooked ? muted : ink, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: muted, fontSize: 10)),
            ],
          ),
          if (isBooked)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)), child: const Text('Booked', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600)))
          else if (isAvailable && price != null)
            Row(
              children: [
                Text(price, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Container(width: 24, height: 24, decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle), child: const Icon(Icons.add, color: AppColors.primary, size: 16)),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RESCHEDULE BALANCE SUMMARY', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: const Text('1:1 Value Match', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow('Original Booking (24 Oct)', 'LKR 5,825'),
          const SizedBox(height: 12),
          _summaryRow('New Slot Fee (25 Oct, 5-7 PM)', 'LKR 5,825'),
          const SizedBox(height: 12),
          _summaryRow('Modification Surcharge', 'LKR 0 (Free Window)', highlight: true),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFE9EEFF), height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('OUTSTANDING BALANCE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                  Text('LKR 0.00', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)), child: const Text('No Extra Payment', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: muted, fontSize: 11)),
        Text(value, style: TextStyle(color: highlight ? AppColors.primary : ink, fontSize: 11, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildPolicyBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Reschedule Policy & Access Sync', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Free one-time reschedule allowed up to 2 hours prior to slot start time. Existing turnstile QR code will automatically update upon confirmation.', style: TextStyle(color: muted, fontSize: 10, height: 1.4)),
              ],
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.circle, size: 8, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('New Slot: Fri, 25 Oct â€¢ 5:00 PM - 7:00\nPM', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
              const Text('LKR 0 Due', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Confirm Reschedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Text('Keep Original Reservation', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
