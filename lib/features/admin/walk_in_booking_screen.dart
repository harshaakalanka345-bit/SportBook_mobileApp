import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/actions.dart';
import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';

/// Counter (walk-in) booking: identify the athlete, pick court & time, add gear, settle payment, issue a gate pass.
/// Pops with `true` when a booking was created.
class WalkInBookingScreen extends StatefulWidget {
  const WalkInBookingScreen({
    super.key,
    required this.venue,
    required this.courts,
    required this.date,
    this.courtName,
    this.startSlotId,
  });

  final Map<String, dynamic> venue;
  final List<Map<String, dynamic>> courts;
  final DateTime date;
  final String? courtName;
  final int? startSlotId;

  @override
  State<WalkInBookingScreen> createState() => _WalkInBookingScreenState();
}

class _WalkInBookingScreenState extends State<WalkInBookingScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  static const _durations = [1.0, 1.5, 2.0, 3.0];

  final _service = SupabaseService();
  final _phone = TextEditingController();
  final _guestName = TextEditingController();

  // athlete
  Map<String, dynamic>? _customer;
  bool _guest = false;
  bool _looking = false;
  String? _lookupMessage;

  // court & time
  late int _court;
  double _hours = 1.0;
  int? _startSlot;
  final Set<String> _taken = {};
  final Map<String, double> _surges = {};
  bool _loadingSlots = true;

  // gear
  int _rackets = 0;
  int _shuttles = 0;
  int _shoes = 0;
  static const _racketFee = 350;
  static const _shuttleFee = 450;
  static const _shoeFee = 250;

  // settlement
  String _payment = 'cash';
  bool _saving = false;
  bool _holding = false;
  List<String> _holdLabels = [];

  String get _venueId => widget.venue['id'] as String;
  double get _venueRate =>
      (widget.venue['hourly_rate'] as num?)?.toDouble() ?? 2000;
  Map<String, dynamic> get _courtRow =>
      widget.courts.isEmpty ? const {} : widget.courts[_court];
  String get _courtName => (_courtRow['name'] as String?) ?? 'Court 1';
  double get _courtRate =>
      (_courtRow['hourly_rate'] as num?)?.toDouble() ?? _venueRate;

  @override
  void initState() {
    super.initState();
    final i = widget.courts.indexWhere((c) => c['name'] == widget.courtName);
    _court = i < 0 ? 0 : i;
    _startSlot = widget.startSlotId;
    _loadAvailability();
  }

  @override
  void dispose() {
    _phone.dispose();
    _guestName.dispose();
    super.dispose();
  }

  bool _isPast(SlotDef s) =>
      isoDate(widget.date) == isoDate(DateTime.now()) &&
      s.endOn(widget.date).isBefore(DateTime.now());

  bool _isTaken(SlotDef s) =>
      !slotWithinVenueHours(s, widget.venue) ||
      _taken.contains('$_courtName|${s.label}') ||
      _isPast(s);

  Future<void> _loadAvailability() async {
    setState(() => _loadingSlots = true);
    try {
      final date = isoDate(widget.date);
      final rows = await _service.getBookedSlots(_venueId, date);
      final surges = await _service.getSurges(_venueId, date);
      if (!mounted) return;
      setState(() {
        _taken
          ..clear()
          ..addAll(
            rows.expand(
              (r) => '${r['time_slot']}'
                  .split(', ')
                  .map((l) => '${r['court_name']}|$l'),
            ),
          );
        _surges
          ..clear()
          ..addEntries(
            surges.map(
              (s) => MapEntry(
                '${s['court_name']}|${s['time_slot']}',
                (s['amount'] as num).toDouble(),
              ),
            ),
          );
      });
    } catch (e) {
      toast('Could not load availability: $e');
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  /// Consecutive free slots starting at the chosen start slot.
  List<SlotDef> get _selection {
    if (_startSlot == null) return [];
    final need = _hours.ceil();
    final out = <SlotDef>[];
    for (var i = _startSlot!; i < kSlots.length && out.length < need; i++) {
      final s = kSlots[i];
      if (_isTaken(s) && !_holdLabels.contains(s.label)) break;
      if (out.isNotEmpty && s.startHour - out.last.startHour > 1) break;
      out.add(s);
    }
    return out;
  }

  double _slotCost(SlotDef s) =>
      s.priceFor(_courtRate) + (_surges['$_courtName|${s.label}'] ?? 0);

  double get _courtFee {
    var remaining = _hours;
    var sum = 0.0;
    for (final s in _selection) {
      final part = remaining >= 1 ? 1.0 : remaining;
      sum += _slotCost(s) * part;
      remaining -= part;
    }
    return sum;
  }

  double get _gearFee =>
      (_rackets * _racketFee + _shuttles * _shuttleFee + _shoes * _shoeFee)
          .toDouble();
  double get _total => _courtFee + _gearFee;
  double get _wallet => (_customer?['wallet_balance'] as num?)?.toDouble() ?? 0;
  bool get _walletOk => _customer != null && _wallet >= _total;

  String _money(num v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  Future<void> _lookup() async {
    final phone = _phone.text.trim();
    if (!RegExp(r'^\+?[0-9 ]{9,15}$').hasMatch(phone)) {
      setState(() => _lookupMessage = 'Enter a valid mobile number first.');
      return;
    }
    setState(() {
      _looking = true;
      _lookupMessage = null;
    });
    try {
      final c = await _service.lookupCustomer(phone);
      if (!mounted) return;
      setState(() {
        _customer = c;
        _guest = false;
        _lookupMessage = c == null
            ? 'No SportsBook account uses this number. Continue as a guest walk-in.'
            : null;
        if (c == null) _payment = _payment == 'wallet' ? 'cash' : _payment;
      });
    } catch (e) {
      if (mounted) setState(() => _lookupMessage = 'Lookup failed: $e');
    } finally {
      if (mounted) setState(() => _looking = false);
    }
  }

  Future<void> _hold() async {
    final sel = _selection;
    if (sel.isEmpty) {
      toast('Choose a start time first.');
      return;
    }
    setState(() => _holding = true);
    try {
      await _service.addSlotBlocks(
        venueId: _venueId,
        courtName: _courtName,
        dateIso: isoDate(widget.date),
        slotLabels: sel.map((s) => s.label).toList(),
        reason: 'Hold',
        note: 'Walk-in hold',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      );
      _holdLabels = sel.map((s) => s.label).toList();
      toast('Slot held for 3 minutes.');
      await _loadAvailability();
    } catch (e) {
      toast('Could not hold the slot: $e');
    } finally {
      if (mounted) setState(() => _holding = false);
    }
  }

  Future<void> _collect() async {
    final sel = _selection;
    if (sel.isEmpty) {
      toast('Choose an available start time.');
      return;
    }
    if (sel.length < _hours.ceil()) {
      toast(
        'Not enough consecutive free slots for ${_hours}h. Pick a shorter duration or another start time.',
      );
      return;
    }
    final name = _customer != null
        ? '${_customer!['full_name']}'
        : _guestName.text.trim();
    if (_customer == null && name.length < 2) {
      toast('Look up the athlete or enter the guest name.');
      return;
    }
    if (_payment == 'wallet' && !_walletOk) {
      toast('Wallet balance is too low for this booking.');
      return;
    }
    setState(() => _saving = true);
    final ref =
        'WI-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    final pin = (1000 + DateTime.now().microsecondsSinceEpoch % 9000)
        .toString();
    var created = false;
    try {
      // The temporary hold (if any) is released so the booking itself owns the slot.
      if (_holdLabels.isNotEmpty) {
        final blocks = await _service.getSlotBlocks(
          _venueId,
          isoDate(widget.date),
        );
        await _service.removeSlotBlocks(
          blocks
              .where(
                (b) => b['reason'] == 'Hold' && b['court_name'] == _courtName,
              )
              .map((b) => '${b['id']}')
              .toList(),
        );
        _holdLabels = [];
      }
      await _service.createWalkInBooking(
        venueId: _venueId,
        bookingRef: ref,
        courtName: _courtName,
        dateIso: isoDate(widget.date),
        timeSlot: sel.map((s) => s.label).join(', '),
        total: _total,
        pin: pin,
        paymentMethod: _payment,
        customerId: _customer?['id'] as String?,
        guestName: name,
        guestPhone: _phone.text.trim(),
        addons: [
          if (_gearFee > 0)
            {
              'rackets': _rackets,
              'shuttles': _shuttles,
              'shoes': _shoes,
              'fee': _gearFee,
            },
        ],
      );
      created = true;
      if (_payment == 'wallet') {
        try {
          await _service.debitCustomerWallet(
            _customer!['id'] as String,
            _total,
          );
        } catch (e) {
          await _service.cancelBooking(ref);
          throw Exception('Wallet charge failed: $e');
        }
      }
      if (!mounted) return;
      await _showPass(ref, pin, name, sel);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        final msg = '$e';
        toast(
          created
              ? msg
              : (msg.contains('just been booked')
                    ? 'That slot was just taken. Pick another.'
                    : 'Could not create booking: $msg'),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showPass(
    String ref,
    String pin,
    String name,
    List<SlotDef> sel,
  ) {
    final when =
        '${isoDate(widget.date)} • ${shortTime(sel.first.startOn(widget.date))} - ${shortTime(sel.last.endOn(widget.date))}';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Gate Pass Issued',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: 'SPORTSBOOK|$ref|$pin',
                size: 170,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),
              Text(
                '$name\n$_courtName • $when\nLKR ${_money(_total)} • ${_paymentLabel(_payment)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => shareText(
              'SportsBook gate pass $ref (PIN $pin)\n${widget.venue['name']} - $_courtName\n$when',
            ),
            child: const Text('Share'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String p) => switch (p) {
    'cash' => 'Cash at counter',
    'lankapay' => 'LankaPay / POS',
    _ => 'Athlete wallet',
  };

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final sel = _selection;
    final canCollect = sel.isNotEmpty && !_saving;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Walk-In Booking',
              style: TextStyle(
                color: ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${widget.venue['name']} • ${isoDate(widget.date)}'.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          _step(1, 'Athlete Identification', trailing: 'LOOKUP & KYC'),
          _athleteCard(),
          const SizedBox(height: 26),
          _step(2, 'Court & Time', trailing: _courtName.toUpperCase()),
          _courtTime(sel),
          const SizedBox(height: 26),
          _step(
            3,
            'Arena Gear & Equipment',
            trailing: '${_rackets + _shuttles + _shoes} items added',
          ),
          _gearRow(
            'Racket hire',
            'LKR $_racketFee / session',
            Icons.sports_tennis_rounded,
            _rackets,
            _racketFee,
            (v) => setState(() => _rackets = v),
          ),
          _gearRow(
            'Shuttle tube',
            'LKR $_shuttleFee / 3-pack',
            Icons.sports_baseball_outlined,
            _shuttles,
            _shuttleFee,
            (v) => setState(() => _shuttles = v),
          ),
          _gearRow(
            'Court shoes',
            'LKR $_shoeFee / pair',
            Icons.do_not_step_rounded,
            _shoes,
            _shoeFee,
            (v) => setState(() => _shoes = v),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Equipment Rental:',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                Text(
                  'LKR ${_money(_gearFee)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _step(
            4,
            'Settlement Method',
            trailing: _payment == 'cash'
                ? 'COUNTER INSTANT'
                : _paymentLabel(_payment).toUpperCase(),
          ),
          _payOption(
            'cash',
            Icons.payments_outlined,
            'Cash at Counter',
            'Immediate cash drawer unlock • receipt slip',
          ),
          _payOption(
            'lankapay',
            Icons.qr_code_2_rounded,
            'LankaPay Dynamic QR / POS',
            'Card or QR payment at the counter terminal',
          ),
          _payOption(
            'wallet',
            Icons.account_balance_wallet_outlined,
            'Athlete Wallet Balance',
            _customer == null
                ? 'Look up a registered athlete to use their wallet'
                : 'LKR ${_money(_wallet)} available${_walletOk ? '' : ' - needs LKR ${_money(_total - _wallet)} more'}',
            enabled: _customer != null,
            warn: _customer != null && !_walletOk,
          ),
          const SizedBox(height: 22),
          _breakdown(sel),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: canCollect ? _collect : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.qr_code_2_rounded),
              label: Text(
                'Collect LKR ${_money(_total)} & Generate Gate QR Pass',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
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
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: (_holding || sel.isEmpty) ? null : _hold,
              icon: const Icon(Icons.lock_clock, size: 18),
              label: const Text(
                'Save Draft / Hold Court Slot (3 mins)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(int n, String title, {String? trailing}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$n',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    ),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: child,
  );

  Widget _athleteCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  onSubmitted: (_) => _lookup(),
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    hintText: '+94 77 123 4567',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _looking ? null : _lookup,
                icon: _looking
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search, size: 16),
                label: const Text('Lookup'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          if (_lookupMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _lookupMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          if (_customer != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    ('${_customer!['full_name']}'.isEmpty
                            ? '?'
                            : '${_customer!['full_name']}'[0])
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${_customer!['full_name']}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                      Text(
                        '${_customer!['phone'] ?? ''} • ${_customer!['bookings_count']} bookings',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wallet credit',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'LKR ${_money(_wallet)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _customer == null && !_guest
                      ? 'Registered athlete? Look up their number.'
                      : (_guest
                            ? 'Guest walk-in (no account)'
                            : 'Verified SportsBook athlete'),
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _guest = !_guest;
                  if (_guest) {
                    _customer = null;
                    if (_payment == 'wallet') _payment = 'cash';
                  }
                }),
                child: Text(
                  _guest ? 'USE LOOKUP' : 'SWITCH TO GUEST WALK-IN',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (_guest || (_customer == null && _lookupMessage != null))
            TextField(
              controller: _guestName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Guest name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
        ],
      ),
    );
  }

  Widget _courtTime(List<SlotDef> sel) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < widget.courts.length; i++)
                ChoiceChip(
                  label: Text('${widget.courts[i]['name']}'),
                  selected: _court == i,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _court == i ? Colors.white : ink,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() {
                    _court = i;
                    _startSlot = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final h in _durations) ...[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _hours = h),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _hours == h
                            ? AppColors.primary
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${h.toStringAsFixed(1)} hrs',
                        style: TextStyle(
                          color: _hours == h ? Colors.white : ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                if (h != _durations.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'START TIME',
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (_loadingSlots) const LinearProgressIndicator(minHeight: 2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in kSlots)
                ChoiceChip(
                  label: Text(
                    s.label.replaceAll(' - ', '-'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  selected: _startSlot == s.id,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  disabledColor: const Color(0xFFF3F4F6),
                  labelStyle: TextStyle(
                    color: _startSlot == s.id
                        ? Colors.white
                        : (_isTaken(s) ? muted : ink),
                    fontWeight: FontWeight.w600,
                    decoration: _isTaken(s) ? TextDecoration.lineThrough : null,
                  ),
                  onSelected: _isTaken(s)
                      ? null
                      : (_) => setState(() => _startSlot = s.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sel.isEmpty
                        ? 'Choose a start time'
                        : 'Allocated slot: ${shortTime(sel.first.startOn(widget.date))} - ${shortTime(sel.last.endOn(widget.date))}',
                    style: const TextStyle(
                      color: ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  sel.isEmpty
                      ? ''
                      : '${sel.length} slot(s) • LKR ${_money(_courtFee)}',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gearRow(
    String title,
    String sub,
    IconData icon,
    int count,
    int fee,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(sub, style: const TextStyle(color: muted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: count > 0 ? () => onChanged(count - 1) : null,
            icon: const Icon(Icons.remove, size: 16),
          ),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton.filled(
            onPressed: count < 10 ? () => onChanged(count + 1) : null,
            icon: const Icon(Icons.add, size: 16),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          SizedBox(
            width: 64,
            child: Text(
              'LKR ${count * fee}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: count > 0 ? ink : muted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payOption(
    String value,
    IconData icon,
    String title,
    String subtitle, {
    bool enabled = true,
    bool warn = false,
  }) {
    final selected = _payment == value;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? () => setState(() => _payment = value) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? softBlue : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE9EEFF),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : softBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: warn ? Colors.redAccent : muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breakdown(List<SlotDef> sel) {
    Widget row(String l, String v, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(l, style: const TextStyle(color: muted, fontSize: 12)),
          ),
          Text(
            v,
            style: TextStyle(
              color: color ?? ink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BREAKDOWN OF FEES',
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          row(
            '$_courtName (${_hours.toStringAsFixed(1)} hrs)',
            'LKR ${_money(_courtFee)}',
          ),
          row('Equipment rental', 'LKR ${_money(_gearFee)}'),
          row('Facility levy', 'LKR 0 (exempt)', color: AppColors.primary),
          const Divider(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL AMOUNT',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'LKR ${_money(_total)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            'Payable via ${_paymentLabel(_payment)}',
            style: const TextStyle(color: AppColors.primary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
