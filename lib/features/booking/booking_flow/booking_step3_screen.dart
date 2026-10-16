import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/booking_draft.dart';
import '../../../core/supabase_service.dart';
import '../../../core/toast.dart';
import 'booking_flow_exit.dart';
import 'booking_flow_popup.dart';
import 'booking_step4_screen.dart';

class BookingStep3Screen extends StatefulWidget {
  const BookingStep3Screen({super.key});

  @override
  State<BookingStep3Screen> createState() => _BookingStep3ScreenState();
}

class _BookingStep3ScreenState extends State<BookingStep3Screen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);

  final _service = SupabaseService();
  bool _saving = false;

  double get _totalDue => BookingDraft.total > 0
      ? BookingDraft.total
      : BookingDraft.courtFee + BookingDraft.gearFee;

  Future<void> _confirmReservation() async {
    final venueId = BookingDraft.venue?['id'] as String?;
    if (venueId == null) {
      toast('This venue is not bookable. Go back and choose a venue.');
      return;
    }
    if (_service.currentUser == null) {
      toast('Please sign in to reserve this court.');
      return;
    }

    setState(() => _saving = true);
    try {
      final ref =
          'SB-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
      final pin = (1000 + DateTime.now().microsecondsSinceEpoch % 9000)
          .toString();
      await _service.createBooking(
        venueId: venueId,
        bookingRef: ref,
        courtName: BookingDraft.courtName,
        dateSchedule: BookingDraft.dateIso,
        timeSlot: BookingDraft.slotLabels.join(', '),
        // Checkout is not connected to a payment gateway. Keep the amount
        // outstanding instead of recording a payment that never happened.
        totalPaid: 0,
        qrPin: pin,
        addons: [
          if (BookingDraft.addonsLabel.isNotEmpty)
            {'label': BookingDraft.addonsLabel, 'fee': BookingDraft.gearFee},
          {
            'payment_method': 'Pay at venue',
            'payment_status': 'Due at venue',
            'full_total': _totalDue,
          },
        ],
      );
      BookingDraft.bookingRef = ref;
      BookingDraft.pin = pin;
      BookingDraft.paymentLabel = 'Pay at venue';
      if (!mounted) return;
      showBookingStepPopup(context, const BookingStep4Screen());
    } catch (e) {
      if (!mounted) return;
      final message = '$e';
      toast(
        message.contains('just been booked')
            ? 'That slot was just taken. Go back and choose another time.'
            : 'Could not reserve this court: $message',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to booking summary',
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPORTSBOOK • BOOKING FLOW',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Confirm reservation',
              style: TextStyle(
                color: _ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Close booking flow',
            icon: const Icon(Icons.close_rounded, color: _ink),
            onPressed: () => closeBookingFlow(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _progress(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _bookingSummary(),
                  const SizedBox(height: 16),
                  _paymentOption(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(top: false, child: _bottomBar()),
    );
  }

  Widget _progress() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      children: [
        const Text(
          'STEP 3 OF 4',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        for (var i = 0; i < 4; i++) ...[
          Container(
            width: i == 3 ? 5 : 16,
            height: 4,
            decoration: BoxDecoration(
              color: i < 3 ? AppColors.primary : const Color(0xFFDCE7FF),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i < 3) const SizedBox(width: 4),
        ],
      ],
    ),
  );

  Widget _bookingSummary() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reservation summary',
          style: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        _detail('Venue', BookingDraft.venueName),
        _detail(
          'Court',
          '${BookingDraft.courtName} • ${BookingDraft.courtType}',
        ),
        _detail('Date', BookingDraft.dateLabel),
        _detail(
          'Time',
          BookingDraft.timeRange.isEmpty
              ? BookingDraft.slotLabels.join(', ')
              : BookingDraft.timeRange,
        ),
        const Divider(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Total due at venue',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ),
            Text(
              'LKR ${BookingDraft.money(_totalDue)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.trim().isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _paymentOption() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay at venue',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pay the venue directly when you arrive.',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Online card and wallet payments are not connected. No payment is collected in this app; the amount above remains due to the venue.',
                  style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 10,
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
            onPressed: _saving ? null : _confirmReservation,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const StadiumBorder(),
            ),
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.event_available_rounded, size: 18),
            label: Text(_saving ? 'Reserving…' : 'Confirm reservation'),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'You will pay the venue directly on arrival.',
          style: TextStyle(color: _muted, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
