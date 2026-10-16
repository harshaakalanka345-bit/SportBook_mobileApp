import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import 'admin_bookings_screen.dart';
import 'admin_profile_screen.dart';
import 'walk_in_booking_screen.dart';

/// Owner schedule: per-court, per-day timeline with block / lock / surge / walk-in / extend / inspect tools.
class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _months = [
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

  final _service = SupabaseService();
  late final DateTime _today;
  late DateTime _stripStart;
  late DateTime _date;

  List<Map<String, dynamic>> _venues = [];
  int _venueIndex = 0;
  List<Map<String, dynamic>> _courts = [];
  int _courtIndex = 0;
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _blocks = [];
  Map<String, double> _surges = {};
  Map<String, Map<String, dynamic>> _customers = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _today = DateTime(n.year, n.month, n.day);
    _stripStart = _today;
    _date = _today;
    _loadVenues();
  }

  Map<String, dynamic>? get _venue =>
      _venues.isEmpty ? null : _venues[_venueIndex];
  String get _venueId => _venue!['id'] as String;
  Map<String, dynamic>? get _court =>
      _courts.isEmpty ? null : _courts[_courtIndex];
  String get _courtName => _court?['name'] as String? ?? '';
  double get _courtRate =>
      (_court?['hourly_rate'] as num?)?.toDouble() ??
      (_venue?['hourly_rate'] as num?)?.toDouble() ??
      2000;
  List<SlotDef> get _venueSlots => kSlots
      .where(
        (slot) =>
            slotWithinVenueHours(slot, _venue ?? const <String, dynamic>{}),
      )
      .toList();

  Future<void> _loadVenues() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final venues = await _service.getMyVenues();
      if (!mounted) return;
      _venues = venues;
      if (_venueIndex >= venues.length) _venueIndex = 0;
      if (venues.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      await _loadCourts();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadCourts() async {
    final courts = await _service.getVenueCourts(_venueId);
    if (!mounted) return;
    _courts = courts;
    if (_courtIndex >= courts.length) _courtIndex = 0;
    await _loadDay();
  }

  Future<void> _loadDay() async {
    if (_venue == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final iso = isoDate(_date);
      final results = await Future.wait([
        _service.getVenueBookingsOn(_venueId, iso),
        _service.getSlotBlocks(_venueId, iso),
        _service.getSurges(_venueId, iso),
      ]);
      final bookings = results[0];
      final ids = bookings
          .map((b) => b['user_id'])
          .whereType<String>()
          .toSet()
          .toList();
      final customers = await _service.getCustomers(ids);
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _blocks = results[1];
        _surges = {
          for (final s in results[2])
            '${s['court_name']}|${s['time_slot']}': (s['amount'] as num)
                .toDouble(),
        };
        _customers = customers;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------------------------------------------------ derived data

  List<Map<String, dynamic>> get _courtBookings =>
      _bookings.where((b) => b['court_name'] == _courtName).toList();
  List<Map<String, dynamic>> get _courtBlocks =>
      _blocks.where((b) => b['court_name'] == _courtName).toList();

  Map<String, dynamic>? _bookingFor(SlotDef s) {
    for (final b in _courtBookings) {
      if ('${b['time_slot']}'.split(', ').contains(s.label)) return b;
    }
    return null;
  }

  Map<String, dynamic>? _blockFor(SlotDef s) {
    for (final b in _courtBlocks) {
      if (b['time_slot'] == s.label) return b;
    }
    return null;
  }

  double _surgeFor(SlotDef s) => _surges['$_courtName|${s.label}'] ?? 0;
  double _priceOf(SlotDef s) => s.priceFor(_courtRate) + _surgeFor(s);

  bool _isPast(SlotDef s) => s.endOn(_date).isBefore(DateTime.now());
  bool _isLive(SlotDef s) {
    final n = DateTime.now();
    return s.startOn(_date).isBefore(n) && s.endOn(_date).isAfter(n);
  }

  List<_Row> get _rows {
    final rows = <_Row>[];
    final seenBookings = <String>{};
    var i = 0;
    while (i < _venueSlots.length) {
      final s = _venueSlots[i];
      final booking = _bookingFor(s);
      final block = _blockFor(s);
      if (booking != null) {
        final ref = '${booking['booking_ref']}';
        if (seenBookings.add(ref)) {
          final labels = '${booking['time_slot']}'.split(', ');
          rows.add(
            _Row.booking(
              booking,
              _venueSlots.where((k) => labels.contains(k.label)).toList(),
            ),
          );
        }
        i++;
      } else if (block != null) {
        final group = [s];
        final ids = ['${block['id']}'];
        var j = i + 1;
        while (j < _venueSlots.length) {
          final nb = _blockFor(_venueSlots[j]);
          if (nb == null ||
              nb['reason'] != block['reason'] ||
              _bookingFor(_venueSlots[j]) != null) {
            break;
          }
          group.add(_venueSlots[j]);
          ids.add('${nb['id']}');
          j++;
        }
        rows.add(_Row.block(block, group, ids));
        i = j;
      } else {
        rows.add(_Row.open(s));
        i++;
      }
    }
    return rows;
  }

  // ------------------------------------------------------------ actions

  void _snack(String m) => toast(m);

  Future<void> _guard(Future<void> Function() action, {String? ok}) async {
    try {
      await action();
      if (ok != null) _snack(ok);
      await _loadDay();
    } catch (e) {
      _snack('Action failed: $e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _today.subtract(const Duration(days: 30)),
      lastDate: _today.add(const Duration(days: 180)),
    );
    if (picked == null) return;
    setState(() {
      _date = DateTime(picked.year, picked.month, picked.day);
      _stripStart = _date;
    });
    _loadDay();
  }

  Future<void> _blockForClean() async {
    var reason = 'Cleaning';
    var from = 0;
    if (_venueSlots.isEmpty) {
      _snack('Set valid opening hours before blocking time slots.');
      return;
    }
    var to = _venueSlots.length - 1;
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(
            'Close $_courtName',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reason',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final r in const [
                      'Cleaning',
                      'Maintenance',
                      'Private event',
                      'Other',
                    ])
                      ChoiceChip(
                        label: Text(r),
                        selected: reason == r,
                        onSelected: (_) => setLocal(() => reason = r),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: from,
                        decoration: const InputDecoration(labelText: 'From'),
                        items: [
                          for (var i = 0; i < _venueSlots.length; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(
                                _venueSlots[i].label.split(' - ').first,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                        onChanged: (v) => setLocal(() {
                          from = v ?? 0;
                          if (to < from) to = from;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: to,
                        decoration: const InputDecoration(
                          labelText: 'Until end of',
                        ),
                        items: [
                          for (var i = from; i < _venueSlots.length; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(
                                _venueSlots[i].label.split(' - ').last,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                        onChanged: (v) => setLocal(() => to = v ?? to),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: note,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'e.g. Floor polishing, work ticket #409',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Slots that already have a booking are skipped. Players cannot book blocked slots.',
                  style: TextStyle(
                    color: muted.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Close court'),
            ),
          ],
        ),
      ),
    );
    final n = note.text.trim();
    note.dispose();
    if (ok != true) return;
    final targets = _venueSlots
        .sublist(from, to + 1)
        .where((s) => _bookingFor(s) == null)
        .map((s) => s.label)
        .toList();
    if (targets.isEmpty) {
      _snack('Every selected slot already has a booking.');
      return;
    }
    await _guard(
      () => _service.addSlotBlocks(
        venueId: _venueId,
        courtName: _courtName,
        dateIso: isoDate(_date),
        slotLabels: targets,
        reason: reason,
        note: n.isEmpty ? null : n,
      ),
      ok: '$_courtName closed for $reason (${targets.length} slots)',
    );
  }

  Future<void> _setSurge() async {
    final amount = TextEditingController();
    var scope = 'evening'; // evening | all | clear
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text(
            'Set Surge Rate',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Extra charge per slot (LKR)',
                    prefixText: '+ LKR ',
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: scope,
                  onChanged: (value) {
                    if (value != null) setLocal(() => scope = value);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: 'evening',
                        title: const Text('Peak slots only (4 PM onwards)'),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: 'all',
                        title: const Text('All open slots today'),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: 'clear',
                        title: const Text('Remove surge from this court today'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    final value = double.tryParse(amount.text.trim()) ?? 0;
    amount.dispose();
    if (ok != true) return;
    if (scope != 'clear' && value <= 0) {
      _snack('Enter a surge amount above 0.');
      return;
    }
    final labels =
        (scope == 'clear'
                ? _venueSlots
                : (scope == 'evening'
                      ? _venueSlots.where((s) => s.startHour >= 16)
                      : _venueSlots))
            .where(
              (s) =>
                  scope == 'clear' || (_bookingFor(s) == null && !_isPast(s)),
            )
            .map((s) => s.label)
            .toList();
    await _guard(
      () => _service.setSurge(
        venueId: _venueId,
        courtName: _courtName,
        dateIso: isoDate(_date),
        slotLabels: labels,
        amount: scope == 'clear' ? 0 : value,
      ),
      ok: scope == 'clear'
          ? 'Surge removed'
          : 'Surge +LKR ${value.toStringAsFixed(0)} applied to ${labels.length} slots',
    );
  }

  Future<void> _lockSlot(SlotDef s) async {
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Lock ${s.label}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: note,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'e.g. Reserved for coaching',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lock slot'),
          ),
        ],
      ),
    );
    final n = note.text.trim();
    note.dispose();
    if (ok != true) return;
    await _guard(
      () => _service.addSlotBlocks(
        venueId: _venueId,
        courtName: _courtName,
        dateIso: isoDate(_date),
        slotLabels: [s.label],
        reason: 'Locked',
        note: n.isEmpty ? null : n,
      ),
      ok: 'Slot locked',
    );
  }

  Future<void> _unblock(_Row r) async {
    await _guard(
      () => _service.removeSlotBlocks(r.blockIds),
      ok: 'Slot unblocked - live sync restored',
    );
  }

  Future<void> _openWalkIn({int? startSlotId}) async {
    if (_venue == null) return;
    if (_courts.isEmpty) {
      _snack('Add a court to this complex first (Owner Profile).');
      return;
    }
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalkInBookingScreen(
          venue: _venue!,
          courts: _courts,
          date: _date,
          courtName: _courtName,
          startSlotId: startSlotId,
        ),
      ),
    );
    if (created == true) _loadDay();
  }

  Future<void> _extend(
    Map<String, dynamic> booking,
    List<SlotDef> slots,
  ) async {
    final lastIdx = _venueSlots.indexOf(slots.last);
    if (lastIdx + 1 >= _venueSlots.length) {
      _snack('No later slot to extend into.');
      return;
    }
    final next = _venueSlots[lastIdx + 1];
    if (next.startHour - slots.last.startHour > 1 ||
        _bookingFor(next) != null ||
        _blockFor(next) != null ||
        _isPast(next)) {
      _snack(
        'The next slot (${next.label}) is not free, so this session cannot be extended.',
      );
      return;
    }
    final extra = _priceOf(next);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Extend Slot',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Add ${next.label} to ${booking['booking_ref']}?\nExtra charge: LKR ${extra.toStringAsFixed(0)} (collect at the counter).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Extend'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final total = ((booking['total_paid'] as num?)?.toDouble() ?? 0) + extra;
    await _guard(
      () => _service.extendBooking(
        '${booking['booking_ref']}',
        newTimeSlot: '${booking['time_slot']}, ${next.label}',
        newTotal: total,
      ),
      ok: 'Extended to ${next.label}',
    );
  }

  String _customerName(Map<String, dynamic> b) {
    final guest = b['guest_name'] as String?;
    if (guest != null && guest.isNotEmpty) return guest;
    final c = _customers['${b['user_id']}'];
    return (c?['full_name'] as String?) ??
        (b['user_id'] == null ? 'Guest' : 'SportsBook member');
  }

  Future<void> _inspect(Map<String, dynamic> b) async {
    final ref = '${b['booking_ref']}';
    final pin = '${b['qr_turnstile_pin']}';
    final status = '${b['status']}';
    final payment = SupabaseService.bookingPaymentDetails(b);
    final dueAtVenue = SupabaseService.bookingDueAtVenue(b);
    final amount = SupabaseService.bookingAmountForDisplay(b);
    final paymentMethod = dueAtVenue
        ? 'Due at venue'
        : '${b['payment_method'] ?? payment?['payment_method'] ?? (b['source'] == 'walk_in' ? 'counter' : 'app payment')}';
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Inspect Ticket',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: 'SPORTSBOOK|$ref|$pin',
                size: 150,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
              Text(
                ref,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'PIN $pin',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                '${_customerName(b)}${(b['guest_phone'] as String?)?.isNotEmpty ?? false ? ' • ${b['guest_phone']}' : ((_customers['${b['user_id']}']?['phone']) != null ? ' • ${_customers['${b['user_id']}']!['phone']}' : '')}\n'
                '${b['court_name']} • ${b['time_slot']}\n'
                'LKR ${amount.toStringAsFixed(0)} • $paymentMethod\n'
                'Status: $status • ${b['source'] == 'walk_in' ? 'Walk-in' : 'App booking'}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          if (status != 'Checked-in')
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text(
                'Cancel booking',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          if (status != 'Checked-in')
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'checkin'),
              child: const Text('Check in'),
            ),
        ],
      ),
    );
    if (action == 'checkin')
      await _guard(
        () => _service.setBookingStatus(ref, 'Checked-in'),
        ok: 'Checked in',
      );
    if (action == 'cancel')
      await _guard(
        () => _service.cancelBooking(ref),
        ok: 'Booking cancelled - slot is open again',
      );
  }

  // ------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadVenues,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              _topBar(),
              const SizedBox(height: 14),
              if (_error != null)
                _message(
                  Icons.cloud_off,
                  'Could not load the schedule',
                  _error!,
                  FilledButton(
                    onPressed: _loadVenues,
                    child: const Text('Retry'),
                  ),
                )
              else if (!_loading && _venue == null)
                _message(
                  Icons.add_business_outlined,
                  'No complex yet',
                  'Register your court complex to manage its schedule.',
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminProfileScreen(),
                      ),
                    ).then((_) => _loadVenues()),
                    child: const Text('Open Owner Profile'),
                  ),
                )
              else ...[
                _venueBar(),
                const SizedBox(height: 14),
                _dateStrip(),
                const SizedBox(height: 14),
                if (_courts.isEmpty && !_loading)
                  _message(
                    Icons.sports_tennis,
                    'No courts',
                    'Add a court in Owner Profile to start scheduling.',
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminProfileScreen(),
                        ),
                      ).then((_) => _loadVenues()),
                      child: const Text('Add a court'),
                    ),
                  )
                else ...[
                  _courtChips(),
                  const SizedBox(height: 14),
                  _courtCard(),
                  const SizedBox(height: 22),
                  _timeSlots(),
                  const SizedBox(height: 18),
                  _walkInCta(),
                ],
              ],
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'SPORTSBOOK OPS • SCHEDULE',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, Widget action) =>
      Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(icon, size: 40, color: muted),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            action,
          ],
        ),
      );

  Widget _topBar() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.event_note_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPORTSBOOK OPS',
              style: TextStyle(
                color: muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Schedule',
              style: TextStyle(
                color: ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EDFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.circle, color: AppColors.primary, size: 7),
            SizedBox(width: 5),
            Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
        ).then((_) => _loadVenues()),
        child: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
      ),
    ],
  );

  Widget _venueBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _venues.length > 1
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _venueIndex,
                    isExpanded: true,
                    items: [
                      for (var i = 0; i < _venues.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(
                            '${_venues[i]['name']}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      _venueIndex = v ?? 0;
                      _courtIndex = 0;
                      _loadCourts();
                    },
                  ),
                )
              : Text(
                  '${_venue?['name'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        IconButton(
          tooltip: 'All bookings',
          icon: const Icon(Icons.tune_rounded, color: ink),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminBookingsScreen()),
          ),
        ),
      ],
    ),
  );

  Widget _dateStrip() {
    final days = List.generate(7, (i) => _stripStart.add(Duration(days: i)));
    return Column(
      children: [
        Row(
          children: [
            Text(
              '${_months[_date.month - 1]} ${_date.year}',
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(
                  () => _stripStart = _stripStart.subtract(
                    const Duration(days: 7),
                  ),
                );
              },
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              onPressed: () {
                setState(
                  () => _stripStart = _stripStart.add(const Duration(days: 7)),
                );
              },
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: const Text('Calendar'),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final d in days)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() => _date = d);
                      _loadDay();
                    },
                    child: Container(
                      width: 62,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isoDate(d) == isoDate(_date)
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE9EEFF)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isoDate(d) == isoDate(_today)
                                ? 'TODAY'
                                : _days[d.weekday - 1],
                            style: TextStyle(
                              color: isoDate(d) == isoDate(_date)
                                  ? Colors.white70
                                  : muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${d.day}',
                            style: TextStyle(
                              color: isoDate(d) == isoDate(_date)
                                  ? Colors.white
                                  : ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _courtChips() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var i = 0; i < _courts.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                Icons.sports_tennis_rounded,
                size: 16,
                color: _courtIndex == i ? Colors.white : AppColors.primary,
              ),
              label: Text(
                '${_courts[i]['name']}${(_courts[i]['type'] as String?)?.isNotEmpty ?? false ? ' • ${_courts[i]['type']}' : ''}',
              ),
              selected: _courtIndex == i,
              showCheckmark: false,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _courtIndex == i ? Colors.white : ink,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => setState(() => _courtIndex = i),
            ),
          ),
      ],
    ),
  );

  Widget _courtCard() {
    final blockedSlots = _venueSlots.where((s) => _blockFor(s) != null).length;
    final bookedSlots = _venueSlots.where((s) => _bookingFor(s) != null).length;
    final available = _venueSlots.length - blockedSlots;
    final pct = available == 0 ? 0 : (bookedSlots * 100 / available).round();
    final closed = _venueSlots.isNotEmpty && blockedSlots == _venueSlots.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: closed ? Colors.orange : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_courtName.toUpperCase()} • ${closed ? 'CLOSED' : 'ACTIVE'}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$pct% BOOKED',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_court?['type'] ?? 'Court'}',
            style: const TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$bookedSlots of $available slots filled • from LKR ${_courtRate.toStringAsFixed(0)}/hr',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: closed ? null : _blockForClean,
                  icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                  label: const Text('Block for Clean'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ink,
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _setSurge,
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Set Surge Rate'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_courtBlocks.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _guard(
                  () => _service.removeSlotBlocks(
                    _courtBlocks.map((b) => '${b['id']}').toList(),
                  ),
                  ok: 'All blocks removed from $_courtName',
                ),
                child: const Text(
                  'Reopen whole court',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _timeSlots() {
    final rows = _rows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Time Slots',
              style: TextStyle(
                color: ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_courtBookings.length} scheduled',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final r in rows) _rowCard(r),
      ],
    );
  }

  String _range(List<SlotDef> s) =>
      '${shortTime(s.first.startOn(_date))} – ${shortTime(s.last.endOn(_date))}';

  Widget _badge(String text, Color color, {IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );

  Widget _cardShell({required Widget child, Color? accent}) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border(
        top: accent != null
            ? BorderSide(color: accent, width: 4)
            : const BorderSide(color: Color(0xFFE9EEFF)),
        left: const BorderSide(color: Color(0xFFE9EEFF)),
        right: const BorderSide(color: Color(0xFFE9EEFF)),
        bottom: const BorderSide(color: Color(0xFFE9EEFF)),
      ),
    ),
    child: child,
  );

  Widget _rowCard(_Row r) {
    switch (r.kind) {
      case _Kind.open:
        final s = r.slots.first;
        final past = _isPast(s);
        final surge = _surgeFor(s);
        return _cardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _range(r.slots),
                      style: const TextStyle(
                        color: ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _badge(
                    past ? 'ELAPSED' : 'OPEN',
                    past ? muted : Colors.green,
                    icon: past ? Icons.history : Icons.lock_open_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${surge > 0 ? 'Surge rate' : 'Standard rate'}: LKR ${_priceOf(s).toStringAsFixed(0)}${surge > 0 ? ' (incl. +${surge.toStringAsFixed(0)})' : ''}',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              if (!past) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _soft(
                        'Lock Slot',
                        Icons.lock_outline,
                        () => _lockSlot(s),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _soft(
                        'Reserve Walk-in',
                        Icons.person_add_alt_1_outlined,
                        () => _openWalkIn(startSlotId: s.id),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      case _Kind.booking:
        final b = r.booking!;
        final last = r.slots.last;
        final done =
            _isPast(last) || b['status'] == 'Checked-in' && _isPast(last);
        final live = !done && r.slots.any(_isLive);
        final checkedIn = b['status'] == 'Checked-in';
        final label = done
            ? 'COMPLETED'
            : (live ? 'IN PROGRESS' : (checkedIn ? 'CHECKED IN' : 'BOOKED'));
        final color = done
            ? muted
            : (live
                  ? AppColors.primary
                  : (checkedIn ? Colors.green : Colors.orange));
        final surgeTotal = r.slots.fold<double>(
          0,
          (sum, s) => sum + _surgeFor(s),
        );
        return _cardShell(
          accent: live ? AppColors.primary : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _range(r.slots),
                      style: const TextStyle(
                        color: ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _badge(
                    label,
                    color,
                    icon: done
                        ? Icons.check_circle_outline
                        : (live ? Icons.circle : Icons.schedule),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _customerName(b),
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (b['source'] == 'walk_in')
                    _badge('WALK-IN', AppColors.primary),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${b['booking_ref']}${surgeTotal > 0 ? ' • includes surge +${surgeTotal.toStringAsFixed(0)}' : ''}',
                        style: const TextStyle(color: muted, fontSize: 11),
                      ),
                    ),
                    Text(
                      'LKR ${b['total_paid']}',
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (!done) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _soft(
                        'Inspect Ticket',
                        Icons.qr_code_scanner,
                        () => _inspect(b),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _extend(b, r.slots),
                        icon: const Icon(Icons.more_time, size: 16),
                        label: const Text('Extend Slot'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _inspect(b),
                    child: const Text('View ticket'),
                  ),
                ),
            ],
          ),
        );
      case _Kind.block:
        final blk = r.block!;
        final reason = '${blk['reason']}';
        final note = (blk['note'] as String?) ?? '';
        return _cardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _range(r.slots),
                      style: const TextStyle(
                        color: ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _badge(
                    reason == 'Locked'
                        ? 'LOCKED'
                        : (reason == 'Hold' ? 'ON HOLD' : 'BLOCKED'),
                    Colors.orange,
                    icon: Icons.block,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                reason == 'Cleaning'
                    ? 'Court closed for cleaning'
                    : (reason == 'Hold'
                          ? 'Walk-in slot hold (expires in minutes)'
                          : reason),
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              if (note.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(color: ink, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _soft(
                  'Unblock Slot & Restore Live Sync',
                  Icons.lock_open,
                  () => _unblock(r),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _soft(
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 16),
    label: Text(label, overflow: TextOverflow.ellipsis),
    style: OutlinedButton.styleFrom(
      foregroundColor: color ?? ink,
      backgroundColor: softBlue,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  Widget _walkInCta() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: () => _openWalkIn(),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Quick Walk-in Reservation',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 14, color: AppColors.primary),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Instant gate pass issued with a QR code and PIN',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

enum _Kind { open, booking, block }

class _Row {
  _Row.open(SlotDef s)
    : kind = _Kind.open,
      slots = [s],
      booking = null,
      block = null,
      blockIds = const [];

  _Row.booking(Map<String, dynamic> b, this.slots)
    : kind = _Kind.booking,
      booking = b,
      block = null,
      blockIds = const [];

  _Row.block(Map<String, dynamic> b, this.slots, this.blockIds)
    : kind = _Kind.block,
      booking = null,
      block = b;

  final _Kind kind;
  final List<SlotDef> slots;
  final Map<String, dynamic>? booking;
  final Map<String, dynamic>? block;
  final List<String> blockIds;
}
