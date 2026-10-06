import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import 'booking_step2_screen.dart';

class BookingStep1Screen extends StatelessWidget {
  const BookingStep1Screen({super.key});

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SPORTSBOOK â€¢ BOOKING FLOW', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            Text('Select Slot & Court', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Text('Flow', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _buildVenueCard(),
                  const SizedBox(height: 24),
                  _buildCalendar(),
                  const SizedBox(height: 16),
                  _buildTags(),
                  const SizedBox(height: 24),
                  _buildCourtSelector(),
                  const SizedBox(height: 24),
                  _buildDurationSelector(),
                  const SizedBox(height: 24),
                  _buildLegend(),
                  const SizedBox(height: 24),
                  _buildMorningSlots(),
                  const SizedBox(height: 24),
                  _buildAfternoonSlots(),
                  const SizedBox(height: 24),
                  _buildPrimeEveningSlots(),
                  const SizedBox(height: 32),
                  _buildAmenities(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text('STEP 1 OF 4', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
          const Text(' â€¢ Slot & Court Selection', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(width: 16, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCE7FF), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCE7FF), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCE7FF), borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildVenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE6F0FF), borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            children: const [
                              Icon(Icons.verified_rounded, size: 10, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('BWF Approved', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('BADMINTON', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('CSA National Arena', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, size: 12, color: muted),
                        SizedBox(width: 4),
                        Text('Maitland Place, Colombo', style: TextStyle(color: muted, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('STARTS AT', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                  Text('LKR 2,500', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('per hour', style: TextStyle(color: muted, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.grid_view_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(child: Text('Indoor Wooden Parquet', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600))),
                Container(width: 1, height: 24, color: const Color(0xFFE9EEFF), margin: const EdgeInsets.symmetric(horizontal: 12)),
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(child: Text('Floodlit Pro 800 Lux', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600))),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('October 2024', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: const [
                  Text('Calendar', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dateBox('THU', '24', 'Today', true),
            _dateBox('FRI', '25', '4 slots', false),
            _dateBox('SAT', '26', '2 slots', false, isWeekend: true),
            _dateBox('SUN', '27', '6 slots', false, isWeekend: true),
            _dateBox('MON', '28', '8 slots', false),
          ],
        ),
      ],
    );
  }

  Widget _dateBox(String day, String date, String subtitle, bool active, {bool isWeekend = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: active ? null : Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: active ? Colors.white : (isWeekend ? Colors.red : muted), fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: active ? Colors.white : ink, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: active ? Colors.white70 : muted, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text('Fast Booking Available', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.red),
                SizedBox(width: 4),
                Text('Peak From 5:00 PM', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourtSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('SELECT COURT', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
            Text('3 Courts Available', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person_outline_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Court 1 (Wooden)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9EEFF))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.layers_outlined, size: 16, color: ink),
                    SizedBox(width: 6),
                    Text('Court 2 (Syn)', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Target Duration', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
                child: const Text('120 Mins', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _durationBox('1.0 Hr', false),
              _durationBox('1.5 Hrs', false),
              _durationBox('2.0 Hrs', true),
              _durationBox('3.0 Hrs', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _durationBox(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : ink, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.white, 'Available', true),
          const SizedBox(width: 16),
          _legendItem(AppColors.primary, 'Selected', false),
          const SizedBox(width: 16),
          _legendItem(const Color(0xFFE5E7EB), 'Booked', false),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, bool hasBorder) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder ? Border.all(color: const Color(0xFFD1D5DB)) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMorningSlots() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.wb_twilight_rounded, size: 16, color: muted),
                SizedBox(width: 8),
                Text('Morning Slots', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            Text('06:00 AM - 12:00 PM', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _slotBox('06:00 - 07:00 AM', 'LKR 2,000', 'Booked', false, isBooked: true)),
            const SizedBox(width: 12),
            Expanded(child: _slotBox('07:00 - 08:00 AM', 'LKR 2,000', 'Open', false)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _slotBox('08:00 - 09:00 AM', 'LKR 2,000', 'Open', false)),
            const SizedBox(width: 12),
            Expanded(child: _slotBox('09:30 - 10:30 AM', 'LKR 2,000', 'Open', false)),
          ],
        ),
      ],
    );
  }

  Widget _buildAfternoonSlots() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, size: 16, color: muted),
                SizedBox(width: 8),
                Text('Afternoon Slots', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            Text('12:00 PM - 05:00 PM', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _slotBox('01:00 - 02:00 PM', 'LKR 2,200', 'Open', false)),
            const SizedBox(width: 12),
            Expanded(child: _slotBox('03:00 - 04:00 PM', 'LKR 2,200', 'Booked', false, isBooked: true)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('04:00 - 05:00 PM', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text('Pre-Peak Transition', style: TextStyle(color: muted, fontSize: 10)),
                ],
              ),
              Row(
                children: [
                  const Text('LKR 2,500', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Select', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimeEveningSlots() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.nightlight_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Prime Evening / Floodlit', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
              child: const Text('High Demand', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('2h', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Consecutive 2-Hour Window', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700, height: 1.3)),
                  ),
                  const Text('ACTIVE\nGROUP', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, height: 1.3), textAlign: TextAlign.right),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _slotBox('06:00 - 07:00 PM', 'LKR 2,500', 'Slot 1', true, showCheck: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _slotBox('07:00 - 08:00 PM', 'LKR 2,500', 'Slot 2', true, showCheck: true)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _slotBox('08:00 - 09:00 PM', 'LKR 2,500', 'Fast Selling', false, isFastSelling: true)),
            const SizedBox(width: 12),
            Expanded(child: _slotBox('09:00 - 10:00 PM', 'LKR 2,200', 'Open', false)),
          ],
        ),
      ],
    );
  }

  Widget _slotBox(String time, String price, String status, bool active, {bool isBooked = false, bool showCheck = false, bool isFastSelling = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : (isBooked ? const Color(0xFFF3F4F6) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: active || isBooked ? null : Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(color: active ? Colors.white : (isBooked ? muted : ink), fontSize: 10, fontWeight: FontWeight.w700)),
              if (showCheck) const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white)
              else if (isBooked) const Icon(Icons.lock_outline_rounded, size: 14, color: muted)
              else if (isFastSelling) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(4)), child: const Text('1 Left', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.w700)))
              else const Icon(Icons.circle, size: 8, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: TextStyle(color: active ? Colors.white : (isBooked ? muted : AppColors.primary), fontSize: 14, fontWeight: FontWeight.w800, decoration: isBooked ? TextDecoration.lineThrough : null)),
              Text(status, style: TextStyle(color: active ? Colors.white70 : (isFastSelling ? Colors.red : muted), fontSize: 9, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('INCLUDED AMENITIES', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
              Text('CSA Arena Facilities', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _amenityBox(Icons.shower_outlined, 'Locker &\nShower')),
              const SizedBox(width: 12),
              Expanded(child: _amenityBox(Icons.local_parking_rounded, 'Free Parking')),
              const SizedBox(width: 12),
              Expanded(child: _amenityBox(Icons.water_drop_outlined, 'Pure Hydration')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amenityBox(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
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
                  SizedBox(width: 6),
                  Text('Today, 6:00 PM - 8:00 PM ', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text('(Court 1)', style: TextStyle(color: muted, fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)),
                child: const Text('2 Hours', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('TOTAL:', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text('LKR ', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('5,000', style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Text('2 hrs @ LKR 2,500/hr', style: TextStyle(color: muted, fontSize: 9)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingStep2Screen()));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Checkout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
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
}
