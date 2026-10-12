import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';

class ModifySlotScreen extends StatefulWidget {
  const ModifySlotScreen({super.key, this.booking});

  final Map<String, dynamic>? booking;

  @override
  State<ModifySlotScreen> createState() => _ModifySlotScreenState();
}

class _Opt {
  final int id;
  final String time;
  final String price;
  final String label;
  const _Opt(this.id, this.time, this.price, this.label);
}

class _ModifySlotScreenState extends State<ModifySlotScreen> {
  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _opts = [
    _Opt(0, '08:00 AM - 10:00 AM', 'LKR 5,500', '8-10 AM'),
    _Opt(1, '10:00 AM - 12:00 PM', 'LKR 5,500', '10 AM-12 PM'),
    _Opt(2, '02:00 PM - 04:00 PM', 'LKR 5,500', '2-4 PM'),
    _Opt(3, '05:00 PM - 07:00 PM', 'LKR 5,825', '5-7 PM'),
    _Opt(4, '07:00 PM - 09:00 PM', 'LKR 5,825', '7-9 PM'),
    _Opt(5, '08:00 PM - 10:00 PM', 'LKR 5,825', '8-10 PM'),
  ];

  late final DateTime _today;
  late DateTime _stripStart;
  late DateTime _date;
  int? _sel;
  final _service = SupabaseService();
  bool _busy = false;
  final Set<String> _taken = {};

