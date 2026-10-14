import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/booking_draft.dart';
import 'booking_step3_screen.dart';
import 'booking_flow_exit.dart';
import 'booking_flow_popup.dart';

class BookingStep2Screen extends StatefulWidget {
  const BookingStep2Screen({super.key});

  @override
  State<BookingStep2Screen> createState() => _BookingStep2ScreenState();
}

class _BookingStep2ScreenState extends State<BookingStep2Screen> {
  double get _courtFee => BookingDraft.courtFee;
  int _rackets = 2;
  int _shuttles = 1;
  bool _shoes = false;
  bool _split = true;
  bool _promo = true;

  double get _gear => _rackets * 300.0 + _shuttles * 450.0 + (_shoes ? 250 : 0);
  double get _subtotal => _courtFee + _gear;
  double get _discount => _promo ? 500 : 0;
  double get _tax => (_subtotal - _discount) * 0.05;
  double get _total => _subtotal - _discount + _tax;
  double get _share => _split ? _total / 4 : _total;

  String _money(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final whole = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '$whole.${parts[1]}';
  }

  String get _gearLabel {
    final items = <String>[
      if (_rackets > 0) '$_rackets Racket${_rackets > 1 ? 's' : ''}',
      if (_shuttles > 0) '$_shuttles Shuttle${_shuttles > 1 ? 's' : ''}',
      if (_shoes) '1 Shoes',
    ];
    return items.isEmpty ? 'No gear selected' : items.join(' + ');
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
            Text('Booking Checkout', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
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
                  _buildVenueCard(),
                  const SizedBox(height: 24),
                  _buildEquipment(),
                  const SizedBox(height: 24),
                  _buildSplitWithFriends(),
                  const SizedBox(height: 24),
                  _buildVoucher(),
                  const SizedBox(height: 24),
                  _buildPaymentSummary(),
                  const SizedBox(height: 24),
                  _buildCancellation(),
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
          const Text('STEP 2 OF 4', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
          const Text(' • Review & Add-ons', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(width: 16, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 16, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCE7FF), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCE7FF), borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildVenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)),
                child: Text(BookingDraft.sport.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Text('${BookingDraft.courtName} •\n${BookingDraft.courtType}', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w600, height: 1.2)),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
                  child: Row(
                    children: const [
                      Icon(Icons.edit_outlined, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(width: 48, height: 48, color: softBlue, child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(BookingDraft.venueName, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(child: Text(BookingDraft.venueArea, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 10))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MATCH SCHEDULE', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${BookingDraft.dateLabel} • ${BookingDraft.timeRange}', style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
                  child: Text('${BookingDraft.hours == BookingDraft.hours.roundToDouble() ? BookingDraft.hours.round() : BookingDraft.hours}\nHours', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipment() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.sports_tennis_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Equipment & Add-ons', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            Text('GEAR RENTAL', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        _gearItem(Icons.search_rounded, 'Yonex Astrox 88D Pro', 'LKR 300 / racket', _rackets, (v) => setState(() => _rackets = v)),
        const SizedBox(height: 12),
        _gearItem(Icons.sports_baseball_outlined, 'Feather Shuttles (Tube)', 'LKR 450 / tube', _shuttles, (v) => setState(() => _shuttles = v)),
        const SizedBox(height: 12),
        _gearItemAdd(Icons.do_not_step_rounded, 'Non-marking Court Shoes', 'Size 42 • LKR 250', _shoes, () => setState(() => _shoes = !_shoes)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.shower_outlined, size: 16, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Locker & Warm Shower', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('Clean towels and heated private lockers', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)),
                child: const Text('Complimentary', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gearItem(IconData icon, String title, String price, int count, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Text(price.split(' ')[0], style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                    Text(' ${price.substring(price.indexOf(' '))}', style: const TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.remove, size: 14), constraints: const BoxConstraints(), padding: const EdgeInsets.all(8), onPressed: count > 0 ? () => onChanged(count - 1) : null),
                Text('$count', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                Container(
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  margin: const EdgeInsets.all(4),
                  child: IconButton(icon: const Icon(Icons.add, size: 14, color: Colors.white), constraints: const BoxConstraints(), padding: const EdgeInsets.all(4), onPressed: count < 10 ? () => onChanged(count + 1) : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gearItemAdd(IconData icon, String title, String subtitle, bool added, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: muted, fontSize: 10)),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: added ? AppColors.primary : softBlue, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(added ? Icons.check_rounded : Icons.add, size: 14, color: added ? Colors.white : AppColors.primary),
                  const SizedBox(width: 4),
                  Text(added ? 'Added' : 'Add', style: TextStyle(color: added ? Colors.white : AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitWithFriends() {
    final share = 'LKR ${_money(_total / 4)}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.group_outlined, size: 16, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Split with Friends', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(_split ? 'Splitting between 4 players' : 'Paying the full amount yourself', style: const TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              CupertinoSwitch(value: _split, activeColor: AppColors.primary, onChanged: (v) => setState(() => _split = v)),
            ],
          ),
          if (_split) ...[
            const SizedBox(height: 16),
            _friendRow('Kasun', 'Paying now via card', share, isHost: true),
            _friendRow('Dimuth K.', 'Invited via WhatsApp', share),
            _friendRow('Sahan P.', 'Invited via SMS', share, initials: 'SP'),
            _friendRow('Nuwan R.', 'Invited via Link', share, initials: 'NR'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: const [
                  Icon(Icons.mobile_screen_share_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(child: Text('Payment links sent instantly to WhatsApp & SMS once confirmed.', style: TextStyle(color: muted, fontSize: 10))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _friendRow(String name, String status, String amount, {bool isHost = false, String? initials}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: initials != null 
              ? Text(initials, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800))
              : const Icon(Icons.person, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    if (isHost) ...[
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Text('HOST', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800))),
                    ]
                  ],
                ),
                Text(status, style: const TextStyle(color: muted, fontSize: 10)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: isHost ? AppColors.primary : muted, fontSize: 11, fontWeight: isHost ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildVoucher() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Voucher & Club Credits', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
            Text(_promo ? '1 Applied' : 'None applied', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: _promo ? 12 : 8),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.local_activity_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('COURTCONNECT', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
              const Spacer(),
              _promo
                  ? InkWell(onTap: () => setState(() => _promo = false), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 16, color: muted)))
                  : TextButton(onPressed: () => setState(() => _promo = true), child: const Text('Apply')),
            ],
          ),
        ),
        if (_promo) ...[
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
              SizedBox(width: 4),
              Text('-LKR 500 PROMO DISCOUNT APPLIED!', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Summary', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(10)), child: const Text('LKR CURRENCY', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow('Court Rental (${BookingDraft.courtName}, ${BookingDraft.hours == BookingDraft.hours.roundToDouble() ? BookingDraft.hours.round() : BookingDraft.hours} hrs)', 'LKR\n${_money(_courtFee)}'),
          const SizedBox(height: 12),
          _summaryRow('Gear Rentals ($_gearLabel)', 'LKR\n${_money(_gear)}'),
          const SizedBox(height: 12),
          _summaryRow('Arena Floodlights & Changing Access', 'Included', isIncluded: true),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFE9EEFF), height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
              Text('LKR ${_money(_subtotal)}', style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Promo Discount\n(COURTCONNECT)', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              Text('- LKR\n${_money(_discount)}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('City Sports Facility Tax (5%)', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
              Text('LKR ${_money(_tax)}', style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFE9EEFF), height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL MATCH AMOUNT', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                  Text('LKR ${_money(_total)}', style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_split ? 'YOUR SHARE (HOST)' : 'YOU PAY', style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                  Text('LKR ${_money(_share)}', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isIncluded = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title, style: const TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w500))),
        const SizedBox(width: 16),
        Text(value, style: TextStyle(color: isIncluded ? AppColors.primary : ink, fontSize: 11, fontWeight: isIncluded ? FontWeight.w600 : FontWeight.w800), textAlign: TextAlign.right),
      ],
    );
  }

  Widget _buildCancellation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle), child: const Icon(Icons.shield_rounded, size: 14, color: AppColors.primary)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('100% Guaranteed Cancellation', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Free cancellation until Today at 4:00 PM (2 hours before start). Full refund credited directly to original payment method.', style: TextStyle(color: muted, fontSize: 10, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('YOU PAY NOW', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(10)), child: const Text('Split active', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800))),
                  ],
                ),
                const SizedBox(height: 2),
                Text('LKR ${_money(_share)}', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
                Text('Full Total: LKR ${_money(_total)}', style: const TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: () {
                BookingDraft.setCheckout(gearFee: _gear, discount: _discount, tax: _tax, total: _total, share: _share, gearLabel: _gearLabel);
                showBookingStepPopup(context, const BookingStep3Screen());
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Proceed to Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
