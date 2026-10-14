import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/booking_draft.dart';
import '../../../core/supabase_service.dart';
import '../../../core/toast.dart';
import 'booking_step4_screen.dart';
import 'booking_flow_exit.dart';
import 'booking_flow_popup.dart';

class BookingStep3Screen extends StatefulWidget {
  const BookingStep3Screen({super.key});

  @override
  State<BookingStep3Screen> createState() => _BookingStep3ScreenState();
}

class _BookingStep3ScreenState extends State<BookingStep3Screen> {
  String _method = 'visa';
  bool _saveCard = true;
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _cvv.dispose();
    super.dispose();
  }

  bool get _counter => _method == 'counter';

  /// Card entered in this session. Only the last 4 digits are kept - never the full number or CVV.
  ({String last4, String name, String exp})? _newCard;

  static bool _luhn(String digits) {
    var sum = 0;
    var alt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  Future<void> _addCard() async {
    final number = TextEditingController();
    final name = TextEditingController();
    final exp = TextEditingController();
    final cvv = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Credit / Debit Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
              const SizedBox(height: 16),
              TextFormField(
                controller: number,
                keyboardType: TextInputType.number,
                maxLength: 19,
                decoration: const InputDecoration(labelText: 'Card number', counterText: ''),
                validator: (v) {
                  final d = (v ?? '').replaceAll(RegExp(r'\s'), '');
                  return (d.length >= 13 && d.length <= 19 && RegExp(r'^\d+$').hasMatch(d) && _luhn(d)) ? null : 'Enter a valid card number';
                },
              ),
              TextFormField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name on card'),
                validator: (v) => (v ?? '').trim().length < 2 ? 'Enter the cardholder name' : null,
              ),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: exp,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', counterText: ''),
                    validator: (v) {
                      final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch((v ?? '').trim());
                      if (m == null) return 'Use MM/YY';
                      final month = int.parse(m.group(1)!);
                      final year = 2000 + int.parse(m.group(2)!);
                      final now = DateTime.now();
                      if (month < 1 || month > 12) return 'Invalid month';
                      if (DateTime(year, month + 1).isBefore(now)) return 'Card expired';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: cvv,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(labelText: 'CVV', counterText: ''),
                    validator: (v) => RegExp(r'^\d{3,4}$').hasMatch((v ?? '').trim()) ? null : 'Invalid CVV',
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Use this card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == true) {
      final digits = number.text.replaceAll(RegExp(r'\s'), '');
      setState(() {
        _newCard = (last4: digits.substring(digits.length - 4), name: name.text.trim(), exp: exp.text.trim());
        _method = 'newcard';
      });
    }
    for (final c in [number, name, exp, cvv]) {
      c.dispose();
    }
  }

  final _service = SupabaseService();
  bool _paying = false;

  static const _methodLabels = {
    'visa': 'Visa •••• 4821',
    'newcard': 'Card',
    'sampath': 'Mastercard •••• 9012',
    'genie': 'Genie by Dialog',
    'frimi': 'FriMi',
    'lankapay': 'LankaPay / JustPay',
    'wallet': 'Apple Pay / Google Wallet',
    'counter': 'Pay at venue counter',
  };

  double get _payNow => _counter ? 1200.0 : BookingDraft.share;

  Future<void> _pay() async {
    final venueId = BookingDraft.venue?['id'] as String?;
    if (venueId == null) {
      toast('This venue is not bookable (no venue selected).');
      return;
    }
    if (_service.currentUser == null) {
      toast('Please sign in to complete your booking.');
      return;
    }
    setState(() => _paying = true);
    try {
      final ref = 'SB-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
      final pin = (1000 + DateTime.now().microsecondsSinceEpoch % 9000).toString();
      await _service.createBooking(
        venueId: venueId,
        bookingRef: ref,
        courtName: BookingDraft.courtName,
        dateSchedule: BookingDraft.dateIso,
        timeSlot: BookingDraft.slotLabels.join(', '),
        totalPaid: _payNow,
        qrPin: pin,
        addons: [
          if (BookingDraft.addonsLabel.isNotEmpty) {'label': BookingDraft.addonsLabel, 'fee': BookingDraft.gearFee},
          {'payment_method': _methodLabels[_method], 'full_total': BookingDraft.total},
        ],
      );
      BookingDraft.bookingRef = ref;
      BookingDraft.pin = pin;
      BookingDraft.paymentLabel = _method == 'newcard' ? 'Card •••• ${_newCard?.last4 ?? ''}' : (_methodLabels[_method] ?? 'Card');
      if (!mounted) return;
      showBookingStepPopup(context, const BookingStep4Screen());
    } catch (e) {
      if (mounted) {
        final msg = '$e';
        toast(msg.contains('just been booked') ? 'That slot was just taken by someone else. Go back and pick another.' : 'Booking failed: $msg');
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SPORTSBOOK • BOOKING FLOW', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            Text('Secure Payment', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Close booking flow',
            icon: const Icon(Icons.close_rounded, color: ink),
            onPressed: () => closeBookingFlow(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _buildPaymentAmount(),
                  const SizedBox(height: 24),
                  _buildPaymentMethod(),
                  const SizedBox(height: 24),
                  _buildDigitalWallets(),
                  const SizedBox(height: 24),
                  _buildVenueCounterPayment(),
                  const SizedBox(height: 24),
                  _buildSecurityBadges(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text('STEP 3 OF 4', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
          const Spacer(),
          const Text('Final Confirmation Next', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(width: 16, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 16, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 16, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCE7FF), borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildPaymentAmount() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('Court slot locked: 08:41', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Color(0xFFF4F7FF), shape: BoxShape.circle),
                child: const Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('AMOUNT TO PAY', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('LKR ${BookingDraft.money(_payNow)} ', style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w800)),
              Text(_counter ? 'deposit now' : 'inclusive of taxes', style: const TextStyle(color: muted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.sports_tennis_rounded, size: 16, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${BookingDraft.venueName} • ${BookingDraft.courtName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                      Text('${BookingDraft.dateLabel}, ${BookingDraft.timeRange}', style: const TextStyle(color: muted, fontSize: 10)),
                    ],
                  ),
                ),
                const Icon(Icons.verified_outlined, size: 16, color: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Payment Method', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
            Text('TAP TO CHANGE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _method = 'visa'), child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _method == 'visa' ? const Color(0xFFF4F7FF) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _method == 'visa' ? AppColors.primary : const Color(0xFFE9EEFF), width: _method == 'visa' ? 1.5 : 1)),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(_method == 'visa' ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: _method == 'visa' ? AppColors.primary : muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Commercial Bank\nVisa Debit', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800, height: 1.2)),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(10)), child: const Text('Preferred', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('•••• 4821 • Kasun Perera • Exp 09/27', style: TextStyle(color: muted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: const Color(0xFFE5E7EB),
                    child: const Text('VISA', style: TextStyle(color: Color(0xFF1A1F71), fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              if (_method == 'visa') ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFDCE7FF), height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Text('Security Code (CVV)', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                          SizedBox(width: 4),
                          Icon(Icons.help_outline_rounded, size: 12, color: muted),
                        ],
                      ),
                      Text('3 digits on back', style: TextStyle(color: muted, fontSize: 10)),
                    ],
                  ),
                  Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: _cvv,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 3,
                      textAlign: TextAlign.center,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2),
                      decoration: const InputDecoration(border: InputBorder.none, counterText: '', hintText: '•••'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Save card for future 1-tap bookings', style: TextStyle(color: muted, fontSize: 10)),
                  InkWell(
                    onTap: () => setState(() => _saveCard = !_saveCard),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(color: _saveCard ? AppColors.primary : Colors.white, border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(4)),
                      child: _saveCard ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                    ),
                  ),
                ],
              ),
              ],
            ],
          ),
        )),
        const SizedBox(height: 12),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _method = 'sampath'), child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _method == 'sampath' ? AppColors.primary : const Color(0xFFE9EEFF), width: _method == 'sampath' ? 1.5 : 1)),
          child: Row(
            children: [
              Icon(_method == 'sampath' ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 20, color: _method == 'sampath' ? AppColors.primary : muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Sampath Bank Mastercard', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('•••• 9012 • Kasun P. • Exp 11/26', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  Transform.translate(offset: const Offset(-4, 0), child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.8), shape: BoxShape.circle))),
                ],
              ),
            ],
          ),
        )),
        const SizedBox(height: 12),
        if (_newCard != null) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _method = 'newcard'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _method == 'newcard' ? AppColors.primary : const Color(0xFFE9EEFF), width: _method == 'newcard' ? 1.5 : 1)),
              child: Row(
                children: [
                  Icon(_method == 'newcard' ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 20, color: _method == 'newcard' ? AppColors.primary : muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Card •••• ${_newCard!.last4}', style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('${_newCard!.name} • Exp ${_newCard!.exp}', style: const TextStyle(color: muted, fontSize: 10)),
                      ],
                    ),
                  ),
                  const Icon(Icons.credit_card_rounded, size: 18, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _addCard,
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_card_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Add New Credit / Debit Card', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildDigitalWallets() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Text('Digital Wallets & Instant Pay', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.2))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: const Text('Fast\nCheckout', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _walletCard('genie', 'G!', 'Genie', 'by Dialog Axiata')),
            const SizedBox(width: 12),
            Expanded(child: _walletCard('frimi', 'FM', 'FriMi', 'Nations Trust Bank')),
          ],
        ),
        const SizedBox(height: 12),
        _walletRow('lankapay', 'LankaPay', 'LankaPay / JustPay', 'Instant Direct Bank Debit (Any LK Bank)', '0% Fee'),
        const SizedBox(height: 12),
        _walletRow('wallet', 'icon', 'Apple Pay / Google Wallet', 'Fast contactless authentication', null),
      ],
    );
  }

  Widget _walletCard(String id, String icon, String title, String subtitle) {
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _method = id), child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _method == id ? AppColors.primary : const Color(0xFFE9EEFF), width: _method == id ? 1.5 : 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)), child: Text(icon, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800))),
              Icon(_method == id ? Icons.check_circle_rounded : Icons.chevron_right_rounded, size: 16, color: _method == id ? AppColors.primary : muted),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    ));
  }

  Widget _walletRow(String id, String iconStr, String title, String subtitle, String? tag) {
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _method = id), child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _method == id ? AppColors.primary : const Color(0xFFE9EEFF), width: _method == id ? 1.5 : 1)),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: iconStr == 'icon' ? const Icon(Icons.contactless_outlined, size: 16, color: ink) : Text(iconStr, style: const TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    if (tag != null) ...[
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(10)), child: Text(tag, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))),
                    ],
                  ],
                ),
                Text(subtitle, style: const TextStyle(color: muted, fontSize: 10)),
              ],
            ),
          ),
          Icon(_method == id ? Icons.check_circle_rounded : Icons.chevron_right_rounded, size: 16, color: _method == id ? AppColors.primary : muted),
        ],
      ),
    ));
  }

  Widget _buildVenueCounterPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Venue Counter Payment', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _method = 'counter'), child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _method == 'counter' ? AppColors.primary : const Color(0xFFE9EEFF), width: _method == 'counter' ? 1.5 : 1)),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.storefront_outlined, size: 16, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Pay at Facility Counter', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('Cash or Card at Reception', style: TextStyle(color: muted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)), child: const Text('Split Pay', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(child: Text('Requires LKR 1,200 advance slot deposit now; the remainder upon arrival at reception.', style: TextStyle(color: muted, fontSize: 10, height: 1.4))),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSecurityBadges() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: Row(children: const [Icon(Icons.lock_outline, size: 10, color: AppColors.primary), SizedBox(width: 4), Text('256-Bit SSL', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))])),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: Row(children: const [Icon(Icons.verified_user_outlined, size: 10, color: AppColors.primary), SizedBox(width: 4), Text('PCI-DSS Level 1', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))])),
          ],
        ),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.shield_outlined, size: 10, color: AppColors.primary), SizedBox(width: 4), Text('LankaPay Secured', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))])),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Regulated and protected in compliance with the Central Bank of Sri Lanka (CBSL) Electronic Payment Directives.', style: TextStyle(color: muted, fontSize: 9, height: 1.4), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_paying || (_method == 'visa' && _cvv.text.length < 3)) ? null : _pay,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 16),
                  const SizedBox(width: 8),
                  Text(_paying ? 'Processing…' : (_counter ? 'Pay LKR 1,200 Deposit Now' : (_method == 'visa' && _cvv.text.length < 3 ? 'Enter CVV to pay' : 'Pay LKR ${BookingDraft.money(_payNow)} Securely')), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.gavel_rounded, size: 10, color: muted),
              SizedBox(width: 4),
              Text('BY CONFIRMING, YOU AGREE TO CSA ARENA RULES &\nSPORTSBOOK TERMS', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w700, height: 1.4), textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}
