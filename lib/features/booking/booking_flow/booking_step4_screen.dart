import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../booking_screen.dart';

class BookingStep4Screen extends StatelessWidget {
  const BookingStep4Screen({super.key});

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
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle),
          child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SPORTSBOOK', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            Text('Booking Confirmed', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: ink),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            _buildConfirmationHeader(),
            const SizedBox(height: 24),
            _buildMatchPass(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildArrivalChecklist(),
            const SizedBox(height: 24),
            _buildVenueLocation(),
            const SizedBox(height: 32),
            _buildPartnerFooter(),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildConfirmationHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
          child: const Text('STEP 4 OF 4 â€¢ CONFIRMED', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        const Text('Booking Confirmed! ðŸŽ‰', style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Your court is reserved and locked in. See you\non the court!', style: TextStyle(color: muted, fontSize: 12, height: 1.4), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Ref: ', style: TextStyle(color: muted, fontSize: 11)),
              Text('#SB-COL-2024-8941', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
              SizedBox(width: 6),
              Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchPass() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.confirmation_number_outlined, size: 14, color: Colors.white),
                        SizedBox(width: 8),
                        Text('OFFICIAL MATCH PASS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('PRIORITY ACCESS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('ARENA VENUE', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w800)),
                const Text('CSA National Arena', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 12, color: Colors.white70),
                    SizedBox(width: 4),
                    Text('Maitland Place, Colombo 07', style: TextStyle(color: Colors.white70, fontSize: 10)),
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
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.sports_tennis_rounded, size: 16, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('SPORT & COURT', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                          Text('Badminton â€¢ Court 1', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                          Text('Indoor Wooden Parquet', style: TextStyle(color: muted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)), child: const Text('Standard', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('DATE & SCHEDULE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                            Text('Today, 24 Oct 2024', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                            Text('06:00 PM - 08:00 PM (2 Hours)', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9EEFF))),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('ADD-ONS INCLUDED', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                            Text('2x Yonex Rackets + 1x Feather Shuttle Tube', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('TOTAL PAID (LKR)', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                        Text('LKR 5,825', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: const [
                          Icon(Icons.credit_card_rounded, size: 12, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text('Visa â€¢â€¢â€¢â€¢ 4821', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Color(0xFFE9EEFF), height: 1, thickness: 2), 
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('FACILITY GATE ACCESS PASS', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
                  child: const Icon(Icons.qr_code_2_rounded, size: 120, color: ink),
                ),
                const SizedBox(height: 16),
                const Text('Scan this QR code at the CSA Arena entrance gate\nor present to the court manager on arrival.', style: TextStyle(color: muted, fontSize: 10, height: 1.4), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('MANUAL CHECK-IN ', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('PIN: 8492', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK MATCH ACTIONS', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _actionRow(Icons.calendar_month_outlined, 'Add to Apple / Google Calendar', 'Includes court gate directions & PIN'),
        const SizedBox(height: 8),
        _actionRow(Icons.share_outlined, 'Share Match Pass with Team', 'Send pass via WhatsApp or SMS'),
        const SizedBox(height: 8),
        _actionRow(Icons.directions_outlined, 'Get GPS Directions', 'Open in Google Maps / Waze (0.8 km away)'),
      ],
    );
  }

  Widget _actionRow(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: muted, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 16, color: muted),
        ],
      ),
    );
  }

  Widget _buildArrivalChecklist() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Arrival Checklist & Rules', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          _ruleItem(Icons.do_not_step_outlined, 'Mandatory Non-Marking Shoes', 'Standard outdoor sneakers strictly prohibited on timber parquet.'),
          const SizedBox(height: 12),
          _ruleItem(Icons.access_time_outlined, 'Arrive 10 Minutes Prior', 'Check-in at front desk for electronic locker key and towel tokens.'),
          const SizedBox(height: 12),
          _ruleItem(Icons.water_drop_outlined, 'Amenities & Refill Station', 'Free chilled electrolyte refill and clean towels available at CSA Pro Shop.'),
        ],
      ),
    );
  }

  Widget _ruleItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: muted, fontSize: 10, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenueLocation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(width: 64, height: 64, color: const Color(0xFFE5E7EB), child: const Icon(Icons.map_outlined, color: muted)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('VENUE LOCATION', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
                Text('Maitland Place Arena', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                Text('Colombo 07, Western Province', style: TextStyle(color: muted, fontSize: 10)),
                SizedBox(height: 4),
                Text('â–³ Est. 4 min drive', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.verified_user_outlined, size: 12, color: AppColors.primary),
            SizedBox(width: 6),
            Text('COLOMBO SPORTS AUTHORITY PARTNER', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        const Text('SportsBook Kinetic Booking System â€¢ Version 2.4.0', style: TextStyle(color: muted, fontSize: 9)),
      ],
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
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                // In a real app, this would switch tab to Bookings tab.
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
                  Text('View in My Bookings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: FilledButton.styleFrom(
                backgroundColor: softBlue,
                foregroundColor: ink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Return to Home Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
