import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/booking_draft.dart';
import 'booking_flow_exit.dart';
import 'booking_flow_popup.dart';
import 'booking_step3_screen.dart';

class BookingStep2Screen extends StatelessWidget {
  const BookingStep2Screen({super.key});

  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    final amount = BookingDraft.courtFee;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to slot selection',
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
              'Review reservation',
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _venueCard(context),
                  const SizedBox(height: 16),
                  _priceCard(amount),
                  const SizedBox(height: 16),
                  _paymentNotice(),
                  const SizedBox(height: 16),
                  _availabilityNotice(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _bottomBar(context, amount),
      ),
    );
  }

  Widget _progress() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      children: [
        const Text(
          'STEP 2 OF 4',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          ' • Confirm your booking details',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
        const Spacer(),
        for (var i = 0; i < 4; i++) ...[
          Container(
            width: i == 3 ? 5 : 16,
            height: 4,
            decoration: BoxDecoration(
              color: i < 2 ? AppColors.primary : const Color(0xFFDCE7FF),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i < 3) const SizedBox(width: 4),
        ],
      ],
    ),
  );

  Widget _venueCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BookingDraft.venueName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    BookingDraft.venueArea.isEmpty
                        ? BookingDraft.sport
                        : BookingDraft.venueArea,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit_outlined, size: 15),
              label: const Text('Edit'),
            ),
          ],
        ),
        const Divider(height: 28, color: Color(0xFFE9EEFF)),
        _detail('Sport', BookingDraft.sport),
        _detail('Court', BookingDraft.courtName),
        if (BookingDraft.courtType.trim().isNotEmpty)
          _detail('Surface', BookingDraft.courtType),
        _detail('Date', BookingDraft.dateLabel),
        _detail(
          'Time',
          BookingDraft.timeRange.isEmpty
              ? BookingDraft.slotLabels.join(', ')
              : BookingDraft.timeRange,
        ),
        _detail(
          'Duration',
          '${BookingDraft.hours == BookingDraft.hours.roundToDouble() ? BookingDraft.hours.round() : BookingDraft.hours} ${BookingDraft.hours == 1 ? 'hour' : 'hours'}',
        ),
      ],
    ),
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
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

  Widget _priceCard(double amount) => Container(
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
          'Price summary',
          style: TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Court reservation',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ),
            Text(
              'LKR ${BookingDraft.money(amount)}',
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1, color: Color(0xFFE9EEFF)),
        ),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Total due at venue',
                style: TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'LKR ${BookingDraft.money(amount)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _paymentNotice() => _notice(
    icon: Icons.storefront_outlined,
    title: 'Pay the venue on arrival',
    message: 'This reservation does not collect money in the app. Pay the venue directly when you arrive.',
  );

  Widget _availabilityNotice() => _notice(
    icon: Icons.info_outline_rounded,
    title: 'Slot availability can change',
    message: 'We will check the selected time again when you confirm. If it has been booked, choose another available slot.',
  );

  Widget _notice({
    required IconData icon,
    required String title,
    required String message,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bottomBar(BuildContext context, double amount) => Container(
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
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DUE AT VENUE',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'LKR ${BookingDraft.money(amount)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              BookingDraft.setCheckout(
                gearFee: 0,
                discount: 0,
                tax: 0,
                total: amount,
                share: amount,
                gearLabel: 'No gear selected',
              );
              showBookingStepPopup(context, const BookingStep3Screen());
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Continue'),
          ),
        ),
      ],
    ),
  );
}
