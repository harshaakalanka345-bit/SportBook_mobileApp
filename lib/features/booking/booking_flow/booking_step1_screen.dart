import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/booking_draft.dart';
import '../../../core/supabase_service.dart';
import 'booking_step2_screen.dart';
import 'booking_flow_exit.dart';
import 'booking_flow_popup.dart';

class BookingStep1Screen extends StatefulWidget {
  const BookingStep1Screen({super.key, this.venue});

  /// Venue row from the `venues` table. Falls back to a demo venue when null.
  final Map<String, dynamic>? venue;

  @override
  State<BookingStep1Screen> createState() => _BookingStep1ScreenState();
}

class _Slot {
  final int id;
  final String time;
  final int price;
  final int startHour;
  const _Slot(this.id, this.time, this.price, this.startHour);
}

class _BookingStep1ScreenState extends State<BookingStep1Screen> {
  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _slots = [
    _Slot(0, '06:00 - 07:00 AM', 2000, 6),
    _Slot(1, '07:00 - 08:00 AM', 2000, 7),
    _Slot(2, '08:00 - 09:00 AM', 2000, 8),
    _Slot(3, '09:30 - 10:30 AM', 2000, 9),
    _Slot(4, '01:00 - 02:00 PM', 2200, 13),
    _Slot(5, '03:00 - 04:00 PM', 2200, 15),
    _Slot(6, '04:00 - 05:00 PM', 2500, 16),
    _Slot(7, '06:00 - 07:00 PM', 2500, 18),
    _Slot(8, '07:00 - 08:00 PM', 2500, 19),
    _Slot(9, '08:00 - 09:00 PM', 2500, 20),
    _Slot(10, '09:00 - 10:00 PM', 2200, 21),
  ];
  static const _durations = [1.0, 1.5, 2.0, 3.0];

  final _service = SupabaseService();
  List<Map<String, dynamic>> _courts = [];
  final Set<String> _taken = {}; // "<court name>|<slot label>" for the selected date
  final Map<String, double> _surges = {}; // "<court name>|<slot label>" -> extra LKR set by the owner
  bool _loadingSlots = true;
  String? _slotError;

  Map<String, dynamic> get _venue => widget.venue ?? const {'name': 'Sports Venue', 'sport': 'Badminton', 'hourly_rate': 2500, 'area': 'Colombo'};
  double get _venueRate => (_venue['hourly_rate'] as num?)?.toDouble() ?? 2000;
  Map<String, dynamic> get _courtRow => _courts.isEmpty ? const {} : _courts[_court.clamp(0, _courts.length - 1)];
  String get _courtName => (_courtRow['name'] as String?) ?? 'Court 1';

