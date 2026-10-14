import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import 'admin_profile_screen.dart';

/// Owner view of every booking at their complexes, with check-in (by tapping or by ref/PIN search) and cancel.
class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  final _service = SupabaseService();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  String? _error;
  String _filter = 'today'; // today | upcoming | all

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _todayIso {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.getOwnerBookings();
      if (mounted) setState(() => _bookings = rows);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _visible {
    final q = _search.text.trim().toLowerCase();
    return _bookings.where((b) {
      final date = '${b['date_schedule']}';
      final ok = switch (_filter) {
        'today' => date == _todayIso,
        'upcoming' => date.compareTo(_todayIso) >= 0,
        _ => true,
      };
      if (!ok) return false;
      if (q.isEmpty) return true;
      final venue = (b['venues'] as Map?) ?? const {};
      return '${b['booking_ref']}'.toLowerCase().contains(q) || '${b['qr_turnstile_pin']}'.contains(q) || '${b['court_name']}'.toLowerCase().contains(q) || '${venue['name']} ${venue['area']} ${venue['address']}'.toLowerCase().contains(q);
    }).toList();
  }

  double get _revenue => _visible.where((b) => b['status'] != 'Cancelled').fold(0.0, (s, b) => s + ((b['total_paid'] as num?)?.toDouble() ?? 0));

  Future<void> _setStatus(Map<String, dynamic> b, String status) async {
    try {
      if (status == 'Cancelled') {
        await _service.cancelBooking(b['booking_ref'] as String);
      } else {
        await _service.setBookingStatus(b['booking_ref'] as String, status);
      }
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update booking: $e'), backgroundColor: Colors.redAccent));
    }
  }

  Color _statusColor(String s) => switch (s) {
        'Checked-in' => Colors.green,
        'Cancelled' => Colors.redAccent,
        'Rescheduled' => Colors.orange,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('OWNER CONSOLE', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
                    Text('Bookings', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                  ]),
                ),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: ink)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search booking ref, PIN or court…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(_search.clear)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                for (final f in const [('today', 'Today'), ('upcoming', 'Upcoming'), ('all', 'All')]) ...[
                  ChoiceChip(
                    label: Text(f.$2),
                    selected: _filter == f.$1,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: _filter == f.$1 ? Colors.white : ink, fontWeight: FontWeight.w600),
                    onSelected: (_) => setState(() => _filter = f.$1),
                  ),
                  const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('BOOKINGS', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800)),
                      Text('${items.length}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('COLLECTED (LKR)', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800)),
                    Text(_revenue.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Column(children: [
                  const SizedBox(height: 32),
                  const Icon(Icons.cloud_off, size: 36, color: Colors.redAccent),
                  const SizedBox(height: 8),
                  Text('Could not load bookings\n$_error', textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ])
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text('No bookings match this view.\nRegister a complex and share it with players to start receiving bookings.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 13))),
                )
              else
                for (final b in items) _card(b),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> b) {
    final status = '${b['status']}';
    final color = _statusColor(status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('${(b['venues'] as Map?)?['name'] ?? 'Venue'} • ${b['court_name']}', style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 6),
        Text('${b['date_schedule']} • ${b['time_slot']}', style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 4),
        Row(children: [
          Text('${b['booking_ref']}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Text('PIN ${b['qr_turnstile_pin']}', style: const TextStyle(color: muted, fontSize: 11)),
          const Spacer(),
          Text('LKR ${b['total_paid']}', style: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
        if (status != 'Cancelled' && status != 'Checked-in') ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _setStatus(b, 'Checked-in'),
                icon: const Icon(Icons.how_to_reg, size: 16),
                label: const Text('Check in'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => _setStatus(b, 'Cancelled'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Cancel'),
            ),
          ]),
        ],
      ]),
    );
  }
}
