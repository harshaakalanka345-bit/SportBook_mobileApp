import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import '../booking/digital_match_pass_screen.dart';
import '../support/report_incident_screen.dart';

/// Activity feed built from the player's own bookings and incident reports.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

enum _Kind { booking, reminder, report }

class _Note {
  const _Note({required this.id, required this.kind, required this.icon, required this.title, required this.body, required this.time, this.bookingRef, this.isIncident = false});

  final String id;
  final _Kind kind;
  final IconData icon;
  final String title;
  final String body;
  final DateTime time;
  final String? bookingRef;
  final bool isIncident;
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  static const border = Color(0xFFE2E8F0);

  final _service = SupabaseService();
  List<_Note> _notes = [];
  DateTime _readAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _clearedAt = DateTime.fromMillisecondsSinceEpoch(0);
  String _tab = 'All';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _parse(Object? v) => DateTime.tryParse('$v')?.toLocal() ?? DateTime.now();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _service.getProfile();
      final prefs = Map<String, dynamic>.from((profile?['preferences'] as Map?) ?? const {});
      _readAt = DateTime.tryParse('${prefs['notif_read_at']}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
      _clearedAt = DateTime.tryParse('${prefs['notif_cleared_at']}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bookings = await _service.getUserBookings();
      List<Map<String, dynamic>> incidents = [];
      try {
        incidents = await _service.getIncidents();
      } catch (_) {}
      final uid = _service.currentUser?.id;
      final notes = <_Note>[];
      final now = DateTime.now();
      final today = isoDate(now);
      final tomorrow = isoDate(now.add(const Duration(days: 1)));
      for (final b in bookings) {
        final venue = (b['venues'] as Map?)?['name'] ?? 'your venue';
        final ref = '${b['booking_ref']}';
        final created = _parse(b['created_at']);
        final status = '${b['status']}';
        if (status == 'Cancelled') {
          notes.add(_Note(id: 'c-$ref', kind: _Kind.booking, icon: Icons.event_busy_outlined, title: 'Booking cancelled', body: '${b['court_name']} • ${b['date_schedule']} • ${b['time_slot']}. ${b['refunded_at'] != null ? 'Refund sent (${b['refund_method'] ?? 'wallet'}).' : 'Refund is being processed.'}', time: created, bookingRef: ref));
          continue;
        }
        notes.add(_Note(id: 'b-$ref', kind: _Kind.booking, icon: Icons.confirmation_number_outlined, title: status == 'Rescheduled' ? 'Booking rescheduled' : 'Court reserved at $venue', body: '${b['court_name']} • ${b['date_schedule']} • ${b['time_slot']}. Your digital pass and QR code are ready.', time: created, bookingRef: ref));
        final date = '${b['date_schedule']}';
        if (date == today || date == tomorrow) {
          notes.add(_Note(id: 'r-$ref', kind: _Kind.reminder, icon: Icons.alarm, title: date == today ? 'Match today' : 'Match tomorrow', body: '$venue, ${b['court_name']} • ${b['time_slot']}. Bring non-marking shoes and arrive 10 minutes early.', time: date == today ? now : created, bookingRef: ref));
        }
      }
      for (final i in incidents.where((i) => i['reporter_id'] == uid)) {
        final status = '${i['status']}';
        final venue = (i['venues'] as Map?)?['name'] ?? 'the venue';
        notes.add(_Note(
          id: 'i-${i['id']}-$status',
          kind: _Kind.report,
          icon: status == 'resolved' ? Icons.verified_outlined : Icons.report_gmailerrorred_outlined,
          title: status == 'resolved' ? 'Report resolved' : (status == 'in_progress' ? 'Report in progress' : 'Report received'),
          body: '${i['category']} at $venue: ${i['description']}${(i['resolution_note'] as String?)?.isNotEmpty ?? false ? '\nManager: ${i['resolution_note']}' : ''}',
          time: _parse(status == 'resolved' ? (i['resolved_at'] ?? i['created_at']) : i['created_at']),
          isIncident: true,
        ));
      }
      notes.sort((a, b) => b.time.compareTo(a.time));
      if (mounted) setState(() => _notes = notes.where((n) => n.time.isAfter(_clearedAt)).toList());
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _unread(_Note n) => n.time.isAfter(_readAt);

  List<_Note> get _filtered => _notes.where((n) => switch (_tab) {
        'Bookings' => n.kind == _Kind.booking,
        'Reminders' => n.kind == _Kind.reminder,
        'Reports' => n.kind == _Kind.report,
        _ => true,
      }).toList();

  Future<void> _markAllRead() async {
    final now = DateTime.now();
    setState(() => _readAt = now);
    try {
      await _service.updatePreferences({'notif_read_at': now.toUtc().toIso8601String()});
    } catch (e) {
      toast('Could not save: $e');
    }
  }

  Future<void> _clearRead() async {
    final read = _notes.where((n) => !_unread(n)).toList();
    if (read.isEmpty) {
      toast('No read notifications to clear.');
      return;
    }
    final cutoff = read.map((n) => n.time).reduce((a, b) => a.isAfter(b) ? a : b);
    setState(() {
      _clearedAt = cutoff;
      _notes = _notes.where((n) => n.time.isAfter(cutoff)).toList();
    });
    try {
      await _service.updatePreferences({'notif_cleared_at': cutoff.toUtc().toIso8601String()});
      toast('Cleared ${read.length} read notification${read.length == 1 ? '' : 's'}');
    } catch (e) {
      toast('Could not save: $e');
    }
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    if (d.inDays == 1) return 'Yesterday';
    return '${t.day}/${t.month}';
  }

  Map<String, List<_Note>> get _grouped {
    final out = <String, List<_Note>>{};
    final now = DateTime.now();
    for (final n in _filtered) {
      final diff = DateTime(now.year, now.month, now.day).difference(DateTime(n.time.year, n.time.month, n.time.day)).inDays;
      final key = diff <= 0 ? 'TODAY' : (diff == 1 ? 'YESTERDAY' : 'EARLIER');
      out.putIfAbsent(key, () => []).add(n);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notes.where(_unread).length;
    final groups = _grouped;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: ink), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 14)),
          const SizedBox(width: 8),
          const Text('Notifications', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(tooltip: 'Report a problem', icon: const Icon(Icons.flag_outlined, color: ink), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIncidentScreen()))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ink),
            onSelected: (v) => v == 'read' ? _markAllRead() : (v == 'clear' ? _clearRead() : _load()),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'read', child: Text('Mark all read')),
              PopupMenuItem(value: 'clear', child: Text('Clear read notifications')),
              PopupMenuItem(value: 'refresh', child: Text('Refresh')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: Text('$unread New', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                const Spacer(),
                InkWell(onTap: _markAllRead, child: const Row(children: [Icon(Icons.done_all, color: AppColors.primary, size: 16), SizedBox(width: 4), Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))])),
              ]),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                for (final t in const ['All', 'Bookings', 'Reminders', 'Reports']) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _tab = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: _tab == t ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _tab == t ? AppColors.primary : border)),
                      child: Text(t, style: TextStyle(color: _tab == t ? Colors.white : ink, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ]),
            ),
            if (_loading)
              const Padding(padding: EdgeInsets.only(top: 60), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Padding(padding: const EdgeInsets.all(30), child: Column(children: [Text('Could not load notifications\n$_error', textAlign: TextAlign.center, style: const TextStyle(color: muted)), TextButton(onPressed: _load, child: const Text('Retry'))]))
            else if (groups.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: Column(children: [Icon(Icons.notifications_off_outlined, size: 44, color: muted), SizedBox(height: 10), Text('You are all caught up', style: TextStyle(color: ink, fontWeight: FontWeight.w800)), Text('Bookings, reminders and report updates show up here.', style: TextStyle(color: muted, fontSize: 12))])))
            else
              for (final key in const ['TODAY', 'YESTERDAY', 'EARLIER'])
                if (groups[key] != null) ...[
                  Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 4), child: Text(key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: ink, letterSpacing: 0.5))),
                  for (final n in groups[key]!) _card(n),
                ],
            const SizedBox(height: 16),
            Center(child: TextButton.icon(onPressed: _clearRead, icon: const Icon(Icons.delete_outline, size: 16), label: const Text('Clear read notifications'))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _card(_Note n) {
    final unread = _unread(n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (n.bookingRef != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DigitalMatchPassScreen(bookingRef: n.bookingRef!)));
          } else if (n.isIncident) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIncidentScreen()));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 2))]),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)), child: Icon(n.icon, color: AppColors.primary, size: 20)),
              if (unread) Positioned(top: 0, right: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink))), Text(_ago(n.time), style: const TextStyle(fontSize: 11, color: muted))]),
                const SizedBox(height: 4),
                Text(n.body, style: const TextStyle(fontSize: 13, color: muted, height: 1.4)),
                if (n.bookingRef != null && n.kind != _Kind.reminder) ...[
                  const SizedBox(height: 10),
                  const Row(children: [Text('View Pass', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)), SizedBox(width: 4), Icon(Icons.arrow_forward, color: AppColors.primary, size: 14)]),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
