import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class CancelBookingScreen extends StatelessWidget {
  const CancelBookingScreen({super.key});

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
            Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.change_circle_outlined, color: Colors.white, size: 18)), // Using a similar icon as there's no exact cancel circle in screenshot
            const SizedBox(width: 12),
            const Text('Cancel Booking', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(16)), child: Row(children: const [Icon(Icons.numbers, size: 12, color: muted), SizedBox(width: 4), Text('#SB-COL-2024-8941', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: Row(children: const [Icon(Icons.circle, size: 8, color: AppColors.primary), SizedBox(width: 4), Text('Live Window', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800))])),
              ],
            ),
            const SizedBox(height: 16),
            _buildCancellationWindow(),
            const SizedBox(height: 24),
            _buildBookingSummary(),
            const SizedBox(height: 24),
            _buildRefundBreakdown(),
            const SizedBox(height: 24),
            _buildReasonForCancellation(),
            const SizedBox(height: 24),
            _buildAccessRevocationNotice(),
            const SizedBox(height: 32),
            _buildBottomButtons(context),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationWindow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle), child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cancellation Window Active', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Free cancellation available until ', style: TextStyle(color: muted, fontSize: 10, height: 1.4)),
                      const TextSpan(text: '4:00 PM\ntoday', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700, height: 1.4)),
                      const TextSpan(text: '. 100% full refund will be credited to\nyour original payment method.', style: TextStyle(color: muted, fontSize: 10, height: 1.4)),
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

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.sports_tennis_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('BADMINTON â€¢ INDOOR WOOD\nCOURT', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, height: 1.2)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)), child: const Text('Olympic\nGrade', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('CSA National Arena', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Court 1 â€¢ Teak Flooring', style: TextStyle(color: muted, fontSize: 10)),
                ],
              ),
              Container(width: 40, height: 40, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.stadium_outlined, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SCHEDULE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Today, 24 Oct', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('06:00 - 08:00 PM (2h)', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SQUAD ACCESS', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Kasun + 3 players', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('Turnstile Gate 4', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFE9EEFF), height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Paid In Full', style: TextStyle(color: muted, fontSize: 11)),
              Text('Commercial Bank Visa â€¢â€¢â€¢â€¢ 4120', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefundBreakdown() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Refund Breakdown', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: const Text('100% Refundable', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))),
          ],
        ),
        const SizedBox(height: 16),
        _summaryRow('Original Court Fee (2.0 hrs)', 'LKR 5,825'),
        const SizedBox(height: 12),
        _summaryRow('Cancellation Policy Fee', 'LKR 0 (Free Window)', highlight: true),
        const SizedBox(height: 12),
        _summaryRow('Convenience & Platform Fee', 'Waived', highlight: true),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Total Refund', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
                Text('Direct to original method', style: TextStyle(color: muted, fontSize: 10)),
              ],
            ),
            const Text('LKR 5,825', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SELECT REFUND DESTINATION', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _refundRadioOption(true, 'Commercial Bank Visa (â€¢â€¢â€¢â€¢ 4120)', 'Processed in 2-3 business days', Icons.credit_card_outlined),
              const SizedBox(height: 12),
              _refundRadioOption(false, 'SportsBook Wallet Credit', 'Instant balance availability', Icons.account_balance_wallet_outlined),
            ],
          ),
        ),
      ],
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

  Widget _refundRadioOption(bool selected, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE9EEFF))),
      child: Row(
        children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? AppColors.primary : muted, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                Text(subtitle, style: TextStyle(color: selected ? AppColors.primary : muted, fontSize: 9)),
              ],
            ),
          ),
          Icon(icon, color: muted, size: 16),
        ],
      ),
    );
  }

  Widget _buildReasonForCancellation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reason for Cancellation', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
        const Text('Help us improve facility availability (Select one)', style: TextStyle(color: muted, fontSize: 10)),
        const SizedBox(height: 16),
        _reasonRadio(true, 'Change of plans / Schedule conflict'),
        const SizedBox(height: 8),
        _reasonRadio(false, 'Teammates / squad unable to attend'),
        const SizedBox(height: 8),
        _reasonRadio(false, 'Injury or health issue'),
        const SizedBox(height: 8),
        _reasonRadio(false, 'Booking mistake (wrong date / time /\ncourt)'),
        const SizedBox(height: 8),
        _reasonRadio(false, 'Other reason'),
      ],
    );
  }

  Widget _reasonRadio(bool selected, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: selected ? AppColors.primary : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? Colors.white : muted, size: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: selected ? Colors.white : ink, fontSize: 11, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildAccessRevocationNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Access Revocation Notice', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.qr_code_2_rounded, size: 14, color: muted),
              SizedBox(width: 8),
              Expanded(child: Text('Digital turnstile gate pass #SB-COL-2024-\n8941 will be revoked immediately and locker\npairings cleared.', style: TextStyle(color: muted, fontSize: 10, height: 1.4))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(child: Text('Kasun and 3 squad members will be\nautomatically notified via SMS & WhatsApp.', style: TextStyle(color: muted, fontSize: 10, height: 1.4))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.event_busy, size: 16),
            label: const Text('Confirm & Cancel Booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Keep Booking / Go Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              side: const BorderSide(color: Color(0xFFE9EEFF)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: const [
        Text('Official Partner of Colombo Sports Authority', style: TextStyle(color: muted, fontSize: 10)),
        SizedBox(height: 4),
        Text('SPORTSBOOK OS â€¢ V2.4.0', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ],
    );
  }
}