  Future<void> _loadTaken() async {
    final venueId = widget.booking?['venue_id'] as String?;
    if (venueId == null) return;
    final iso = '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    try {
      final rows = await _service.getBookedSlots(venueId, iso);
      if (!mounted) return;
      setState(() {
        _taken
          ..clear()
          ..addAll(rows.where((r) => r['court_name'] == widget.booking?['court_name']).expand((r) => '${r['time_slot']}'.split(', ')));
      });
    } catch (_) {}
  }

  Future<void> _confirm() async {
    final ref = widget.booking?['booking_ref'] as String?;
    if (ref == null || _sel == null) return;
    final iso = '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    setState(() => _busy = true);
    try {
      await _service.rescheduleBooking(ref, _opts[_sel!].time, iso);
      if (!mounted) return;
      toast('Rescheduled to ${_dateText(_date)}, ${_opts[_sel!].time}');
      Navigator.pop(context, true);
    } catch (e) {
      final msg = '$e';
      if (mounted) toast(msg.contains('just been booked') ? 'That slot is no longer free. Pick another.' : 'Could not reschedule: $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _today = DateTime(n.year, n.month, n.day);
    _stripStart = _today;
    _date = _today.add(const Duration(days: 1));
    _loadTaken();
  }

  void _shift(int days) => setState(() {
        final next = _stripStart.add(Duration(days: days));
        if (next.isBefore(_today)) return;
        _stripStart = next;
        _date = next;
        _sel = null;
      });

  String _dateText(DateTime d) => '${_days[d.weekday - 1][0]}${_days[d.weekday - 1].substring(1).toLowerCase()}, ${d.day} ${_months[d.month - 1].substring(0, 3)}';

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
              Text('#${widget.booking?['booking_ref'] ?? ''}', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
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
                  children: [
                    Text('${(widget.booking?['venues'] as Map?)?['name'] ?? 'Your booking'}', style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('${widget.booking?['court_name'] ?? ''}', style: const TextStyle(color: muted, fontSize: 10)),
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
                    children: [
                      Text('${widget.booking?['date_schedule'] ?? ''}', style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                      Text('${widget.booking?['time_slot'] ?? ''}', style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
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
            children: [
              Text('Amount Paid', style: TextStyle(color: muted, fontSize: 11)),
              Text.rich(TextSpan(children: [TextSpan(text: 'LKR ${widget.booking?['total_paid'] ?? 0} ', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)), TextSpan(text: '(Paid in Full)', style: TextStyle(color: muted, fontSize: 10))])),
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
                Expanded(child: Text('Free Reschedule Window Active • Ends at 4:00 PM', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final days = List.generate(4, (i) => _stripStart.add(Duration(days: i)));
    final nextMonth = days.last.month != days.first.month ? ' / ${_months[days.last.month - 1].substring(0, 3)}' : '';
    return Column(
      children: [
        Row(
          children: [
            Text('${_months[days.first.month - 1]} ${days.first.year}', style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text(nextMonth, style: const TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const Spacer(),
            _navBtn(Icons.chevron_left_rounded, () => _shift(-4)),
            const SizedBox(width: 8),
            _navBtn(Icons.chevron_right_rounded, () => _shift(4)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final d in days)
              _dateBox(
                d == _today ? 'TODAY' : _days[d.weekday - 1],
                '${d.day}',
                d == _today ? _days[d.weekday - 1][0] + _days[d.weekday - 1].substring(1).toLowerCase() : (d == _date ? '${_opts.where((o) => !_bookedOn(o.id, d)).length} slots' : 'Open'),
                d == _date,
                () {
                  setState(() {
                    _date = d;
                    _sel = null;
                    _taken.clear();
                  });
                  _loadTaken();
                },
              ),
          ],
        ),
      ],
    );
  }

  bool _bookedOn(int id, DateTime d) => d == _date && _taken.contains(_opts[id].time);

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle), child: Icon(icon, color: ink, size: 18)),
    );
  }

  Widget _dateBox(String day, String date, String subtitle, bool active, VoidCallback onTap) {
    return Material(
      color: active ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
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
        ),
      ),
    );
  }

  Widget _group(Widget header, List<int> ids) {
    return Column(
      children: [
        header,
        const SizedBox(height: 16),
        for (final id in ids) ...[
          _slotItem(_opts[id]),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildMorningSlots() => _group(
        Row(
          children: const [
            Icon(Icons.wb_sunny_outlined, size: 14, color: muted),
            SizedBox(width: 8),
            Text('MORNING & AFTERNOON', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ],
        ),
        [0, 1, 2],
      );

  Widget _buildEveningSlots() => _group(
        Row(
          children: const [
            Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
            SizedBox(width: 8),
            Text('EVENING PRIME SLOTS', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ],
        ),
        [3, 4, 5],
      );

  Widget _slotItem(_Opt o) {
    final isBooked = _bookedOn(o.id, _date);
    final selected = _sel == o.id;
    final fg = selected ? Colors.white : ink;
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isBooked ? null : () => setState(() => _sel = o.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: selected ? null : Border.all(color: const Color(0xFFE9EEFF)),
            boxShadow: selected ? [const BoxShadow(color: Color(0x330044FF), blurRadius: 10, offset: Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.time, style: TextStyle(color: isBooked ? muted : fg, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Court 1 • 2.0 hrs', style: TextStyle(color: selected ? Colors.white70 : muted, fontSize: 10)),
                ],
              ),
              if (isBooked)
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)), child: const Text('Booked', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600)))
              else
                Row(
                  children: [
                    Text(o.price, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: selected ? Colors.white24 : softBlue, shape: BoxShape.circle),
                      child: Icon(selected ? Icons.check_rounded : Icons.add, color: selected ? Colors.white : AppColors.primary, size: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
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
          _summaryRow(_sel == null ? 'New Slot Fee (select a slot)' : 'New Slot Fee (${_date.day} ${_months[_date.month - 1].substring(0, 3)}, ${_opts[_sel!].label})', _sel == null ? '-' : _opts[_sel!].price),
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
    final hasSel = _sel != null;
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
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(hasSel ? 'New Slot: ${_dateText(_date)} • ${_opts[_sel!].time.replaceAll(' - ', '\n- ')}' : 'Select a new slot', style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
              const Text('LKR 0 Due', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (!hasSel || _busy) ? null : _confirm,
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
