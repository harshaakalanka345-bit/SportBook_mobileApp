import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';

class ModifySlotScreen extends StatefulWidget {
  const ModifySlotScreen({super.key, this.booking});

  final Map<String, dynamic>? booking;

  @override
  State<ModifySlotScreen> createState() => _ModifySlotScreenState();
}

class _ModifySlotScreenState extends State<ModifySlotScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);

  final _service = SupabaseService();
  late final DateTime _today;
  late DateTime _date;
  final Set<String> _taken = {};
  String? _availabilityError;
  String? _selectedTime;
  bool _loadingAvailability = true;
  bool _loading = false;

  Map<String, dynamic> get _venue => widget.booking?['venues'] is Map
      ? Map<String, dynamic>.from(widget.booking!['venues'] as Map)
      : const {};

  int get _slotCount {
    final raw = '${widget.booking?['time_slot'] ?? ''}'.trim();
    if (raw.isEmpty) return 1;
    final pieces = raw
        .split(',')
        .where((label) => label.trim().isNotEmpty)
        .toList();
    if (pieces.length > 1) return pieces.length.clamp(1, 4);
    final range = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)?\s*-\s*(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (range == null) return 1;
    int toMinutes(String hourText, String minuteText, String? period) {
      var hour = int.tryParse(hourText) ?? 0;
      final minute = int.tryParse(minuteText) ?? 0;
      if (period != null) {
        final pm = period.toUpperCase() == 'PM';
        hour = hour % 12 + (pm ? 12 : 0);
      }
      return hour * 60 + minute;
    }

    final start = toMinutes(
      range.group(1)!,
      range.group(2)!,
      range.group(3) ?? range.group(6),
    );
    final end = toMinutes(range.group(4)!, range.group(5)!, range.group(6));
    final minutes = end > start ? end - start : end + 24 * 60 - start;
    return (minutes / 60).round().clamp(1, 4);
  }

  String get _currentTime =>
      '${widget.booking?['time_slot'] ?? 'Not available'}';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _date = _today;
    _loadTaken();
  }

  String _iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (date == _today) return 'Today, ${date.day} ${months[date.month - 1]}';
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  dynamic _reservationAmount() {
    final booking = widget.booking ?? const <String, dynamic>{};
    final addons = booking['addons'];
    if (addons is List) {
      for (final item in addons) {
        if (item is Map && item['payment_status'] == 'Due at venue') {
          return item['full_total'] ?? booking['total_paid'];
        }
      }
    }
    return booking['total_paid'];
  }

  Future<void> _loadTaken() async {
    final venueId = widget.booking?['venue_id']?.toString();
    if (venueId == null || venueId.isEmpty) {
      setState(() {
        _availabilityError = 'This booking has no venue reference.';
        _loadingAvailability = false;
      });
      return;
    }
    setState(() {
      _loadingAvailability = true;
      _availabilityError = null;
      _taken.clear();
      _selectedTime = null;
    });
    try {
      final rows = await _service.getBookedSlots(venueId, _iso(_date));
      if (!mounted) return;
      setState(() {
        for (final row in rows) {
          if ('${row['court_name']}' != '${widget.booking?['court_name']}')
            continue;
          _taken.addAll(
            '${row['time_slot']}'.split(', ').map((label) => label.trim()),
          );
        }
      });
    } catch (error) {
      if (mounted)
        setState(
          () => _availabilityError =
              'Could not load live availability. Refresh to try again.',
        );
    } finally {
      if (mounted) setState(() => _loadingAvailability = false);
    }
  }

  List<({String label, String value, DateTime start, List<SlotDef> slots})>
  get _options {
    final result =
        <({String label, String value, DateTime start, List<SlotDef> slots})>[];
    final slots = kSlots;
    for (var index = 0; index + _slotCount <= slots.length; index++) {
      final window = slots.skip(index).take(_slotCount).toList();
      var consecutive = true;
      for (var part = 1; part < window.length; part++) {
        if (window[part]
                .startOn(_date)
                .difference(window[part - 1].startOn(_date)) !=
            const Duration(hours: 1)) {
          consecutive = false;
          break;
        }
      }
      if (!consecutive ||
          window.any((slot) => !slotWithinVenueHours(slot, _venue)))
        continue;
      final start = window.first.startOn(_date);
      if (_date == _today && !start.isAfter(DateTime.now())) continue;
      final end = start.add(Duration(hours: _slotCount));
      result.add((
        label: '${shortTime(start)} – ${shortTime(end)}',
        value: window.map((slot) => slot.label).join(', '),
        start: start,
        slots: window,
      ));
    }
    return result;
  }

  ({int start, int end})? _parseRange(String raw) {
    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)?\s*-\s*(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) return null;
    int minutes(String hourText, String minuteText, String? period) {
      var hour = int.tryParse(hourText) ?? 0;
      final minute = int.tryParse(minuteText) ?? 0;
      if (period != null) {
        hour = hour % 12 + (period.toUpperCase() == 'PM' ? 12 : 0);
      }
      return hour * 60 + minute;
    }

    final start = minutes(
      match.group(1)!,
      match.group(2)!,
      match.group(3) ?? match.group(6),
    );
    var end = minutes(match.group(4)!, match.group(5)!, match.group(6));
    if (end <= start) end += 24 * 60;
    return (start: start, end: end);
  }

  bool _isTaken(
    ({String label, String value, DateTime start, List<SlotDef> slots}) option,
  ) {
    for (final blocked in _taken) {
      if (option.slots.any((slot) => slot.label == blocked)) return true;
      final range = _parseRange(blocked);
      if (range == null) continue;
      for (final slot in option.slots) {
        final start = slot.startHour * 60 + slot.startMinute;
        if (range.start < start + 60 && range.end > start) return true;
      }
    }
    return false;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 90)),
    );
    if (picked == null) return;
    setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    await _loadTaken();
  }

  Future<void> _reschedule() async {
    final ref = widget.booking?['booking_ref']?.toString();
    if (ref == null || _selectedTime == null) return;
    setState(() => _loading = true);
    try {
      await _service.rescheduleBooking(ref, _selectedTime!, _iso(_date));
      if (!mounted) return;
      toast('Booking rescheduled to ${_dateLabel(_date)}.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) toast('Could not reschedule: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueName = '${_venue['name'] ?? 'Sports venue'}';
    final court = '${widget.booking?['court_name'] ?? 'Court'}';
    final amount = _reservationAmount();
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: const Text(
          'Modify booking',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
        children: [
          _bookingCard(venueName, court, amount),
          const SizedBox(height: 23),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Choose a new date',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_outlined, size: 17),
                label: const Text('Pick date'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _dateLabel(_date),
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 15),
          _loadingAvailability
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _availabilityError != null
              ? _errorCard()
              : _options.isEmpty
              ? _emptyCard()
              : Column(
                  children: [
                    for (final option in _options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _slotCard(option),
                      ),
                  ],
                ),
          const SizedBox(height: 12),
          _infoCard(amount),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: FilledButton.icon(
            onPressed:
                _selectedTime == null ||
                    _loading ||
                    _loadingAvailability ||
                    _availabilityError != null
                ? null
                : _reschedule,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_loading ? 'Updating…' : 'Confirm new time'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(
    String venueName,
    String court,
    dynamic amount,
  ) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9EEFF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venueName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    court,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _tag(
              Icons.calendar_today_outlined,
              '${widget.booking?['date_schedule'] ?? 'Date not set'}',
            ),
            _tag(Icons.access_time_rounded, _currentTime),
            _tag(
              Icons.confirmation_number_outlined,
              '#${widget.booking?['booking_ref'] ?? ''}',
            ),
          ],
        ),
        if (amount != null) ...[
          const SizedBox(height: 12),
          Text(
            'Recorded booking amount: LKR ${amount is num ? amount.toStringAsFixed(2) : amount}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _slotCard(
    ({String label, String value, DateTime start, List<SlotDef> slots}) option,
  ) {
    final taken = _isTaken(option);
    final selected = _selectedTime == option.value;
    return Material(
      color: taken
          ? const Color(0xFFF4F5F8)
          : (selected ? AppColors.primary : Colors.white),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: taken || _loadingAvailability || _availabilityError != null
            ? null
            : () => setState(() => _selectedTime = option.value),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE9EEFF),
            ),
          ),
          child: Row(
            children: [
              Icon(
                taken
                    ? Icons.event_busy_outlined
                    : (selected
                          ? Icons.check_circle_rounded
                          : Icons.access_time_rounded),
                color: taken
                    ? _muted
                    : (selected ? Colors.white : AppColors.primary),
                size: 19,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    color: taken ? _muted : (selected ? Colors.white : _ink),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                taken
                    ? 'Booked'
                    : (_selectedTime == option.value
                          ? 'Selected'
                          : '${_slotCount} hr${_slotCount == 1 ? '' : 's'}'),
                style: TextStyle(
                  color: taken ? _muted : (selected ? Colors.white70 : _muted),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(dynamic amount) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _softBlue,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            amount == null
                ? 'The current booking amount is not recorded. Confirm any price change with the venue.'
                : 'The booking keeps its recorded amount${_selectedTime == null ? '' : ' (${amount is num ? 'LKR ${amount.toStringAsFixed(2)}' : 'LKR $amount'})'}. Confirm any price adjustment with the venue.',
            style: const TextStyle(color: _muted, fontSize: 11, height: 1.35),
          ),
        ),
      ],
    ),
  );

  Widget _errorCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        Text(
          _availabilityError!,
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _loadTaken,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh availability'),
        ),
      ],
    ),
  );

  Widget _emptyCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Text(
      'No time slots are available for this court on this date.',
      style: TextStyle(color: _muted, fontSize: 12),
    ),
  );

  Widget _tag(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: _softBlue,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
