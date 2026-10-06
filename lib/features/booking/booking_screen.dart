import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_theme.dart';
import 'digital_match_pass_screen.dart';
import 'modify_slot_screen.dart';
import 'cancel_booking_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 22),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My Bookings', style: TextStyle(color: ink, fontSize: 29, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Manage your court reservations &\ndigital passes', style: TextStyle(color: muted, fontSize: 15, height: 1.3))])),
                _badge('LIVE ENTRY\nREADY'),
              ]),
              const SizedBox(height: 16),
              TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded, color: muted), hintText: 'Search bookings or venues...', suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded, color: AppColors.primary)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
              const SizedBox(height: 13),
              _tabs(),
              const SizedBox(height: 18),
              _bookingCard(context, primary: true, name: 'CSA National Arena', detail: 'Court 1 (Teak Flooring • Olympic Grade)', date: 'Today, 24 Oct 2024', time: '06:00 PM - 08:00 PM', price: '5,825', status: 'Confirmed • In 2 Hours', ref: '#SB-COL-2024-8941'),
              const SizedBox(height: 16),
              _bookingCard(context, name: 'Liberty Courts', detail: 'Court 3 • Kollupitiya, Colombo 03', date: 'Saturday, 26 Oct 2024', time: '08:30 AM - 10:00 AM', price: '2,700', status: 'Scheduled', ref: '#SB-COL-2024-9102'),
              const SizedBox(height: 16),
              Row(children: [const Expanded(child: Text('Recently Completed', style: TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w700))), TextButton(onPressed: () {}, child: const Text('View History (5)'))]),
              _completedCard(),
              const SizedBox(height: 18),
              _supportCard(context),
              const SizedBox(height: 26),
              const Center(child: Text('♢  Official Partner of Colombo Sports Authority\n\nSportsBook Engine • Version 2.4.0 (Colombo Build)', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12, height: 1.4, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 23)), const SizedBox(width: 9), const Expanded(child: Text('SportsBook', style: TextStyle(color: ink, fontSize: 25, fontWeight: FontWeight.w700))), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: muted)), Container(width: 38, height: 38, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 21))]);

  Widget _badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(24)), child: Row(children: [const Icon(Icons.circle, color: AppColors.primary, size: 9), const SizedBox(width: 7), Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800, height: 1.1))]));

  Widget _tabs() => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Upcoming', 'Completed', 'Cancelled'].map((tab) => Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: () {}, child: Container(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11), decoration: BoxDecoration(color: tab == 'Upcoming' ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(24)), child: Text('$tab   ${tab == 'Upcoming' ? '2' : tab == 'Completed' ? '5' : '0'}', style: TextStyle(color: tab == 'Upcoming' ? Colors.white : muted, fontSize: 14, fontWeight: FontWeight.w600)))))).toList()));

  Widget _bookingCard(BuildContext context, {required String name, required String detail, required String date, required String time, required String price, required String status, required String ref, bool primary = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: primary ? const Border(top: BorderSide(color: AppColors.primary, width: 7)) : null, boxShadow: const [BoxShadow(color: Color(0x0C001844), blurRadius: 10, offset: Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Align(alignment: Alignment.centerLeft, child: _status(status))), Text(ref, style: const TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 15),
        Row(children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFE2EAFF), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 30)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('BADMINTON • Indoor Wood Court', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(name, style: const TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w700)), Text(detail, style: const TextStyle(color: muted, fontSize: 13))]))]),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: Column(children: [Row(children: [const Icon(Icons.event_outlined, color: AppColors.primary, size: 19), const SizedBox(width: 7), Expanded(child: Text(date, style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w600))), const Text('2.0 Hours', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w700))]), const SizedBox(height: 12), Row(children: [const Icon(Icons.access_time_rounded, color: muted, size: 19), const SizedBox(width: 7), Expanded(child: Text(time, style: const TextStyle(color: muted, fontSize: 17))), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('LKR', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w700)), Text(price, style: const TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800)), const Text('Paid in full', style: TextStyle(color: muted, fontSize: 11))])])])),
        const SizedBox(height: 13),
        Row(children: [const Icon(Icons.location_on_outlined, color: muted, size: 18), const SizedBox(width: 5), const Expanded(child: Text('Maitland Place, Colombo 07', overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 13))), TextButton(onPressed: () {}, child: const Text('Directions →'))]),
        const SizedBox(height: 4),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _showPass(context, ref), icon: const Icon(Icons.qr_code_2_rounded, size: 20), label: const Text('View Pass & QR Code'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 13)))),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _softButton('▣ Modify Slot', () { Navigator.push(context, MaterialPageRoute(builder: (context) => const ModifySlotScreen())); })), const SizedBox(width: 8), Expanded(child: _softButton('× Cancel', () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CancelBookingScreen())); }, danger: true))]),
        const SizedBox(height: 10),
        const Center(child: Text('Free cancellation policy was applicable until 4:00\nPM today', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _completedCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const _StatusTag(label: 'Completed'), const SizedBox(width: 10), const Expanded(child: Text('20 Oct 2024 • 05:00 PM', style: TextStyle(color: muted, fontSize: 13))), const Text('LKR\n3,000', textAlign: TextAlign.right, style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 12),
        const Text('Royal Sports Complex', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w700)),
        const Text('Clay Tennis Court A • 1.0 hr match', style: TextStyle(color: muted, fontSize: 13)),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: _softButton('Re-book Court ⚡', () {})), const SizedBox(width: 8), Expanded(child: _softButton('↓ Invoice', () {}))]),
      ]),
    );
  }

  Widget _supportCard(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(17)), child: Row(children: [Container(width: 42, height: 42, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.support_agent_rounded, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Need assistance with\naccess?', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w700)), Text('24/7 Colombo Sports Authority Hotline', style: TextStyle(color: muted, fontSize: 13))])), FilledButton(onPressed: () {}, style: FilledButton.styleFrom(minimumSize: const Size(64, 36), backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder()), child: const Text('Call'))]));

  Widget _status(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)));

  Widget _softButton(String label, VoidCallback onPressed, {bool danger = false}) => TextButton(onPressed: onPressed, style: TextButton.styleFrom(backgroundColor: softBlue, foregroundColor: danger ? Colors.redAccent : ink, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 11)), child: Text(label));

  void _showPass(BuildContext context, String ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DigitalMatchPassScreen(bookingRef: ref)),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)));
}
