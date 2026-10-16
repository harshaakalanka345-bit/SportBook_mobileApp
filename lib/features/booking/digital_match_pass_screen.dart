import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/actions.dart';
import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';

class DigitalMatchPassScreen extends StatefulWidget {
  const DigitalMatchPassScreen({super.key, required this.bookingRef});

  final String bookingRef;

  @override
  State<DigitalMatchPassScreen> createState() => _DigitalMatchPassScreenState();
}

class _DigitalMatchPassScreenState extends State<DigitalMatchPassScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);
  final _service = SupabaseService();
  late Future<Map<String, dynamic>?> _bookingFuture;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _service.getUserBookingByRef(widget.bookingRef);
  }

  String _date(dynamic raw) {
    final date = DateTime.tryParse('$raw');
    if (date == null) return 'Date not available';
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
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _money(dynamic value) {
    final amount = value is num ? value : num.tryParse('$value');
    if (amount == null) return '—';
    final whole = amount.toStringAsFixed(
      amount == amount.roundToDouble() ? 0 : 2,
    );
    return 'LKR ${whole.replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), (_) => ',')}';
  }

  Map<String, dynamic>? _paymentDetails(dynamic raw) {
    if (raw is! List) return null;
    for (final item in raw) {
      if (item is Map && item.containsKey('payment_method')) {
        return Map<String, dynamic>.from(item);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
            SizedBox(width: 9),
            Text(
              'Digital Match Pass',
              style: TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh booking details',
            onPressed: () => setState(() {
              _bookingFuture = _service.getUserBookingByRef(widget.bookingRef);
            }),
            icon: const Icon(Icons.refresh_rounded, color: _ink),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _bookingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _message(
              icon: Icons.cloud_off_rounded,
              title: 'Pass details could not load',
              body: 'Check your connection and refresh to try again.',
              action: FilledButton.icon(
                onPressed: () => setState(() {
                  _bookingFuture = _service.getUserBookingByRef(
                    widget.bookingRef,
                  );
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            );
          }
          final booking = snapshot.data;
          if (booking == null) {
            return _message(
              icon: Icons.confirmation_number_outlined,
              title: 'Booking not found',
              body: 'This booking is not available on your account.',
            );
          }
          return _buildPass(booking);
        },
      ),
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String body,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 44),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, height: 1.4),
            ),
            if (action != null) ...[const SizedBox(height: 18), action],
          ],
        ),
      ),
    );
  }

  Widget _buildPass(Map<String, dynamic> booking) {
    final venue = booking['venues'] is Map
        ? Map<String, dynamic>.from(booking['venues'] as Map)
        : <String, dynamic>{};
    final name = '${venue['name'] ?? 'Venue'}';
    final address = '${venue['address'] ?? venue['area'] ?? ''}'.trim();
    final sport = '${venue['sport'] ?? ''}'.trim();
    final environment = '${venue['environment'] ?? ''}'.trim();
    final court = '${booking['court_name'] ?? 'Court'}';
    final ref = '${booking['booking_ref'] ?? widget.bookingRef}';
    final pin = '${booking['qr_turnstile_pin'] ?? ''}'.trim();
    final status = '${booking['status'] ?? 'Confirmed'}';
    final cancelled = status.toLowerCase() == 'cancelled';
    final refunded = booking['refunded_at'] != null;
    final accessCode = pin.isNotEmpty ? pin : ref;
    final timeSlot = '${booking['time_slot'] ?? 'Time not available'}';
    final payment = _paymentDetails(booking['addons']);
    final dueAtVenue = payment?['payment_status'] == 'Due at venue';
    final amount = dueAtVenue && payment != null
        ? payment['full_total']
        : booking['total_paid'];
    final venueLine = [
      sport,
      environment,
      court,
    ].where((part) => part.isNotEmpty).join(' • ');
    final share =
        'SportsBook booking $ref at $name on ${_date(booking['date_schedule'])}, $timeSlot.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                cancelled || refunded
                    ? Icons.info_outline_rounded
                    : Icons.wb_sunny_outlined,
                color: cancelled || refunded
                    ? Colors.redAccent
                    : AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cancelled
                      ? 'This booking is cancelled. Its entry code is no longer shown.'
                      : refunded
                      ? 'This booking has been refunded. Contact the venue before using this pass.'
                      : 'Show the booking code below to the venue staff when you arrive.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE9EEFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'BOOKING PASS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            venueLine.isEmpty ? court : venueLine,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'BOOKING REF',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ref,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _detail(
                            'DATE',
                            _date(booking['date_schedule']),
                          ),
                        ),
                        Expanded(
                          child: _detail('TIME', timeSlot, highlight: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: _detail('COURT', court)),
                        Expanded(
                          child: _detail(
                            dueAtVenue
                                ? 'AMOUNT DUE AT VENUE'
                                : 'BOOKING AMOUNT',
                            amount == null ? 'Not available' : _money(amount),
                            highlight: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: Color(0xFFE9EEFF),
              ),
              if (cancelled || refunded)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        cancelled
                            ? Icons.event_busy_rounded
                            : Icons.currency_exchange_rounded,
                        size: 54,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cancelled ? 'Booking cancelled' : 'Booking refunded',
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reference $ref',
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _softBlue,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: QrImageView(
                          data: accessCode,
                          backgroundColor: _softBlue,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: _ink,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: _ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'BOOKING CODE',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        accessCode,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            copyText(accessCode, message: 'Entry code copied'),
                        icon: const Icon(Icons.copy_rounded, size: 17),
                        label: const Text('Copy booking code'),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'If the code cannot be scanned, show your booking reference to the venue staff.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                decoration: const BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Keep this pass available when you arrive',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    shareText(share, subject: 'SportsBook booking $ref'),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share details'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: address.isEmpty
                    ? null
                    : () => openDirections(address),
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Directions'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final cancelled = status.toLowerCase() == 'cancelled';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            cancelled ? Icons.cancel_outlined : Icons.verified_outlined,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.primary : _ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
