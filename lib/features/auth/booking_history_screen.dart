import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../booking/rate_review_screen.dart';

/// Every booking the player has made, newest first, with totals.
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  final _service = SupabaseService();
  late Future<List<Map<String, dynamic>>> _future;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _future = _service.getUserBookings();
  }

  Future<void> _refresh() async {
    final f = _service.getUserBookings();
    setState(() => _future = f);
    await f;
  }

  Color _color(String s) => switch (s) {
    'Cancelled' => Colors.redAccent,
    'Checked-in' => Colors.green,
    'Rescheduled' => Colors.orange,
    _ => AppColors.primary,
  };

  dynamic _displayAmount(Map<String, dynamic> booking) {
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

  bool _dueAtVenue(Map<String, dynamic> booking) {
    final addons = booking['addons'];
    return addons is List &&
        addons.any(
          (item) => item is Map && item['payment_status'] == 'Due at venue',
        );
  }

  bool _isPast(Map<String, dynamic> b) {
    final d = DateTime.tryParse('${b['date_schedule']}');
    final now = DateTime.now();
    return d != null && d.isBefore(DateTime(now.year, now.month, now.day));
  }

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
        title: const Text(
          'Booking History',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (snap.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Could not load history.\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              );
            }
            final all = snap.data ?? [];
            final list = all
                .where(
                  (b) => switch (_filter) {
                    'Completed' => b['status'] != 'Cancelled' && _isPast(b),
                    'Upcoming' => b['status'] != 'Cancelled' && !_isPast(b),
                    'Cancelled' => b['status'] == 'Cancelled',
                    _ => true,
                  },
                )
                .toList();
            final spent = all
                .where((b) => b['status'] != 'Cancelled')
                .fold<double>(
                  0,
                  (s, b) => s + ((b['total_paid'] as num?)?.toDouble() ?? 0),
                );
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL BOOKINGS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${all.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TOTAL SPENT (LKR)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            spent.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in const [
                        'All',
                        'Upcoming',
                        'Completed',
                        'Cancelled',
                      ]) ...[
                        ChoiceChip(
                          label: Text(f),
                          selected: _filter == f,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _filter == f ? Colors.white : ink,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        'No bookings here yet.',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  )
                else
                  for (final b in list)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE9EEFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${(b['venues'] as Map?)?['name'] ?? 'Venue'}',
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _color('${b['status']}')
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${b['status']}',
                                  style: TextStyle(
                                    color: _color('${b['status']}'),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${b['court_name']} • ${b['date_schedule']} • ${b['time_slot']}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${b['booking_ref']}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'LKR ${_displayAmount(b)}',
                                    style: const TextStyle(
                                      color: ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (_dueAtVenue(b))
                                    const Text(
                                      'Due at venue',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (b['status'] != 'Cancelled' && _isPast(b))
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RateReviewScreen(booking: b),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.star_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text('Rate & review'),
                              ),
                            ),
                        ],
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
