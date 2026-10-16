import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/actions.dart';
import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../auth/booking_history_screen.dart';
import '../auth/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import 'cancel_booking_screen.dart';
import 'digital_match_pass_screen.dart';
import 'modify_slot_screen.dart';
import 'rate_review_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F3FF);
  static const _background = Color(0xFFFAF8FF);

  final _searchCtl = TextEditingController();
  final _service = SupabaseService();
  String _activeTab = 'Upcoming';
  bool _newestFirst = true;
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _service.getUserBookings();
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final next = _service.getUserBookings();
    setState(() {
      _bookingsFuture = next;
    });
    try {
      await next;
    } catch (_) {
      // The FutureBuilder shows the error and lets the player retry.
    }
  }

  bool _isPast(Map<String, dynamic> booking) {
    final date = DateTime.tryParse('${booking['date_schedule']}');
    if (date == null) return false;
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day.isBefore(today)) return true;
    if (day.isAfter(today)) return false;

    final time = '${booking['time_slot'] ?? ''}';
    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(time);
    if (match == null) return false;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)?.toUpperCase();
    if (meridiem == 'PM' && hour < 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    final start = DateTime(date.year, date.month, date.day, hour, minute);
    return !start.isAfter(now);
  }

  String _dateText(dynamic value) {
    final date = DateTime.tryParse('$value');
    if (date == null) return value?.toString() ?? 'Date not available';
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _amount(dynamic value) {
    final amount = (value as num?)?.toDouble();
    if (amount == null) return 'LKR 0';
    return 'LKR ${NumberFormat('#,##0.##').format(amount)}';
  }

  Map<String, dynamic>? _paymentDetails(Map<String, dynamic> booking) {
    final raw = booking['addons'];
    if (raw is! List) return null;
    for (final item in raw) {
      if (item is Map && item.containsKey('payment_method')) {
        return Map<String, dynamic>.from(item);
      }
    }
    return null;
  }

  dynamic _displayAmount(Map<String, dynamic> booking) {
    final payment = _paymentDetails(booking);
    final due = payment?['full_total'];
    if (payment?['payment_status'] == 'Due at venue' && due != null) {
      return due;
    }
    return booking['total_paid'];
  }

  String _amountCaption(Map<String, dynamic> booking) =>
      _paymentDetails(booking)?['payment_status'] == 'Due at venue'
      ? 'Due at venue'
      : 'Total';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My bookings',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Your reservations, all in one place.',
                            style: TextStyle(color: _muted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Booking history',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingHistoryScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.history_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchCtl,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: _muted),
                    hintText: 'Search venue, court or booking ID',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchCtl.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchCtl.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded, size: 19),
                          ),
                        IconButton(
                          tooltip: _newestFirst
                              ? 'Newest first'
                              : 'Oldest first',
                          onPressed: () =>
                              setState(() => _newestFirst = !_newestFirst),
                          icon: Icon(
                            _newestFirst
                                ? Icons.south_rounded
                                : Icons.north_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(color: Color(0xFFE9EEFF)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFutureBookings(context),
                const SizedBox(height: 18),
                _helpCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(
          Icons.sports_tennis_rounded,
          color: Colors.white,
          size: 23,
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Text(
          'SportsBook',
          style: TextStyle(
            color: _ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      IconButton(
        tooltip: 'Notifications',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        ),
        icon: const Icon(Icons.notifications_none_rounded, color: _muted),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    ],
  );

  Widget _buildFutureBookings(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 52),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _emptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Couldn’t load your bookings',
            message: 'Check your connection, then try again.',
            action: TextButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          );
        }

        var bookings = List<Map<String, dynamic>>.from(
          snapshot.data ?? const [],
        );
        final query = _searchCtl.text.trim().toLowerCase();
        if (query.isNotEmpty) {
          bookings = bookings.where((booking) {
            final venue = (booking['venues'] as Map?) ?? const {};
            return '${venue['name']} ${venue['area']} ${venue['address']} ${venue['sport']} '
                    '${booking['court_name']} ${booking['booking_ref']} ${booking['date_schedule']}'
                .toLowerCase()
                .contains(query);
          }).toList();
        }
        if (!_newestFirst) bookings = bookings.reversed.toList();

        final upcoming = bookings.where((booking) {
          final status = '${booking['status']}'.toLowerCase();
          return status != 'cancelled' &&
              status != 'completed' &&
              !_isPast(booking);
        }).toList();
        final completed = bookings.where((booking) {
          final status = '${booking['status']}'.toLowerCase();
          return status == 'completed' ||
              (status != 'cancelled' && _isPast(booking));
        }).toList();
        final cancelled = bookings
            .where(
              (booking) => '${booking['status']}'.toLowerCase() == 'cancelled',
            )
            .toList();

        final active = switch (_activeTab) {
          'Completed' => completed,
          'Cancelled' => cancelled,
          _ => upcoming,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabs(upcoming.length, completed.length, cancelled.length),
            const SizedBox(height: 16),
            if (active.isEmpty)
              _emptyState(
                icon: _activeTab == 'Cancelled'
                    ? Icons.event_busy_rounded
                    : Icons.calendar_month_rounded,
                title: query.isEmpty
                    ? 'No $_activeTab bookings yet'
                    : 'No matching bookings',
                message: query.isEmpty
                    ? 'Your $_activeTab reservations will appear here.'
                    : 'Try another venue, court or booking ID.',
                action: query.isNotEmpty
                    ? TextButton.icon(
                        onPressed: () {
                          _searchCtl.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Clear search'),
                      )
                    : null,
              )
            else
              for (final booking in active) ...[
                _bookingCard(context, booking),
                const SizedBox(height: 14),
              ],
            if (_activeTab == 'Upcoming' && completed.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recently completed',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingHistoryScreen(),
                      ),
                    ),
                    child: Text('View all (${completed.length})'),
                  ),
                ],
              ),
              for (final booking in completed.take(2)) ...[
                _completedCard(context, booking),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _tabs(int upcoming, int completed, int cancelled) {
    final counts = {
      'Upcoming': upcoming,
      'Completed': completed,
      'Cancelled': cancelled,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: counts.entries.map((entry) {
          final selected = entry.key == _activeTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${entry.key}  ${entry.value}'),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _activeTab = entry.key),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFFE9EEFF),
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : _muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bookingCard(BuildContext context, Map<String, dynamic> booking) {
    final venue = (booking['venues'] as Map?) ?? const {};
    final name = venue['name']?.toString() ?? 'Sports venue';
    final sport = venue['sport']?.toString() ?? 'Court booking';
    final court = booking['court_name']?.toString() ?? 'Court';
    final status = booking['status']?.toString() ?? 'Confirmed';
    final ref = booking['booking_ref']?.toString() ?? '';
    final date = _dateText(booking['date_schedule']);
    final time = booking['time_slot']?.toString() ?? 'Time not available';
    final address = (venue['address'] ?? venue['area'] ?? '').toString();
    final past = _isPast(booking);
    final canManage =
        !past &&
        status.toLowerCase() != 'cancelled' &&
        status.toLowerCase() != 'completed';
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7ECFA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09001844),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  ref,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.sports_rounded,
                  color: AppColors.primary,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sport,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      court,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _amount(_displayAmount(booking)),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: _muted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        time,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _amountCaption(booking),
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: _muted, size: 18),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () => openDirections('$name, $address'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Directions'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showPass(context, ref),
              icon: const Icon(Icons.qr_code_2_rounded, size: 19),
              label: const Text('View booking pass'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (canManage) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.edit_calendar_rounded,
                    label: 'Change time',
                    onPressed: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModifySlotScreen(booking: booking),
                        ),
                      );
                      if (changed == true && mounted) await _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _actionButton(
                    icon: Icons.close_rounded,
                    label: 'Cancel',
                    danger: true,
                    onPressed: () async {
                      final cancelled = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CancelBookingScreen(booking: booking),
                        ),
                      );
                      if (cancelled == true && mounted) await _refresh();
                    },
                  ),
                ),
              ],
            ),
          ] else if (status.toLowerCase() == 'cancelled') ...[
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: _muted, size: 17),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Cancelled. Check the venue policy for refund details.',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status.toLowerCase()) {
    'cancelled' => const Color(0xFFC62828),
    'completed' || 'checked-in' => const Color(0xFF21834A),
    'rescheduled' => const Color(0xFFB46900),
    _ => AppColors.primary,
  };

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool danger = false,
  }) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 17),
    label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    style: OutlinedButton.styleFrom(
      foregroundColor: danger ? const Color(0xFFC62828) : AppColors.primary,
      side: BorderSide(
        color: danger ? const Color(0xFFF2C9C9) : const Color(0xFFDDE6FF),
      ),
      backgroundColor: danger ? const Color(0xFFFFF8F7) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      shape: const StadiumBorder(),
    ),
  );

  Widget _completedCard(BuildContext context, Map<String, dynamic> booking) {
    final venue = (booking['venues'] as Map?) ?? const {};
    return Container(
      padding: const EdgeInsets.all(15),
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
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF21834A),
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${_dateText(booking['date_schedule'])} · ${booking['time_slot'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _amount(_displayAmount(booking)),
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${venue['name'] ?? 'Sports venue'}',
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${booking['court_name'] ?? 'Court'}',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.star_outline_rounded,
                  label: 'Rate & review',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RateReviewScreen(booking: booking),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  icon: Icons.receipt_long_outlined,
                  label: 'Invoice',
                  onPressed: () => _showInvoice(context, booking),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 25, 20, 22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: _softBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 13),
        ),
        if (action != null) ...[const SizedBox(height: 8), action],
      ],
    ),
  );

  Widget _helpCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0FF),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      children: [
        Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 26),
        SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help?',
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'For changes or refunds, check the venue’s policy.',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _invoiceText(Map<String, dynamic> booking) {
    final venue = (booking['venues'] as Map?)?['name'] ?? 'Venue';
    return 'SPORTSBOOK INVOICE\n'
        'Booking: ${booking['booking_ref']}\n'
        'Venue: $venue\n'
        'Court: ${booking['court_name']}\n'
        'Date: ${booking['date_schedule']}\n'
        'Time: ${booking['time_slot']}\n'
        'Amount: ${_amount(_displayAmount(booking))} (${_amountCaption(booking)})\n'
        'Status: ${booking['status']}';
  }

  void _showInvoice(BuildContext context, Map<String, dynamic> booking) {
    final text = _invoiceText(booking);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Booking invoice',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SelectableText(text, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              copyText(text, message: 'Invoice copied');
              Navigator.pop(dialogContext);
            },
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () {
              shareText(text, subject: 'Invoice ${booking['booking_ref']}');
              Navigator.pop(dialogContext);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showPass(BuildContext context, String ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DigitalMatchPassScreen(bookingRef: ref),
      ),
    );
  }
}
