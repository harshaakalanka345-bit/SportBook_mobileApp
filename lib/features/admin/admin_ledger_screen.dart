import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/actions.dart';
import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import 'admin_profile_screen.dart';

/// Shift ledger & payouts: revenue intake, rain-check refunds, live ingestion feed, Z-report PDF and shift close.
class AdminLedgerScreen extends StatefulWidget {
  const AdminLedgerScreen({super.key});

  @override
  State<AdminLedgerScreen> createState() => _AdminLedgerScreenState();
}

class _AdminLedgerScreenState extends State<AdminLedgerScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  static const _defaultTarget = 50000.0;

  final _service = SupabaseService();
  List<Map<String, dynamic>> _venues = [];
  List<Map<String, dynamic>> _courts = [];
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _closures = [];
  String? _venueId;
  String _period = 'today'; // today | week | month
  String _feed = 'all'; // all | cards | wallet | cash | app
  double _target = _defaultTarget;
  DateTime _loadedAt = DateTime.now();
  bool _loading = true;
  String? _error;
  final Set<String> _refundsInProgress = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _service.getProfile();
      final prefs = Map<String, dynamic>.from(
        (profile?['preferences'] as Map?) ?? const {},
      );
      final venues = await _service.getMyVenues();
      final bookings = await _service.getOwnerBookings();
      var courts = <Map<String, dynamic>>[];
      for (final v in venues) {
        try {
          courts = [
            ...courts,
            ...await _service.getVenueCourts(v['id'] as String),
          ];
        } catch (_) {}
      }
      var closures = <Map<String, dynamic>>[];
      try {
        closures = await _service.getShiftClosures();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _venues = venues;
        _courts = courts;
        _bookings = bookings;
        _closures = closures;
        _target =
            (prefs['revenue_target'] as num?)?.toDouble() ?? _defaultTarget;
        _loadedAt = DateTime.now();
        _venueId ??= venues.length == 1 ? venues.first['id'] as String : null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------------------------------------------------ derived

  DateTime get _from {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    return switch (_period) {
      'week' => today.subtract(const Duration(days: 6)),
      'month' => today.subtract(const Duration(days: 29)),
      _ => today,
    };
  }

  DateTime _created(Map<String, dynamic> b) =>
      (DateTime.tryParse('${b['created_at']}') ?? DateTime.now()).toLocal();
  double _amount(Map<String, dynamic> b) =>
      (b['total_paid'] as num?)?.toDouble() ?? 0;
  double _sum(Iterable<Map<String, dynamic>> l) =>
      l.fold(0.0, (s, b) => s + _amount(b));

  Map<String, dynamic>? get _venue => _venueId == null
      ? null
      : _venues.firstWhere((v) => v['id'] == _venueId, orElse: () => const {});
  String get _venueName =>
      (_venue?['name'] as String?) ??
      (_venues.isEmpty ? 'No complex' : 'All complexes');

  List<Map<String, dynamic>> get _scoped => _bookings
      .where((b) => _venueId == null || b['venue_id'] == _venueId)
      .toList();
  List<Map<String, dynamic>> get _inPeriod =>
      _scoped.where((b) => !_created(b).isBefore(_from)).toList();
  List<Map<String, dynamic>> get _paid =>
      _inPeriod.where((b) => b['status'] != 'Cancelled').toList();
  List<Map<String, dynamic>> get _pendingRefunds => _scoped
      .where(
        (b) =>
            b['status'] == 'Cancelled' &&
            b['refunded_at'] == null &&
            _amount(b) > 0,
      )
      .toList();

  /// cash | cards | wallet | app
  String _kind(Map<String, dynamic> b) {
    if (b['source'] == 'walk_in') {
      return switch ('${b['payment_method']}') {
        'cash' => 'cash',
        'wallet' => 'wallet',
        _ => 'cards',
      };
    }
    return 'app';
  }

  String _kindLabel(String k) => switch (k) {
    'cash' => 'Cash drawer',
    'wallet' => 'Athlete wallet',
    'cards' => 'Cards & LankaPay',
    _ => 'App payments',
  };

  Map<String, double> get _byKind {
    final m = {'cards': 0.0, 'wallet': 0.0, 'cash': 0.0, 'app': 0.0};
    for (final b in _paid) {
      m[_kind(b)] = m[_kind(b)]! + _amount(b);
    }
    return m;
  }

  String _money(num v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  String get _periodLabel => switch (_period) {
    'week' => 'Last 7 days',
    'month' => 'Last 30 days',
    _ => 'Today, ${isoDate(DateTime.now())}',
  };

  // ------------------------------------------------------------ actions

  Future<void> _editTarget() async {
    final c = TextEditingController(text: _target.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Revenue target',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target for the selected period (LKR)',
            prefixText: 'LKR ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    final v = double.tryParse(c.text.trim());
    c.dispose();
    if (ok != true || v == null || v <= 0) return;
    setState(() => _target = v);
    try {
      await _service.updatePreferences({'revenue_target': v});
    } catch (e) {
      toast('Could not save target: $e');
    }
  }

  Future<void> _refundAllToWallets() async {
    final list = _pendingRefunds.where((b) => b['user_id'] != null).toList();
    if (list.isEmpty) {
      toast('No refunds can go to a wallet.');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Refund all to wallets?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Credit LKR ${_money(_sum(list))} back to ${list.length} athlete wallet${list.length == 1 ? '' : 's'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Refund all'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    var done = 0;
    for (final b in list) {
      try {
        await _service.refundBooking(b, toWallet: true);
        done++;
      } catch (_) {}
    }
    toast('Refunded $done of ${list.length}.');
    await _load();
  }

  Future<void> _weatherVoid() async {
    if (_venues.isEmpty || _courts.isEmpty) {
      toast('Register a complex with courts first.');
      return;
    }
    final today = isoDate(DateTime.now());
    final venueIds = _venueId == null
        ? _venues.map((v) => v['id']).toSet()
        : {_venueId};
    final names = _courts
        .where((c) => venueIds.contains(c['venue_id']))
        .map((c) => '${c['name']}')
        .toSet()
        .toList();
    final selected = <String>{};
    var reason = 'Weather void';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text(
            'Rain-Check Action',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cancels all of today\'s remaining bookings on the selected courts and queues them for refund.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final n in names)
                      FilterChip(
                        label: Text(n),
                        selected: selected.contains(n),
                        onSelected: (v) => setLocal(
                          () => v ? selected.add(n) : selected.remove(n),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final r in const [
                      'Weather void',
                      'Maintenance',
                      'Power outage',
                    ])
                      ChoiceChip(
                        label: Text(r),
                        selected: reason == r,
                        onSelected: (_) => setLocal(() => reason = r),
                      ),
                  ],
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
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Void & queue refunds'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final now = DateTime.now();
    final targets = _scoped.where((b) {
      if (b['status'] == 'Cancelled' ||
          b['date_schedule'] != today ||
          !selected.contains('${b['court_name']}'))
        return false;
      final labels = '${b['time_slot']}'.split(', ');
      final slots = kSlots.where((s) => labels.contains(s.label)).toList();
      return slots.isEmpty || slots.last.endOn(now).isAfter(now);
    }).toList();
    if (targets.isEmpty) {
      toast('No remaining bookings on those courts today.');
      return;
    }
    var done = 0;
    for (final b in targets) {
      try {
        await _service.cancelBooking('${b['booking_ref']}', reason: reason);
        done++;
      } catch (_) {}
    }
    toast(
      '$done booking${done == 1 ? '' : 's'} voided - refunds are in the queue.',
    );
    await _load();
  }

  Future<List<int>> _buildPdf() async {
    final paid = _paid;
    final by = _byKind;
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(
            'SportsBook - Z Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('$_venueName  |  $_periodLabel'),
          pw.Text(
            'Generated ${DateTime.now().toLocal().toString().substring(0, 16)}',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Revenue: LKR ${_money(_sum(paid))}  (${paid.length} bookings)',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Method', 'Amount (LKR)'],
            data: [
              for (final k in ['cards', 'wallet', 'cash', 'app'])
                [_kindLabel(k), _money(by[k]!)],
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Refunds pending: ${_pendingRefunds.length} (LKR ${_money(_sum(_pendingRefunds))})',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Transactions',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: [
              'Ref',
              'Court',
              'Date',
              'Slot',
              'Method',
              'Status',
              'LKR',
            ],
            cellStyle: const pw.TextStyle(fontSize: 8),
            data: [
              for (final b in _inPeriod)
                [
                  '${b['booking_ref']}',
                  '${b['court_name']}',
                  '${b['date_schedule']}',
                  '${b['time_slot']}',
                  _kindLabel(_kind(b)),
                  '${b['status']}',
                  _money(_amount(b)),
                ],
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  Future<void> _exportPdf() async {
    if (_inPeriod.isEmpty) {
      toast('Nothing to export for this period.');
      return;
    }
    try {
      final bytes = await _buildPdf();
      await shareFileBytes(
        bytes,
        'z-report-${isoDate(DateTime.now())}.pdf',
        'application/pdf',
        text: 'SportsBook Z report',
      );
    } catch (e) {
      toast('Could not build the PDF: $e');
    }
  }

  Future<void> _exportCsv() async {
    if (_inPeriod.isEmpty) {
      toast('Nothing to export for this period.');
      return;
    }
    final rows = <String>[
      'booking_ref,venue,court,date,time_slot,amount_lkr,status,method,created_at',
    ];
    String esc(Object? v) => '"${'${v ?? ''}'.replaceAll('"', '""')}"';
    for (final b in _inPeriod) {
      rows.add(
        [
          b['booking_ref'],
          (b['venues'] as Map?)?['name'],
          b['court_name'],
          b['date_schedule'],
          b['time_slot'],
          b['total_paid'],
          b['status'],
          _kindLabel(_kind(b)),
          b['created_at'],
        ].map(esc).join(','),
      );
    }
    await shareText(
      rows.join('\n'),
      subject: 'SportsBook ledger ${isoDate(DateTime.now())}',
    );
  }

  Future<void> _closeShift() async {
    final today = isoDate(DateTime.now());
    final targetVenue =
        _venueId ??
        (_venues.length == 1 ? _venues.first['id'] as String : null);
    if (targetVenue == null) {
      toast(
        'Pick a single complex (top of the page) before closing its shift.',
      );
      return;
    }
    final pending = _pendingRefunds
        .where((b) => b['venue_id'] == targetVenue)
        .length;
    final shift = _bookings
        .where(
          (b) => b['venue_id'] == targetVenue && isoDate(_created(b)) == today,
        )
        .toList();
    final live = shift.where((b) => b['status'] != 'Cancelled').toList();
    final cash = _sum(live.where((b) => _kind(b) == 'cash'));
    final digital = _sum(live) - cash;
    final refunds = _sum(
      _scoped.where(
        (b) =>
            b['venue_id'] == targetVenue &&
            b['refunded_at'] != null &&
            isoDate(
                  DateTime.tryParse('${b['refunded_at']}')?.toLocal() ??
                      DateTime(2000),
                ) ==
                today,
      ),
    );
    final counted = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Reconcile & Close Shift',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${live.length} bookings today\nCash expected: LKR ${_money(cash)}\nCards / wallet / app: LKR ${_money(digital)}\nRefunds paid: LKR ${_money(refunds)}',
                style: const TextStyle(height: 1.6),
              ),
              if (pending > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '$pending refund${pending == 1 ? ' is' : 's are'} still pending.',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: counted,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cash counted in drawer (LKR)',
                ),
              ),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
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
            child: const Text('Close shift'),
          ),
        ],
      ),
    );
    final countedValue = double.tryParse(counted.text.trim());
    final noteText = note.text.trim();
    counted.dispose();
    note.dispose();
    if (ok != true) return;
    try {
      await _service.closeShift(
        venueId: targetVenue,
        shiftDate: today,
        bookingsCount: live.length,
        cashTotal: cash,
        digitalTotal: digital,
        refundsTotal: refunds,
        countedCash: countedValue,
        note: noteText.isEmpty ? null : noteText,
      );
      final diff = countedValue == null ? null : countedValue - cash;
      toast(
        diff == null
            ? 'Shift closed.'
            : (diff == 0
                  ? 'Shift closed - drawer balanced.'
                  : 'Shift closed - drawer is ${diff > 0 ? 'over' : 'short'} by LKR ${_money(diff.abs())}.'),
      );
      await _load();
    } catch (e) {
      toast('Could not close shift: $e');
    }
  }

  // ------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final pending = _pendingRefunds;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              _appBar(),
              const SizedBox(height: 14),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Text(
                        'Could not load the ledger\n$_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted),
                      ),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              else if (!_loading && _venues.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text(
                      'Register a complex to see its ledger.',
                      style: TextStyle(color: muted),
                    ),
                  ),
                )
              else ...[
                _headerCard(),
                const SizedBox(height: 14),
                _revenueCard(),
                const SizedBox(height: 22),
                _rainCheck(pending),
                const SizedBox(height: 22),
                _feedSection(),
                const SizedBox(height: 22),
                _vault(pending.length),
                if (_closures.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'RECENT SHIFT CLOSURES',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final c in _closures.take(5))
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE9EEFF)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${c['shift_date']} • ${(c['venues'] as Map?)?['name'] ?? ''}\n${c['bookings_count']} bookings • cash LKR ${_money((c['cash_total'] as num?) ?? 0)}${c['counted_cash'] != null ? ' (counted ${_money(c['counted_cash'] as num)})' : ''}',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                ],
              ],
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.account_balance_wallet_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _venues.isEmpty
                  ? 'OWNER CONSOLE'
                  : '${_venueName.toUpperCase()} • LEDGER',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'Shift Ledger & Payouts',
              style: TextStyle(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: _load,
        icon: const Icon(Icons.refresh_rounded, color: ink),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
        ),
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

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: child,
  );

  Widget _headerCard() {
    final secs = DateTime.now().difference(_loadedAt).inSeconds;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _period == 'today'
                      ? 'CURRENT SHIFT'
                      : (_period == 'week' ? '7-DAY VIEW' : '30-DAY VIEW'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
                label: const Text(
                  'Export Z-PDF',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFD6E0FF)),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_venues.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All complexes'),
                    selected: _venueId == null,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _venueId == null ? Colors.white : ink,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _venueId = null),
                  ),
                  for (final v in _venues) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('${v['name']}'),
                      selected: _venueId == v['id'],
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _venueId == v['id'] ? Colors.white : ink,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          setState(() => _venueId = v['id'] as String),
                    ),
                  ],
                ],
              ),
            )
          else
            Text(
              '$_venueName • ${_venue?['area'] ?? ''}',
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final p in const [
                ('today', 'Today'),
                ('week', '7 days'),
                ('month', '30 days'),
              ]) ...[
                ChoiceChip(
                  label: Text(p.$2),
                  selected: _period == p.$1,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _period == p.$1 ? Colors.white : ink,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _period = p.$1),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _periodLabel,
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ),
              const Icon(
                Icons.verified_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Ledger synced ${secs < 60 ? '${secs}s' : '${secs ~/ 60}m'} ago',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _revenueCard() {
    final total = _sum(_paid);
    final pct = _target <= 0 ? 0 : (total * 100 / _target).round();
    final by = _byKind;
    final cardsShare = by['cards']! + by['app']!;
    double share(double v) => total == 0 ? 0 : v * 100 / total;
    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'REVENUE INTAKE',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InkWell(
                onTap: _editTarget,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: softBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        pct >= 100 ? Icons.flag : Icons.flag_outlined,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pct >= 100 ? 'Target met $pct%' : '$pct% of target',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_outlined,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'LKR ${_money(total)}',
            style: const TextStyle(
              color: ink,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: softBlue,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_paid.length} transactions processed • target LKR ${_money(_target)}',
            style: const TextStyle(color: muted, fontSize: 10),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'Cards & LankaPay',
                  cardsShare,
                  '${share(cardsShare).round()}% of total',
                  const Color(0xFF0D6EFD),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metric(
                  'Athlete Wallet',
                  by['wallet']!,
                  '${share(by['wallet']!).round()}% of total',
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metric(
                  'Cash Drawer',
                  by['cash']!,
                  '${share(by['cash']!).round()}% in till',
                  const Color(0xFF94A3B8),
                  isMuted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(
    String title,
    double value,
    String sub,
    Color dot, {
    bool isMuted = false,
  }) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FD),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ink,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'LKR\n${_money(value)}',
          style: const TextStyle(
            color: ink,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: TextStyle(
            color: isMuted ? muted : AppColors.primary,
            fontSize: 9,
          ),
        ),
      ],
    ),
  );

  Widget _rainCheck(List<Map<String, dynamic>> pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Rain-Check Action',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pending.isEmpty ? softBlue : const Color(0xFFFFE9E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${pending.length} pending',
                style: TextStyle(
                  color: pending.isEmpty
                      ? AppColors.primary
                      : const Color(0xFFE11D48),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _weatherVoid,
                icon: const Icon(Icons.thunderstorm_outlined, size: 16),
                label: const Text('Declare weather void'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (pending.length > 1) ...[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _refundAllToWallets,
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                  ),
                  label: const Text('Refund all'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          const Text(
            'No cancelled bookings waiting for a refund.',
            style: TextStyle(color: muted, fontSize: 13),
          )
        else
          for (final b in pending) _refundCard(b),
      ],
    );
  }

  Future<bool> _confirmRefund(
    String title,
    String message,
    String action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Go back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Widget _refundCard(Map<String, dynamic> b) {
    final canWallet = b['user_id'] != null;
    final ref = '${b['booking_ref']}';
    final processing = _refundsInProgress.contains(ref);
    final reason = (b['cancel_reason'] as String?) ?? 'Cancelled';
    final name = (b['guest_name'] as String?)?.isNotEmpty ?? false
        ? '${b['guest_name']}'
        : (canWallet ? 'SportsBook member' : 'Guest');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${b['booking_ref']} • ${b['court_name']}',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reason.toUpperCase(),
                  style: const TextStyle(
                    color: ink,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${b['date_schedule']} • ${b['time_slot']}',
            style: const TextStyle(color: muted, fontSize: 10),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: softBlue,
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'REFUND DUE',
                    style: TextStyle(
                      color: muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'LKR ${_money(_amount(b))}',
                    style: const TextStyle(
                      color: ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (canWallet)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: processing
                    ? null
                    : () async {
                        if (!await _confirmRefund(
                          'Refund to wallet?',
                          'Credit LKR ${_money(_amount(b))} to this player’s SportsBook wallet?',
                          'Credit wallet',
                        ))
                          return;
                        setState(() => _refundsInProgress.add(ref));
                        try {
                          await _service.refundBooking(b, toWallet: true);
                          toast('Refund credited to the player wallet.');
                          await _load();
                        } catch (e) {
                          toast('Refund failed: $e');
                        } finally {
                          if (mounted)
                            setState(() => _refundsInProgress.remove(ref));
                        }
                      },
                icon: const Icon(Icons.currency_exchange, size: 14),
                label: Text(
                  processing ? 'Recording refund…' : 'Refund to athlete wallet',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: processing
                  ? null
                  : () async {
                      if (!await _confirmRefund(
                        'Record a cash refund?',
                        'Confirm that LKR ${_money(_amount(b))} has been returned to the player in cash at the venue.',
                        'Cash returned',
                      ))
                        return;
                      setState(() => _refundsInProgress.add(ref));
                      try {
                        await _service.refundBooking(b, toWallet: false);
                        toast('Cash refund recorded for the venue.');
                        await _load();
                      } catch (e) {
                        toast('Could not record refund: $e');
                      } finally {
                        if (mounted)
                          setState(() => _refundsInProgress.remove(ref));
                      }
                    },
              icon: const Icon(Icons.payments_outlined, size: 14),
              label: Text(
                processing
                    ? 'Recording refund…'
                    : 'Record cash refund at venue',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedSection() {
    final all = _inPeriod;
    int count(String k) => all.where((b) => k == 'all' || _kind(b) == k).length;
    final list = all
        .where((b) => _feed == 'all' || _kind(b) == _feed)
        .take(40)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Shift Ingestion Feed',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 7),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in const [
                ('all', 'ALL'),
                ('cards', 'CARDS'),
                ('wallet', 'WALLET'),
                ('cash', 'CASH'),
                ('app', 'APP'),
              ]) ...[
                ChoiceChip(
                  label: Text(
                    '${f.$2} (${count(f.$1)})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  selected: _feed == f.$1,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _feed == f.$1 ? Colors.white : ink,
                  ),
                  onSelected: (_) => setState(() => _feed = f.$1),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.download, size: 14),
                label: const Text('CSV'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'No transactions match.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ),
        for (final b in list) _feedRow(b),
      ],
    );
  }

  Widget _feedRow(Map<String, dynamic> b) {
    final cancelled = b['status'] == 'Cancelled';
    final refunded = b['refunded_at'] != null;
    final kind = _kind(b);
    final icon = cancelled
        ? Icons.undo_rounded
        : (kind == 'cash'
              ? Icons.payments_outlined
              : (kind == 'wallet'
                    ? Icons.account_balance_wallet_outlined
                    : (kind == 'cards'
                          ? Icons.qr_code_2_rounded
                          : Icons.phone_iphone_rounded)));
    final status = cancelled
        ? (refunded ? 'Refunded' : 'Cancelled')
        : (b['status'] == 'Checked-in' ? 'Checked in' : 'Settled');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: cancelled ? Colors.redAccent : AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${b['court_name']}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: softBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _kindLabel(kind).toUpperCase(),
                        style: const TextStyle(
                          color: ink,
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${b['booking_ref']} • ${shortTime(_created(b))}',
                  style: const TextStyle(color: muted, fontSize: 9),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${cancelled ? '-' : '+'}LKR ${_money(_amount(b))}',
                style: TextStyle(
                  color: cancelled ? Colors.redAccent : AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  color: ink,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vault(int pendingCount) {
    final ready = pendingCount == 0;
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
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Vault Reconciliation Protocol',
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ready ? Colors.white : const Color(0xFFFFE9E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ready ? 'Ready' : '$pendingCount refunds pending',
                  style: TextStyle(
                    color: ready ? AppColors.primary : Colors.redAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Closing the ledger records today\'s totals, compares the cash you counted in the drawer with what the system expects, and stores the shift summary for audit.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _closeShift,
              icon: const Icon(Icons.lock_outline, size: 16),
              label: const Text(
                'Reconcile & Close Shift',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: ink,
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
}
