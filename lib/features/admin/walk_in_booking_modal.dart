import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'admin_profile_screen.dart';

class WalkInBookingModal extends StatelessWidget {
  const WalkInBookingModal({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildAppBar(context),
            const SizedBox(height: 16),
            _buildSubHeader(),
            const SizedBox(height: 24),
            _buildStep1(),
            const SizedBox(height: 24),
            _buildStep2(),
            const SizedBox(height: 24),
            _buildStep3(),
            const SizedBox(height: 24),
            _buildStep4(),
            const SizedBox(height: 24),
            _buildFeeBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.close, color: ink, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('New Walk In Booking', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('DESK TERMINAL #04', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(16)),
            child: const Text('FAST\nINTAKE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Target <45s • CSA Counter\nTerminal #01', style: TextStyle(color: muted, fontSize: 10, height: 1.3)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: Text('Colombo Sports Authority\nArena', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700, height: 1.2))),
                    Row(
                      children: const [
                        Icon(Icons.circle, color: AppColors.primary, size: 4),
                        SizedBox(width: 4),
                        Text('Turnstiles Live &\nSynced', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700, height: 1.2)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: const [
              Icon(Icons.access_time, color: AppColors.primary, size: 12),
              SizedBox(height: 2),
              Text('10:31\nIST', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String number, String title, String action) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(action, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildStepHeader('1', 'Athlete Identification', 'LOOKUP & KYC'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: softBlue)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.flag, color: muted, size: 16), // Placeholder for Sri Lanka flag
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Mobile Number', style: TextStyle(color: muted, fontSize: 9)),
                    Text('+94 77 418 9201', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 14),
                label: const Text('Lookup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: softBlue), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))]),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Color(0xFFE5EDFF), shape: BoxShape.circle),
                    child: const Center(child: Text('KP', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text('Kasun\nPerera', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800, height: 1.1)),
                            SizedBox(width: 8),
                            Icon(Icons.verified, color: AppColors.primary, size: 14),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('+94 77 418 9201', style: TextStyle(color: muted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                    child: const Text('GOLD TIER • 16\nPLAYS', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.right),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    const Text('Wallet\nCredit:', style: TextStyle(color: muted, fontSize: 9, height: 1.2)),
                    const SizedBox(width: 12),
                    const Text('LKR\n1,850', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800, height: 1.1)),
                    const Spacer(),
                    const Text('NFC Card\nActive', style: TextStyle(color: muted, fontSize: 9, height: 1.2), textAlign: TextAlign.right),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: AppColors.primary, size: 6),
                      SizedBox(width: 6),
                      Text('Verified biometric\nprofile', style: TextStyle(color: muted, fontSize: 9, height: 1.2)),
                    ],
                  ),
                  const Text('SWITCH TO GUEST WALK-\nIN', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.right),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _buildStepHeader('2', 'Court & Time', 'COURT 2'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: softBlue)),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt_long, size: 16),
                      SizedBox(width: 8),
                      Text('Collect LKR 5,150 & Generate Gate QR\nPass', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.center),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: const [
                        Icon(Icons.print, color: AppColors.primary, size: 12),
                        SizedBox(width: 6),
                        Expanded(child: Text('Auto-print slip on\nCounter #01', style: TextStyle(color: muted, fontSize: 9, height: 1.2))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 12),
                        SizedBox(width: 6),
                        Expanded(child: Text('SMS + WhatsApp to +94\n77 418 9201', style: TextStyle(color: muted, fontSize: 9, height: 1.2))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_clock, size: 14, color: ink),
                  label: const Text('Save Draft / Hold Court Slot (3 mins)', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F9FA),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Colombo Sports Authority Arena Management System •\nCounter 01', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 8, height: 1.4)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _durationBtn('1.0 hr', false)),
                  const SizedBox(width: 8),
                  Expanded(child: _durationBtn('1.5 hrs', false)),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: _durationBtn('2.0 hrs • Active', true)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.primary, size: 14),
                    const SizedBox(width: 8),
                    const Text('Allocated Slot: 18:30 –\n20:30', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800, height: 1.2)),
                    const Spacer(),
                    const Text('2.0 HRS (LKR\n4,000)', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.right),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _durationBtn(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0D6EFD) : softBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: active ? Colors.white : ink, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Arena Gear &\nEquipment', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFD0DDFB), borderRadius: BorderRadius.circular(16)),
              child: const Text('3 Items\nAdded', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.center),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: softBlue)),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _gearRow(Icons.sports_tennis, 'Yonex Astrox', 'LKR 350 / session', '2', 'LKR 700'),
              const Divider(color: softBlue, height: 24),
              _gearRow(Icons.sports_baseball, 'Yonex AS - 30', 'LKR 450 / 3-pack', '1', 'LKR 450'),
              const Divider(color: softBlue, height: 24),
              _gearRow(Icons.directions_walk, 'Indoor Grip 5', 'LKR 250 / pair', '0', 'LKR 0'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Total Equipment Rental:', style: TextStyle(color: muted, fontSize: 10)),
                  Text('LKR 1,150', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gearRow(IconData icon, String title, String subtitle, String count, String price) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
              Text(subtitle, style: const TextStyle(color: muted, fontSize: 9)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Icon(Icons.remove, size: 14, color: muted),
              const SizedBox(width: 12),
              Text(count, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 50,
          child: Text(price, style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        _buildStepHeader('4', 'Settlement Method', 'COUNTER INSTANT'),
        const SizedBox(height: 12),
        _radioOption(
          Icons.money, 
          'Cash at Counter (Drawer 01)', 
          'Immediate drawer unlock • Physical slip\nprint', 
          true,
          true
        ),
        const SizedBox(height: 8),
        _radioOption(
          Icons.qr_code, 
          'LankaPay Dynamic QR / POS', 
          'Commercial Bank Terminal #02', 
          false,
          false
        ),
        const SizedBox(height: 8),
        _radioOption(
          Icons.account_balance_wallet, 
          'Athlete Wallet Bal. (LKR 1,850)', 
          'Partial balance (Requires LKR 3,300 split)', 
          false,
          false,
          subtitleColor: Colors.redAccent
        ),
      ],
    );
  }

  Widget _radioOption(IconData icon, String title, String subtitle, bool isSelected, bool isBlueBg, {Color? subtitleColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? softBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isBlueBg ? const Color(0xFF0D6EFD) : softBlue, shape: BoxShape.circle),
            child: Icon(icon, color: isBlueBg ? Colors.white : AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: subtitleColor ?? muted, fontSize: 9, height: 1.3)),
              ],
            ),
          ),
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF0D6EFD) : muted, size: 18),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BREAKDOWN OF FEES', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
                child: const Text('Terminal #01 Verified', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _feeRow('Court 2 Synthetic Mat (2.0 hrs @ LKR\n2,000/hr)', 'LKR\n4,000'),
          const SizedBox(height: 12),
          _feeRow('Equipment Rental (2 Rackets + 1 Shuttles\nTube)', 'LKR\n1,150'),
          const SizedBox(height: 12),
          _feeRow('CSA Arena Operations Levy &\nMunicipal Tax', 'LKR 0\n(Exempt)', valueColor: AppColors.primary),
          const Divider(color: softBlue, height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('TOTAL INGESTION AMOUNT', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Payable via Cash Desk', style: TextStyle(color: AppColors.primary, fontSize: 9)),
                  ],
                ),
              ),
              const Text('LKR 5,150', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value, {Color valueColor = ink}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: muted, fontSize: 10, height: 1.3))),
        Text(value, style: TextStyle(color: valueColor, fontSize: 10, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.right),
      ],
    );
  }
}
