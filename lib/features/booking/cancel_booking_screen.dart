import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key, this.booking});

  final Map<String, dynamic>? booking;

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  static const _reasons = [
    'Change of plans',
    'My group can’t attend',
    'Injury or health issue',
    'Booked the wrong slot',
    'Other',
  ];

  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _background = Color(0xFFFAF8FF);

  final _service = SupabaseService();
  int _reason = 0;
  bool _busy = false;

  Map? get _venue => widget.booking?['venues'] as Map?;

  Future<void> _confirmCancel() async {
    final booking = widget.booking;
    final ref = booking?['booking_ref']?.toString();
    if (ref == null || ref.isEmpty) {
      toast('This booking could not be identified. Go back and try again.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: const Text(
          'Your booking will be marked as cancelled. Refund eligibility depends on the venue’s cancellation policy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _service.cancelBooking(ref, reason: _reasons[_reason]);
      if (!mounted) return;
      toast('Booking cancelled. Check the venue’s policy for refund details.');
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        toast('Could not cancel this booking. Please refresh and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _dateText(dynamic value) {
    final parsed = DateTime.tryParse('$value');
    if (parsed == null) return value?.toString() ?? 'Date not available';
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
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String _amount(dynamic value) {
    final amount = (value as num?)?.toDouble();
    if (amount == null) return 'LKR 0';
    return 'LKR ${NumberFormat('#,##0.##').format(amount)}';
  }

  (dynamic, String) _reservationAmount(Map<String, dynamic> booking) {
    final addons = booking['addons'];
    if (addons is List) {
      for (final item in addons) {
        if (item is Map && item['payment_status'] == 'Due at venue') {
          return (
            item['full_total'] ?? booking['total_paid'],
            'Amount due at venue',
          );
        }
      }
    }
    return (booking['total_paid'], 'Amount paid');
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking ?? const <String, dynamic>{};
    final venueName = _venue?['name']?.toString() ?? 'Court booking';
    final sport = _venue?['sport']?.toString();
    final (reservationAmount, amountLabel) = _reservationAmount(booking);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: const Text(
          'Cancel booking',
          style: TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFC62828)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before you cancel',
                        style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Refunds follow the venue’s policy. Cancelling here does not submit a card refund.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EDFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.stadium_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sport != null && sport.isNotEmpty)
                            Text(
                              sport.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .4,
                              ),
                            ),
                          Text(
                            venueName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            booking['court_name']?.toString() ?? 'Court',
                            style: const TextStyle(color: _muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _detailRow(
                  Icons.calendar_today_rounded,
                  'Date',
                  _dateText(booking['date_schedule']),
                ),
                const SizedBox(height: 12),
                _detailRow(
                  Icons.access_time_rounded,
                  'Time',
                  booking['time_slot']?.toString() ?? 'Time not available',
                ),
                const SizedBox(height: 12),
                _detailRow(
                  Icons.confirmation_number_outlined,
                  'Booking ID',
                  booking['booking_ref']?.toString() ?? '—',
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        amountLabel,
                        style: const TextStyle(color: _muted, fontSize: 13),
                      ),
                    ),
                    Text(
                      _amount(reservationAmount),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Why are you cancelling?',
            style: TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose the reason that fits best.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _reasons.length; i++) ...[
            _reasonTile(i),
            if (i != _reasons.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                  size: 19,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your booking status updates after cancellation. Contact the venue to confirm whether a refund applies and how it will be paid.',
                    style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x12001844),
                blurRadius: 14,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _confirmCancel,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  icon: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.event_busy_rounded, size: 18),
                  label: Text(_busy ? 'Cancelling…' : 'Cancel booking'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('Keep my booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9EEFF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08001844),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _detailRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 17, color: AppColors.primary),
      const SizedBox(width: 10),
      SizedBox(
        width: 78,
        child: Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
      ),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: _ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );

  Widget _reasonTile(int index) {
    final selected = _reason == index;
    return Material(
      color: selected ? const Color(0xFFEAF0FF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _reason = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE9EEFF),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : _muted,
                size: 19,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  _reasons[index],
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
