import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import 'admin_profile_screen.dart';
import 'walk_in_booking_screen.dart';

/// Owner "Floor Ops": live view of today - KPIs, court radar, arrivals and emergency tools.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  final _service = SupabaseService();
  List<Map<String, dynamic>> _venues = [];
  int _venueIndex = 0;
  List<Map<String, dynamic>> _courts = [];
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _blocks = [];
  List<Map<String, dynamic>> _incidents = [];
  String _ownerName = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Map<String, dynamic>? get _venue => _venues.isEmpty ? null : _venues[_venueIndex];
  String get _today => isoDate(DateTime.now());

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _service.getProfile();
      final venues = await _service.getMyVenues();
      if (!mounted) return;
      _venues = venues;
      if (_venueIndex >= venues.length) _venueIndex = 0;
      _ownerName = ((profile?['full_name'] as String?) ?? '').split(' ').first;
      if (venues.isNotEmpty) {
        final id = venues[_venueIndex]['id'] as String;
        final results = await Future.wait([
          _service.getVenueCourts(id),
          _service.getVenueBookingsOn(id, _today),
          _service.getSlotBlocks(id, _today),
          _service.getIncidents(),
        ]);
        _courts = results[0];
        _bookings = results[1];
        _blocks = results[2];
        _incidents = results[3].where((i) => i['venue_id'] == id && i['status'] != 'resolved').toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  String _money(num v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  List<SlotDef> _slotsOf(Map<String, dynamic> b) {
    final labels = '${b['time_slot']}'.split(', ');
    return kSlots.where((s) => labels.contains(s.label)).toList();
  }

  bool _isLive(Map<String, dynamic> b) {
    final slots = _slotsOf(b);
    if (slots.isEmpty) return false;
    final now = DateTime.now();
    return slots.any((s) => s.startOn(now).isBefore(now) && s.endOn(now).isAfter(now));
  }

  DateTime _start(Map<String, dynamic> b) {
    final slots = _slotsOf(b);
    return slots.isEmpty ? DateTime.now() : slots.first.startOn(DateTime.now());
  }

  Future<void> _walkIn() async {
    if (_venue == null) return;
    if (_courts.isEmpty) {
      toast('Add a court first (Owner Profile).');
      return;
    }
    final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => WalkInBookingScreen(venue: _venue!, courts: _courts, date: DateTime.now())));
    if (created == true) _load();
  }

  Future<void> _quickExtend() async {
    final live = _bookings.where(_isLive).toList();
    if (live.isEmpty) {
      toast('No session is in progress right now.');
      return;
    }
    final pick = live.length == 1
        ? live.first
        : await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (ctx) => SimpleDialog(title: const Text('Extend which session?'), children: [
              for (final b in live) SimpleDialogOption(onPressed: () => Navigator.pop(ctx, b), child: Text('${b['court_name']} • ${b['time_slot']}')),
            ]),
          );
    if (pick == null) return;
    final slots = _slotsOf(pick);
    final idx = kSlots.indexOf(slots.last);
    if (idx + 1 >= kSlots.length) {
      toast('No later slot to extend into.');
      return;
    }
    final next = kSlots[idx + 1];
    final taken = _bookings.any((b) => b['court_name'] == pick['court_name'] && '${b['time_slot']}'.split(', ').contains(next.label)) || _blocks.any((b) => b['court_name'] == pick['court_name'] && b['time_slot'] == next.label);
    if (next.startHour - slots.last.startHour > 1 || taken) {
      toast('${next.label} is not free on ${pick['court_name']}.');
      return;
    }
    final court = _courts.firstWhere((c) => c['name'] == pick['court_name'], orElse: () => const {});
    final rate = (court['hourly_rate'] as num?)?.toDouble() ?? (_venue?['hourly_rate'] as num?)?.toDouble() ?? 2000;
    final extra = next.priceFor(rate);
    try {
      await _service.extendBooking('${pick['booking_ref']}', newTimeSlot: '${pick['time_slot']}, ${next.label}', newTotal: ((pick['total_paid'] as num?)?.toDouble() ?? 0) + extra);
      toast('Extended ${pick['court_name']} to ${next.label} (+LKR ${_money(extra)})');
      await _load();
    } catch (e) {
      toast('Could not extend: $e');
    }
  }

  bool get _halted => _blocks.any((b) => b['reason'] == 'Emergency');

  Future<void> _emergency() async {
    if (_venue == null) return;
    if (_halted) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Resume operations?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text('This reopens all slots that were closed by the emergency halt.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Resume'))],
        ),
      );
      if (ok != true) return;
      await _service.removeSlotBlocks(_blocks.where((b) => b['reason'] == 'Emergency').map((b) => '${b['id']}').toList());
      toast('Operations resumed.');
      await _load();
      return;
    }
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency halt', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Closes every remaining free slot on all courts for today so no new bookings can be made. Existing bookings are not cancelled.'),
          TextField(controller: note, decoration: const InputDecoration(labelText: 'Reason', hintText: 'e.g. Power outage')),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('Halt now'))],
      ),
    );
    final reason = note.text.trim();
    note.dispose();
    if (ok != true) return;
    final now = DateTime.now();
    try {
      for (final c in _courts) {
        final free = kSlots.where((s) => s.endOn(now).isAfter(now) && !_bookings.any((b) => b['court_name'] == c['name'] && '${b['time_slot']}'.split(', ').contains(s.label)) && !_blocks.any((b) => b['court_name'] == c['name'] && b['time_slot'] == s.label)).map((s) => s.label).toList();
        if (free.isNotEmpty) await _service.addSlotBlocks(venueId: _venue!['id'] as String, courtName: '${c['name']}', dateIso: _today, slotLabels: free, reason: 'Emergency', note: reason.isEmpty ? null : reason);
      }
      toast('Emergency halt active for the rest of today.');
      await _load();
    } catch (e) {
      toast('Could not halt: $e');
    }
  }

  Future<void> _checkIn(Map<String, dynamic> b) async {
    try {
      await _service.setBookingStatus('${b['booking_ref']}', 'Checked-in');
      toast('Checked in');
      await _load();
    } catch (e) {
      toast('Could not check in: $e');
    }
  }

  // ------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final revenue = _bookings.fold<double>(0, (s, b) => s + ((b['total_paid'] as num?)?.toDouble() ?? 0));
    final checkedIn = _bookings.where((b) => b['status'] == 'Checked-in').length;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 18)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('OWNER CONSOLE', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)), Text('Floor Ops', style: TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800))])),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: ink)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen())).then((_) => _load()),
                  child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 18)),
                ),
              ]),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(padding: const EdgeInsets.only(top: 40), child: Column(children: [Text('Could not load Floor Ops\n$_error', textAlign: TextAlign.center, style: const TextStyle(color: muted)), TextButton(onPressed: _load, child: const Text('Retry'))]))
              else if (!_loading && _venue == null)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(children: [
                    const Icon(Icons.add_business_outlined, size: 44, color: muted),
                    const SizedBox(height: 10),
                    const Text('Register your first complex', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('Floor Ops shows live bookings, courts and incidents once you have one.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
                    const SizedBox(height: 14),
                    FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen())).then((_) => _load()), child: const Text('Open Owner Profile')),
                  ]),
                )
              else if (_venue != null) ...[
                Text('$greeting${_ownerName.isEmpty ? '' : ', $_ownerName'}', style: const TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                if (_venues.length > 1)
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _venueIndex,
                      items: [for (var i = 0; i < _venues.length; i++) DropdownMenuItem(value: i, child: Text('${_venues[i]['name']}', style: const TextStyle(fontWeight: FontWeight.w700)))],
                      onChanged: (v) {
                        _venueIndex = v ?? 0;
                        _load();
                      },
                    ),
                  )
                else
                  Text('${_venue!['name']} • ${_venue!['area'] ?? ''}', style: const TextStyle(color: muted, fontSize: 12)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _kpi(Icons.event_available, 'Bookings today', '${_bookings.length}')),
                  const SizedBox(width: 10),
                  Expanded(child: _kpi(Icons.payments_outlined, 'Revenue (LKR)', _money(revenue))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _kpi(Icons.how_to_reg, 'Checked in', '$checkedIn / ${_bookings.length}')),
                  const SizedBox(width: 10),
                  Expanded(child: _kpi(Icons.warning_amber_rounded, 'Open incidents', '${_incidents.length}', warn: _incidents.isNotEmpty)),
                ]),
                const SizedBox(height: 18),
                if (_halted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFFFE9E9), borderRadius: BorderRadius.circular(14)),
                    child: const Row(children: [Icon(Icons.report, color: Colors.redAccent), SizedBox(width: 10), Expanded(child: Text('Emergency halt is active - new bookings are blocked for today.', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 12)))]),
                  ),
                Row(children: [
                  Expanded(child: FilledButton.icon(onPressed: _walkIn, icon: const Icon(Icons.add, size: 16), label: const Text('Fast Walk-In'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: _quickExtend, icon: const Icon(Icons.timer_outlined, size: 16), label: const Text('Extend'), style: OutlinedButton.styleFrom(foregroundColor: ink, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: _emergency, icon: Icon(_halted ? Icons.play_arrow_rounded : Icons.warning_amber_rounded, size: 16), label: Text(_halted ? 'Resume' : 'Halt'), style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                ]),
                const SizedBox(height: 22),
                const Text('Court Radar', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (_courts.isEmpty) const Text('No courts yet - add one in Owner Profile.', style: TextStyle(color: muted)),
                for (final c in _courts) _courtTile(c),
                const SizedBox(height: 22),
                const Text('Today\'s Arrivals', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (_bookings.isEmpty) const Text('No bookings today.', style: TextStyle(color: muted)),
                for (final b in (List.of(_bookings)..sort((a, b) => _start(a).compareTo(_start(b))))) _arrival(b),
              ],
              if (_loading) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator(minHeight: 2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpi(IconData icon, String label, String value, {bool warn = false}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: warn ? Colors.redAccent.withValues(alpha: 0.4) : const Color(0xFFE9EEFF))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: warn ? Colors.redAccent : AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: warn ? Colors.redAccent : ink, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: muted, fontSize: 11)),
        ]),
      );

  Widget _courtTile(Map<String, dynamic> c) {
    final name = '${c['name']}';
    final mine = _bookings.where((b) => b['court_name'] == name).toList();
    final live = mine.where(_isLive).toList();
    final upcoming = mine.where((b) => _start(b).isAfter(DateTime.now())).toList()..sort((a, b) => _start(a).compareTo(_start(b)));
    final closed = (c['is_active'] as bool?) == false;
    final blocked = _blocks.any((b) => b['court_name'] == name && _slotsOfLabel(b['time_slot']).any((s) => s.startOn(DateTime.now()).isBefore(DateTime.now()) && s.endOn(DateTime.now()).isAfter(DateTime.now())));
    final (label, color, icon) = closed
        ? ('CLOSED', muted, Icons.block)
        : blocked
            ? ('BLOCKED', Colors.orange, Icons.build_circle_outlined)
            : live.isNotEmpty
                ? ('IN USE', AppColors.primary, Icons.sports_tennis_rounded)
                : upcoming.isNotEmpty
                    ? ('NEXT ${shortTime(_start(upcoming.first))}', Colors.green, Icons.schedule)
                    : ('OPEN', Colors.green, Icons.check_circle_outline);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
            Text(live.isNotEmpty ? 'Playing now • ${live.first['time_slot']}' : '${mine.length} booking${mine.length == 1 ? '' : 's'} today', style: const TextStyle(color: muted, fontSize: 11)),
          ]),
        ),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800))),
      ]),
    );
  }

  List<SlotDef> _slotsOfLabel(Object? label) => kSlots.where((s) => s.label == label).toList();

  Widget _arrival(Map<String, dynamic> b) {
    final checked = b['status'] == 'Checked-in';
    final name = (b['guest_name'] as String?)?.isNotEmpty ?? false ? '${b['guest_name']}' : (b['user_id'] == null ? 'Guest' : 'Member');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${b['court_name']} • ${shortTime(_start(b))}', style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 13)),
          Text('$name • ${b['booking_ref']}', style: const TextStyle(color: muted, fontSize: 11)),
        ])),
        if (checked)
          const Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 18), SizedBox(width: 4), Text('In', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 12))])
        else
          TextButton(onPressed: () => _checkIn(b), style: TextButton.styleFrom(backgroundColor: softBlue), child: const Text('Check in')),
      ]),
    );
  }
}
