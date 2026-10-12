import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_theme.dart';
import 'digital_match_pass_screen.dart';
import 'modify_slot_screen.dart';
import 'cancel_booking_screen.dart';
import 'rate_review_screen.dart';
import '../auth/booking_history_screen.dart';
import '../auth/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import '../../core/actions.dart';
import '../../core/app_config.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _activeTab = 'Upcoming';
  final _searchCtl = TextEditingController();
  bool _newestFirst = true;

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  final SupabaseService _service = SupabaseService();
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      _bookingsFuture = _service.getUserBookings();
    });
  }


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
              _header(context),
              const SizedBox(height: 22),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My Bookings', style: TextStyle(color: ink, fontSize: 29, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Manage your court reservations &\ndigital passes', style: TextStyle(color: muted, fontSize: 15, height: 1.3))])),
                _badge('LIVE ENTRY\nREADY'),
              ]),
              const SizedBox(height: 16),
              TextField(controller: _searchCtl, onChanged: (_) => setState(() {}), decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded, color: muted), hintText: 'Search bookings or venues...', suffixIcon: IconButton(tooltip: _newestFirst ? 'Newest first' : 'Oldest first', onPressed: () => setState(() => _newestFirst = !_newestFirst), icon: Icon(_newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: AppColors.primary)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
              const SizedBox(height: 13),
              _buildFutureBookings(context),
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

  Widget _header(BuildContext context) => Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 23)), const SizedBox(width: 9), const Expanded(child: Text('SportsBook', style: TextStyle(color: ink, fontSize: 25, fontWeight: FontWeight.w700))), IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none_rounded, color: muted)), GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), child: Container(width: 38, height: 38, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 21)))]);

  Widget _badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(24)), child: Row(children: [const Icon(Icons.circle, color: AppColors.primary, size: 9), const SizedBox(width: 7), Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800, height: 1.1))]));

  
  Widget _buildFutureBookings(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        
        var bookings = snapshot.data ?? [];
        final q = _searchCtl.text.trim().toLowerCase();
        if (q.isNotEmpty) {
          bookings = bookings.where((b) => '${(b['venues'] as Map?)?['name']} ${b['court_name']} ${b['booking_ref']} ${b['date_schedule']}'.toLowerCase().contains(q)).toList();
        }
        if (!_newestFirst) bookings = bookings.reversed.toList();
        
        bool isPast(Map<String, dynamic> b) {
          final d = DateTime.tryParse('${b['date_schedule']}');
          final now = DateTime.now();
          return d != null && d.isBefore(DateTime(now.year, now.month, now.day));
        }

        final upcomingList = bookings.where((b) => b['status'] != 'Cancelled' && b['status'] != 'Completed' && !isPast(b)).toList();
        final completedList = bookings.where((b) => b['status'] == 'Completed' || (b['status'] != 'Cancelled' && isPast(b))).toList();
        final cancelledList = bookings.where((b) => b['status'] == 'Cancelled').toList();
        
        List<Map<String, dynamic>> activeList;
        if (_activeTab == 'Upcoming') activeList = upcomingList;
        else if (_activeTab == 'Completed') activeList = completedList;
        else activeList = cancelledList;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabs(upcomingList.length, completedList.length, cancelledList.length),
            const SizedBox(height: 18),
            if (activeList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No bookings found for this category.', style: TextStyle(color: muted, fontSize: 14)),
              )
            else
              ...activeList.map((b) {
                final venue = b['venues'] ?? {};
                const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                final dateSplit = (b['date_schedule'] ?? '').toString().split('-');
                final formattedDate = dateSplit.length == 3 ? '${dateSplit[2]} ${mon[(int.tryParse(dateSplit[1]) ?? 1) - 1]} ${dateSplit[0]}' : b['date_schedule'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _bookingCard(
                    context,
                    primary: activeList.indexOf(b) == 0,
                    name: venue['name'] ?? 'Unknown Venue',
                    detail: b['court_name'] ?? 'Court',
                    date: formattedDate ?? '',
                    time: b['time_slot'] ?? '',
                    price: (b['total_paid'] ?? 0).toString(),
                    status: b['status'] ?? 'Scheduled',
                    ref: b['booking_ref'] ?? '',
                    booking: b,
                  ),
                );
              }).toList(),
              
            if (_activeTab == 'Upcoming' && completedList.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(children: [const Expanded(child: Text('Recently Completed', style: TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w700))), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen())), child: Text('View History (${completedList.length})'))]),
              for (final c in completedList.take(3)) _completedCard(context, c),
            ]
          ],
        );
      },
    );
  }

  Widget _tabs(int upcoming, int completed, int cancelled) => SingleChildScrollView(
    scrollDirection: Axis.horizontal, 
    child: Row(
      children: ['Upcoming', 'Completed', 'Cancelled'].map((tab) => Padding(
        padding: const EdgeInsets.only(right: 8), 
        child: GestureDetector(
          onTap: () { setState((){ _activeTab = tab; }); }, 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11), 
            decoration: BoxDecoration(color: tab == _activeTab ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(24)), 
            child: Text('$tab   ${tab == 'Upcoming' ? upcoming : tab == 'Completed' ? completed : cancelled}', style: TextStyle(color: tab == _activeTab ? Colors.white : muted, fontSize: 14, fontWeight: FontWeight.w600))
          )
        )
      )).toList()
    )
  );

  Widget _bookingCard(BuildContext context, {required String name, required String detail, required String date, required String time, required String price, required String status, required String ref, required Map<String, dynamic> booking, bool primary = false}) {
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
        Row(children: [const Icon(Icons.location_on_outlined, color: muted, size: 18), const SizedBox(width: 5), Expanded(child: Text('${(booking['venues'] as Map?)?['address'] ?? (booking['venues'] as Map?)?['area'] ?? ''}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 13))), TextButton(onPressed: () => openDirections('${(booking['venues'] as Map?)?['name'] ?? ''}, ${(booking['venues'] as Map?)?['address'] ?? (booking['venues'] as Map?)?['area'] ?? ''}'), child: const Text('Directions →'))]),
        const SizedBox(height: 4),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _showPass(context, ref), icon: const Icon(Icons.qr_code_2_rounded, size: 20), label: const Text('View Pass & QR Code'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 13)))),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _softButton('▣ Modify Slot', () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => ModifySlotScreen(booking: booking))); _loadBookings(); })), const SizedBox(width: 8), Expanded(child: _softButton('× Cancel', () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => CancelBookingScreen(booking: booking))); _loadBookings(); }, danger: true))]),
        const SizedBox(height: 10),
        const Center(child: Text('Free cancellation policy was applicable until 4:00\nPM today', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _completedCard(BuildContext context, Map<String, dynamic> b) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const _StatusTag(label: 'Completed'), const SizedBox(width: 10), Expanded(child: Text('${b['date_schedule']} • ${b['time_slot']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 13))), Text('LKR\n${b['total_paid']}', textAlign: TextAlign.right, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 12),
        Text('${(b['venues'] as Map?)?['name'] ?? 'Venue'}', style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w700)),
        Text('${b['court_name']}', style: const TextStyle(color: muted, fontSize: 13)),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: _softButton('★ Rate & Review', () { Navigator.push(context, MaterialPageRoute(builder: (_) => RateReviewScreen(booking: b))); })), const SizedBox(width: 8), Expanded(child: _softButton('↓ Invoice', () => _showInvoice(context, b)))]),
      ]),
    );
  }

  Widget _supportCard(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(17)), child: Row(children: [Container(width: 42, height: 42, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.support_agent_rounded, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Need assistance with\naccess?', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w700)), Text('24/7 Colombo Sports Authority Hotline', style: TextStyle(color: muted, fontSize: 13))])), FilledButton(onPressed: () => callNumber(AppConfig.supportPhone), style: FilledButton.styleFrom(minimumSize: const Size(64, 36), backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder()), child: const Text('Call'))]));

  Widget _status(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)));

  Widget _softButton(String label, VoidCallback onPressed, {bool danger = false}) => TextButton(onPressed: onPressed, style: TextButton.styleFrom(backgroundColor: softBlue, foregroundColor: danger ? Colors.redAccent : ink, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 11)), child: Text(label));

  String _invoiceText(Map<String, dynamic> b) {
    final venue = (b['venues'] as Map?)?['name'] ?? 'Venue';
    return 'SPORTSBOOK INVOICE\n'
        'Booking: ${b['booking_ref']}\n'
        'Venue: $venue\n'
        'Court: ${b['court_name']}\n'
        'Date: ${b['date_schedule']}\n'
        'Time: ${b['time_slot']}\n'
        'Amount paid: LKR ${b['total_paid']}\n'
        'Status: ${b['status']}';
  }

  void _showInvoice(BuildContext context, Map<String, dynamic> b) {
    final text = _invoiceText(b);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invoice', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SelectableText(text, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          TextButton(onPressed: () { copyText(text, message: 'Invoice copied'); Navigator.pop(ctx); }, child: const Text('Copy')),
          FilledButton(onPressed: () { shareText(text, subject: 'Invoice ${b['booking_ref']}'); Navigator.pop(ctx); }, child: const Text('Share')),
        ],
      ),
    );
  }

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