  late final DateTime _today;
  late DateTime _selectedDate;
  late DateTime _stripStart;
  int _court = 0;
  double _hours = 2.0;
  int? _startSlot;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _today = DateTime(n.year, n.month, n.day);
    _selectedDate = _today;
    _stripStart = _today;
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    final id = _venue['id'] as String?;
    var courts = <Map<String, dynamic>>[];
    if (id != null) {
      try {
        courts = (await _service.getVenueCourts(id)).where((c) => (c['is_active'] as bool?) ?? true).toList();
      } catch (_) {}
    }
    if (courts.isEmpty) {
      courts = [
        {'name': 'Court 1', 'type': 'Standard'},
        {'name': 'Court 2', 'type': 'Standard'},
      ];
    }
    if (!mounted) return;
    setState(() => _courts = courts);
    await _loadTaken();
  }

  Future<void> _loadTaken() async {
    final id = _venue['id'] as String?;
    setState(() {
      _loadingSlots = true;
      _slotError = null;
      _taken.clear();
      _surges.clear();
    });
    if (id != null) {
      try {
        try {
          for (final s in await _service.getSurges(id, _isoDate(_selectedDate))) {
            _surges['${s['court_name']}|${s['time_slot']}'] = (s['amount'] as num).toDouble();
          }
        } catch (_) {}
        final rows = await _service.getBookedSlots(id, _isoDate(_selectedDate));
        for (final r in rows) {
          for (final label in '${r['time_slot']}'.split(', ')) {
            _taken.add('${r['court_name']}|$label');
          }
        }
      } catch (e) {
        _slotError = 'Live availability unavailable ($e)';
      }
    }
    if (mounted) setState(() => _loadingSlots = false);
  }

  String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _priceOf(_Slot s) {
    final base = (_courtRow['hourly_rate'] as num?)?.toDouble() ?? _venueRate;
    final mult = s.startHour < 12 ? 0.8 : (s.startHour < 17 ? 0.9 : 1.0);
    return ((base * mult) / 50).round() * 50 + (_surges['$_courtName|${s.time}'] ?? 0).round();
  }

  bool _isBooked(int id, DateTime d, int court) {
    final slot = _slots[id];
    if (d == _today && slot.startHour <= DateTime.now().hour) return true; // already started
    return _taken.contains('$_courtName|${slot.time}');
  }

  /// Consecutive slots covered by the current selection (stops at a booked slot or a gap).
  List<_Slot> get _selection {
    if (_startSlot == null) return [];
    final need = _hours.ceil();
    final out = <_Slot>[];
    for (var i = _startSlot!; i < _slots.length && out.length < need; i++) {
      if (_isBooked(_slots[i].id, _selectedDate, _court)) break;
      if (out.isNotEmpty && _slots[i].startHour - out.last.startHour > 1) break;
      out.add(_slots[i]);
    }
    return out;
  }

  int get _total {
    var remaining = _hours;
    var sum = 0.0;
    for (final s in _selection) {
      final portion = remaining >= 1 ? 1.0 : remaining;
      sum += _priceOf(s) * portion;
      remaining -= portion;
    }
    return sum.round();
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  String _dayLabel(DateTime d) {
    if (d == _today) return 'Today';
    if (d == _today.add(const Duration(days: 1))) return 'Tomorrow';
    final name = _days[d.weekday - 1];
    return '${name[0]}${name.substring(1).toLowerCase()}, ${_months[d.month - 1].substring(0, 3)} ${d.day}';
  }

  String _hourLabel(int h) {
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:00 ${h >= 12 ? 'PM' : 'AM'}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 90)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
      _stripStart = _selectedDate;
      _startSlot = null;
    });
    _loadTaken();
  }

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
            Text('SPORTSBOOK • BOOKING FLOW', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            Text('Select Slot & Court', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Close booking flow',
            icon: const Icon(Icons.close_rounded, color: ink),
            onPressed: () => closeBookingFlow(context),
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
                  if (_loadingSlots) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator(minHeight: 2)),
                  if (_slotError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_slotError!, style: const TextStyle(color: Colors.redAccent, fontSize: 10))),
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
          const Text(' • Slot & Court Selection', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600)),
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
                            children: [
                              const Icon(Icons.verified_rounded, size: 10, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('${_venue['environment'] ?? 'Indoor'}', style: const TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${_venue['sport'] ?? 'Sport'}'.toUpperCase(), style: const TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${_venue['name']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: muted),
                        const SizedBox(width: 4),
                        Expanded(child: Text('${_venue['address'] ?? _venue['area'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 10))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('STARTS AT', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                  Text('LKR ${_fmt(_venueRate.round())}', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
                  const Text('per hour', style: TextStyle(color: muted, fontSize: 10)),
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
                Expanded(child: Text('${_courtRow['type'] ?? 'Standard surface'}', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600))),
                Container(width: 1, height: 24, color: const Color(0xFFE9EEFF), margin: const EdgeInsets.symmetric(horizontal: 12)),
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(((_venue['amenities'] as List?)?.isNotEmpty ?? false) ? '${(_venue['amenities'] as List).first}' : 'Facilities on site', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final days = List.generate(5, (i) => _stripStart.add(Duration(days: i)));
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('${_months[_selectedDate.month - 1]} ${_selectedDate.year}', style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Text('Calendar', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final d in days)
              _dateBox(
                _days[d.weekday - 1],
                '${d.day}',
                d == _today ? 'Today' : (d == _today.add(const Duration(days: 1)) ? 'Tomorrow' : 'Open'),
                d == _selectedDate,
                isWeekend: d.weekday >= 6,
                onTap: () {
                  setState(() {
                    _selectedDate = d;
                    _startSlot = null;
                  });
                  _loadTaken();
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _dateBox(String day, String date, String subtitle, bool active, {bool isWeekend = false, VoidCallback? onTap}) {
    return Material(
      color: active ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
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
        ),
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
          children: [
            const Text('SELECT COURT', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
            Text('${_courts.length} Courts Available', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _courts.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _courtChip(i)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _courtChip(int i) {
    final active = _court == i;
    return Material(
      color: active ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _court = i;
            _startSlot = null;
          });
          _loadTaken();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: active ? null : Border.all(color: const Color(0xFFE9EEFF))),
          child: Text('${_courts[i]['name']}', textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : ink, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final mins = (_hours * 60).round();
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
                child: Text('$mins Mins', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final h in _durations) _durationBox('${h.toStringAsFixed(1)} ${h == 1 ? 'Hr' : 'Hrs'}', _hours == h, () => setState(() => _hours = h)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _durationBox(String label, bool active, VoidCallback onTap) {
    return Material(
      color: active ? AppColors.primary : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(label, style: TextStyle(color: active ? Colors.white : ink, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ),
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

  Widget _section(IconData icon, String title, String range, List<int> ids, {Widget? badge}) {
    final rows = <Widget>[];
    for (var i = 0; i < ids.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 12));
      rows.add(Row(
        children: [
          Expanded(child: _slotBox(_slots[ids[i]])),
          const SizedBox(width: 12),
          Expanded(child: i + 1 < ids.length ? _slotBox(_slots[ids[i + 1]]) : const SizedBox()),
        ],
      ));
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: muted),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            badge ?? Text(range, style: const TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        ...rows,
      ],
    );
  }

  Widget _buildMorningSlots() => _section(Icons.wb_twilight_rounded, 'Morning Slots', '06:00 AM - 12:00 PM', [0, 1, 2, 3]);

  Widget _buildAfternoonSlots() => _section(Icons.wb_sunny_outlined, 'Afternoon Slots', '12:00 PM - 05:00 PM', [4, 5, 6]);

  Widget _buildPrimeEveningSlots() => _section(
        Icons.nightlight_outlined,
        'Prime Evening / Floodlit',
        '',
        [7, 8, 9, 10],
        badge: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
          child: const Text('High Demand', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
      );

  Widget _slotBox(_Slot s) {
    final isBooked = _isBooked(s.id, _selectedDate, _court);
    final active = _selection.any((x) => x.id == s.id);
    final status = isBooked ? 'Booked' : (active ? 'Selected' : 'Open');
    return Material(
      color: active ? AppColors.primary : (isBooked ? const Color(0xFFF3F4F6) : Colors.white),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isBooked ? null : () => setState(() => _startSlot = (active && _startSlot == s.id) ? null : s.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: active || isBooked ? null : Border.all(color: const Color(0xFFE9EEFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.time, style: TextStyle(color: active ? Colors.white : (isBooked ? muted : ink), fontSize: 10, fontWeight: FontWeight.w700)),
                  if (active) const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white)
                  else if (isBooked) const Icon(Icons.lock_outline_rounded, size: 14, color: muted)
                  else const Icon(Icons.circle, size: 8, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LKR ${_fmt(_priceOf(s))}', style: TextStyle(color: active ? Colors.white : (isBooked ? muted : AppColors.primary), fontSize: 14, fontWeight: FontWeight.w800, decoration: isBooked ? TextDecoration.lineThrough : null)),
                  Text(status, style: TextStyle(color: active ? Colors.white70 : muted, fontSize: 9, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
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
    final sel = _selection;
    final hasSel = sel.isNotEmpty;
    final label = hasSel
        ? '${_dayLabel(_selectedDate)}, ${_hourLabel(sel.first.startHour)} - ${_hourLabel(sel.first.startHour + sel.length)} '
        : 'Select a time slot ';
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
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  if (hasSel) Text('(Court ${_court + 1})', style: const TextStyle(color: muted, fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)),
                child: Text('${_hours == _hours.roundToDouble() ? _hours.round() : _hours} Hours', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
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
                    children: [
                      const Text('LKR ', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(_fmt(_total), style: const TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Text(hasSel ? '${sel.length} slot${sel.length > 1 ? 's' : ''} selected' : 'No slot selected', style: const TextStyle(color: muted, fontSize: 9)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: FilledButton(
                  onPressed: !hasSel
                      ? null
                      : () {
                          BookingDraft.start(
                            venue: widget.venue,
                            courtName: _courtName,
                            courtType: '${_courtRow['type'] ?? ''}',
                            date: _selectedDate,
                            slotLabels: sel.map((s) => s.time).toList(),
                            timeRange: '${_hourLabel(sel.first.startHour)} - ${_hourLabel(sel.first.startHour + sel.length)}',
                            hours: _hours,
                            courtFee: _total.toDouble(),
                            startAt: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, sel.first.startHour),
                            endAt: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, sel.first.startHour + sel.length),
                          );
                          showBookingStepPopup(context, const BookingStep2Screen());
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
