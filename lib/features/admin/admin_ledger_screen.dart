import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'admin_profile_screen.dart';
import '../notifications/notifications_screen.dart';

class AdminLedgerScreen extends StatelessWidget {
  const AdminLedgerScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildAppBar(),
            const SizedBox(height: 20),
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildRevenueCard(),
            const SizedBox(height: 24),
            _buildRainCheckSection(),
            const SizedBox(height: 24),
            _buildIngestionFeed(),
            const SizedBox(height: 24),
            _buildVaultProtocol(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('APEX CENTER - SHIFT #402', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              Text('Shift Ledger & Payouts', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Builder(
          builder: (ctx) => Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                icon: const Icon(Icons.notifications_none_rounded, color: ink, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, color: AppColors.primary, size: 6),
                    SizedBox(width: 6),
                    Text('SHIFT 02 • EVENING', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 12, color: AppColors.primary),
                label: const Text('Export Z-PDF', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: softBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Text('CSA National Arena', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
              Text(' • Colombo • ', style: TextStyle(color: ink, fontSize: 11)),
              Text('Drawer #01', style: TextStyle(color: muted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today, 24 Oct (16:00 -\n23:00)', style: TextStyle(color: muted, fontSize: 10, height: 1.3)),
              Row(
                children: const [
                  Icon(Icons.sync, color: AppColors.primary, size: 12),
                  SizedBox(width: 4),
                  Text('Ledger Synced (Audit\nv2.4)', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700, height: 1.2)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: softBlue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SHIFT REVENUE INTAKE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up, color: AppColors.primary, size: 10),
                    SizedBox(width: 4),
                    Text('Target Met 112%', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('LKR 84,250', style: TextStyle(color: ink, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.check_circle_outline, color: AppColors.primary, size: 12),
              SizedBox(width: 4),
              Expanded(child: Text('48 Transactions Processed • Cash in Drawer\nVerified', style: TextStyle(color: muted, fontSize: 9, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(flex: 65, child: Container(height: 6, color: const Color(0xFF0D6EFD))),
                const SizedBox(width: 2),
                Expanded(flex: 25, child: Container(height: 6, color: const Color(0xFF3B82F6))),
                const SizedBox(width: 2),
                Expanded(flex: 10, child: Container(height: 6, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRevenueMetric('Cards & La...', 'LKR\n54,762', '65% of shift', const Color(0xFF0D6EFD))),
              const SizedBox(width: 8),
              Expanded(child: _buildRevenueMetric('Athlete Wa...', 'LKR\n21,063', '25% of shift', const Color(0xFF3B82F6))),
              const SizedBox(width: 8),
              Expanded(child: _buildRevenueMetric('Cash Draw...', 'LKR\n8,425', '10% in till', const Color(0xFF94A3B8), isMuted: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueMetric(String title, String value, String percent, Color dotColor, {bool isMuted = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: dotColor, size: 6),
              const SizedBox(width: 4),
              Expanded(child: Text(title, style: const TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 2),
          Text(percent, style: TextStyle(color: isMuted ? muted : AppColors.primary, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildRainCheckSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Rain-Check\nAction', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(12)),
              child: const Text('1\nPending', style: TextStyle(color: Color(0xFFE11D48), fontSize: 8, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.center),
            ),
            const Spacer(),
            const Text('SLA: 12m\nremaining', style: TextStyle(color: muted, fontSize: 10, height: 1.2), textAlign: TextAlign.right),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('#SB-COL-8921 • Tennis\nCourt B', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800, height: 1.2)),
                        SizedBox(height: 4),
                        Text('Logged 18 mins ago via Ground\nMarshal', style: TextStyle(color: muted, fontSize: 9, height: 1.3)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: const [
                        Icon(Icons.cloudy_snowing, color: AppColors.primary, size: 12),
                        SizedBox(width: 4),
                        Text('Weather\nVoid', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800, height: 1.2)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: Color(0xFFE5EDFF), shape: BoxShape.circle),
                      child: const Center(child: Text('DS', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Dilhara Senanayake', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                          Text('+94 71 882 1094 • Pro Tier', style: TextStyle(color: muted, fontSize: 9)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('REFUND DUE', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
                        Text('LKR 3,200', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.currency_exchange, size: 14),
                  label: const Text('Refund to Athlete Wallet (Instant • 0\nFee)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.2), textAlign: TextAlign.center),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.credit_card, size: 14, color: ink),
                  label: const Text('Card Gateway Reversal (2–3 Banking\nDays)', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w700, height: 1.2), textAlign: TextAlign.center),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: softBlue,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngestionFeed() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Shift Ingestion\nFeed', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(width: 12),
            Row(
              children: const [
                Icon(Icons.circle, color: AppColors.primary, size: 6),
                SizedBox(width: 4),
                Text('Live (12s\nago)', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, height: 1.2)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: const [
                  Icon(Icons.filter_list, color: muted, size: 12),
                  SizedBox(width: 6),
                  Text('ALL\n(48)', style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _feedRow(
          icon: Icons.public, // Representing visa/mastercard globe
          title: '#8941 • Kasun P.',
          pill: 'Court 1',
          subtitle: 'Visa Card (•••• 4812) • 18:02',
          amount: '+LKR 5,825',
          status: 'Cleared',
        ),
        _feedRow(
          icon: Icons.inventory_2, // Drawer
          title: '#8942 • Sahan P.',
          pill: 'Walk-In',
          subtitle: 'Counter Cash (Drawer 01) • 18...',
          amount: '+LKR 2,450',
          status: 'Cleared',
        ),
        _feedRow(
          icon: Icons.sports_tennis,
          title: 'Add-On • Yonex Rackets x2',
          pill: null,
          subtitle: 'LankaPay Dynamic QR • 18:25',
          amount: '+LKR 700',
          status: 'Cleared',
        ),
        _feedRow(
          icon: Icons.lock_outline,
          title: 'Locker #14 & #15',
          pill: 'Kasun P.',
          subtitle: 'Athlete Wallet Bal • 18:05',
          amount: '+LKR 300',
          status: 'Auto-Settled',
        ),
      ],
    );
  }

  Widget _feedRow({required IconData icon, required String title, String? pill, required String subtitle, required String amount, required String status}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))]),
      child: Row(
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
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                    if (pill != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(4)),
                        child: Text(pill, style: const TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: muted, fontSize: 9)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(status, style: const TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaultProtocol() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              const Expanded(child: Text('Vault Reconciliation Protocol', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFD0DDFB), borderRadius: BorderRadius.circular(12)),
                child: const Text('Ready', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Closing ledger seals turnstiles, verifies cash in\nDrawer #01, and hashes shift telemetry directly to\nthe Colombo Sports Authority Treasury ledger.', style: TextStyle(color: muted, fontSize: 10, height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_outline, size: 14, color: Colors.white),
              label: const Text('Reconcile & Close Evening Shift', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
