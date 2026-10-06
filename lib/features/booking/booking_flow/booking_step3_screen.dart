import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import 'booking_step4_screen.dart';

class BookingStep3Screen extends StatelessWidget {
  const BookingStep3Screen({super.key});

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
            Text('SPORTSBOOK â€¢ BOOKING FLOW', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            Text('Secure Payment', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Text('Flow', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
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
            children: const [
              Text('LKR 5,825 ', style: TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w800)),
              Text('inclusive of taxes', style: TextStyle(color: muted, fontSize: 11)),
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
                    children: const [
                      Text('Booking CSA Arena â€¢ Court #', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                      Text('Today 6:00 PM - 8:00 PM (2 hrs)', style: TextStyle(color: muted, fontSize: 10)),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary),
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
                        const Text('â€¢â€¢â€¢â€¢ 4821 â€¢ Kasun Perera â€¢ Exp 09/27', style: TextStyle(color: muted, fontSize: 10)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text('842', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Save card for future 1-tap bookings', style: TextStyle(color: muted, fontSize: 10)),
                  Container(width: 16, height: 16, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
          child: Row(
            children: [
              Container(width: 20, height: 20, decoration: BoxDecoration(color: softBlue, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Sampath Bank Mastercard', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('â€¢â€¢â€¢â€¢ 9012 â€¢ Kasun P. â€¢ Exp 11/26', style: TextStyle(color: muted, fontSize: 10)),
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
        ),
        const SizedBox(height: 12),
        Container(
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
            Expanded(child: _walletCard('G!', 'Genie', 'by Dialog Axiata')),
            const SizedBox(width: 12),
            Expanded(child: _walletCard('FM', 'FriMi', 'Nations Trust Bank')),
          ],
        ),
        const SizedBox(height: 12),
        _walletRow('LankaPay', 'LankaPay / JustPay', 'Instant Direct Bank Debit (Any LK Bank)', '0% Fee'),
        const SizedBox(height: 12),
        _walletRow('icon', 'Apple Pay / Google Wallet', 'Fast contactless authentication', null),
      ],
    );
  }

  Widget _walletCard(String icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(6)), child: Text(icon, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800))),
              const Icon(Icons.chevron_right_rounded, size: 16, color: muted),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _walletRow(String iconStr, String title, String subtitle, String? tag) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
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
          const Icon(Icons.chevron_right_rounded, size: 16, color: muted),
        ],
      ),
    );
  }

  Widget _buildVenueCounterPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Venue Counter Payment', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
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
                    Expanded(child: Text('Requires LKR 1,200 advance slot deposit now; remainder (LKR 4,625) upon arrival at reception.', style: TextStyle(color: muted, fontSize: 10, height: 1.4))),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingStep4Screen()));
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
                  Icon(Icons.lock, size: 16),
                  SizedBox(width: 8),
                  Text('Pay LKR 5,825 Securely', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
