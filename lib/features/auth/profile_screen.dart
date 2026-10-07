import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../support/help_support_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 24),
              const _ProfileHeader(),
              const SizedBox(height: 16),
              const _StatsRow(),
              const SizedBox(height: 24),
              const _PlayerCredentials(),
              const SizedBox(height: 24),
              const _BookingPreferences(),
              const SizedBox(height: 24),
              const _PaymentCredits(),
              const SizedBox(height: 24),
              const _TopBookedVenues(),
              const SizedBox(height: 24),
              const _PreferencesSecurity(),
              const SizedBox(height: 32),
              const _LogoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Sportsbook User\nProfile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: Color(0xFF11182D),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined, color: Color(0xFF4A5568)),
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF4A5568)),
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon, {this.action});
  final String title;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF11182D),
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x0A001844), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFE5EAFF),
                      backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Player+One&background=E5EAFF&color=0052CC&size=150'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.pause, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Kasun Perera',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF11182D)),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.verified, color: AppColors.primary, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 11, color: Color(0xFF737A8E)),
                          children: [
                            TextSpan(text: 'ID: SB-LK-89410  •  '),
                            TextSpan(text: 'GOLD TIER', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 12),
                            SizedBox(width: 4),
                            Text('Frequent Booker • 18 matches', style: TextStyle(fontSize: 11, color: Color(0xFF4A5568), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F4FF)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 14),
                        SizedBox(width: 6),
                        Text('kasun.perera@gmail.com', style: TextStyle(fontSize: 12, color: Color(0xFF4A5568), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_outlined, color: AppColors.primary, size: 14),
                        SizedBox(width: 6),
                        Text('+94 77 123 4567', style: TextStyle(fontSize: 12, color: Color(0xFF4A5568), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(Icons.emoji_events_outlined, '24', 'Matches'),
        _buildStatCard(Icons.timer_outlined, '42h', 'Court Time'),
        _buildStatCard(Icons.savings_outlined, '4.2k', 'LKR\nSaved'),
        _buildStatCard(Icons.star_outline_rounded, '4.9', 'Fairplay'),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A001844), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF737A8E), fontWeight: FontWeight.w600, height: 1.2)),
        ],
      ),
    );
  }
}

class _PlayerCredentials extends StatelessWidget {
  const _PlayerCredentials();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionTitle(
          'Player Credentials',
          Icons.badge_outlined,
          action: Text('Edit >', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x08001844), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('BADMINTON', style: TextStyle(fontSize: 10, color: Color(0xFF737A8E), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                          child: const Text('BWF\n4.2', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Competitive', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
                    const SizedBox(height: 2),
                    const Text('Advanced Men\'s\nSingles', style: TextStyle(fontSize: 12, color: Color(0xFF737A8E), height: 1.3)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x08001844), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('TENNIS', style: TextStyle(fontSize: 10, color: Color(0xFF737A8E), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE5EAFF), borderRadius: BorderRadius.circular(6)),
                          child: const Text('ITN 6', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Intermediate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
                    const SizedBox(height: 2),
                    const Text('Social Doubles Club\n', style: TextStyle(fontSize: 12, color: Color(0xFF737A8E), height: 1.3)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFFFFEBEB), shape: BoxShape.circle),
                child: const Icon(Icons.medical_services_outlined, color: Colors.redAccent, size: 16),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency ICE Contact', style: TextStyle(fontSize: 11, color: Color(0xFF737A8E), fontWeight: FontWeight.w600)),
                    Text('Suneth P. (Brother)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF11182D))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: const Row(
                  children: [
                    Icon(Icons.phone_outlined, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text('Dial', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingPreferences extends StatelessWidget {
  const _BookingPreferences();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionTitle(
          'Booking Preferences',
          Icons.tune_rounded,
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(12)),
            child: const Text('Auto-Applied', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0x0A001844), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SPORT PRIORITY', style: TextStyle(fontSize: 10, color: Color(0xFF737A8E), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Badminton', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          SizedBox(width: 6),
                          Text('Primary', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_tennis_outlined, color: Color(0xFF737A8E), size: 16),
                          SizedBox(width: 6),
                          Text('Tennis', style: TextStyle(color: Color(0xFF4A5568), fontSize: 13, fontWeight: FontWeight.w600)),
                          SizedBox(width: 6),
                          Text('Secondary', style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(14)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PREFERRED SURFACE', style: TextStyle(fontSize: 9, color: Color(0xFF737A8E), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          SizedBox(height: 4),
                          Text('Indoor Parquet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
                          SizedBox(height: 2),
                          Text('Alt: Synthetic BWF Mat', style: TextStyle(fontSize: 11, color: Color(0xFF737A8E), height: 1.3)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(14)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PREFERRED WINDOW', style: TextStyle(fontSize: 9, color: Color(0xFF737A8E), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          SizedBox(height: 4),
                          Text('Floodlit Evenings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
                          SizedBox(height: 2),
                          Text('06:00 PM - 09:00 PM', style: TextStyle(fontSize: 11, color: Color(0xFF737A8E), height: 1.3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GEAR & SIZING KIT', style: TextStyle(fontSize: 10, color: Color(0xFF737A8E), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        Text('Pre-Filled in Rentals', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        const Expanded(child: Text('26 lbs Tension • G4 Towel Grip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF11182D)))),
                        const Icon(Icons.do_not_step_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: const Text('UK 9 / EUR 43', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF11182D))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Auto-Invite Default Squad', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
                              SizedBox(width: 6),
                              Icon(Icons.group_add_outlined, color: AppColors.primary, size: 16),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('Dinuth K., Sahan P., Navin H.', style: TextStyle(fontSize: 12, color: Color(0xFF4A5568))),
                        ],
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentCredits extends StatelessWidget {
  const _PaymentCredits();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionTitle(
          'Payment & Credits',
          Icons.account_balance_wallet_outlined,
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: const Row(
              children: [
                Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text('Add Card', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COURT CREDIT BALANCE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('LKR ', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('1,850.00', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.0)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Valid across all registered Colombo\ncourts.', style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text('Top\nUp', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800, height: 1.1)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCardItem(
          icon: 'VISA',
          title: 'Commercial Bank Debit',
          subtitle: '**** 4321 • Exp 06/27',
          isDefault: true,
          isSelected: true,
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          icon: 'Master',
          title: 'Sampath Bank Platinum',
          subtitle: '**** 9012 • Exp 11/25',
          isDefault: false,
          isSelected: false,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('Genie by\nDialog', style: TextStyle(color: Color(0xFF11182D), fontSize: 11, fontWeight: FontWeight.w700, height: 1.1)),
                    const SizedBox(width: 12),
                    const Text('Linked', style: TextStyle(color: Color(0xFF737A8E), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('LankaPay\nDirect', style: TextStyle(color: Color(0xFF11182D), fontSize: 11, fontWeight: FontWeight.w700, height: 1.1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardItem({required String icon, required String title, required String subtitle, required bool isDefault, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF8F9FD) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Text(icon, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF11182D))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE5EAFF), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Default', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF737A8E))),
              ],
            ),
          ),
          Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? AppColors.primary : const Color(0xFFCBD5E0)),
        ],
      ),
    );
  }
}

class _TopBookedVenues extends StatelessWidget {
  const _TopBookedVenues();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionTitle(
          'Top Booked Venues',
          Icons.calendar_month_outlined,
          action: Row(
            children: [
              Text('History (18)', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
              Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 14),
            ],
          ),
        ),
        _buildVenueItem(
          'CSA National Sports Arena',
          'Torrington Ave, Colombo 07',
          '12 Bookings',
          'Last: 2 days ago',
          Colors.blue[100]!,
        ),
        _buildVenueItem(
          'Liberty Courts Colombo',
          'Kollupitiya, Colombo 03',
          '4 Bookings',
          'Tennis Doubles',
          Colors.orange[100]!,
        ),
        _buildVenueItem(
          'Royal College Sports Complex',
          'Rajakeeya Mawatha, Colombo 07',
          '2 Bookings',
          'Weekend League',
          Colors.brown[100]!,
        ),
      ],
    );
  }

  Widget _buildVenueItem(String name, String address, String count, String subtext, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF11182D))),
                const SizedBox(height: 2),
                Text(address, style: const TextStyle(fontSize: 12, color: Color(0xFF737A8E))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(height: 2),
              Text(subtext, style: const TextStyle(fontSize: 10, color: Color(0xFF4A5568))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreferencesSecurity extends StatelessWidget {
  const _PreferencesSecurity();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionTitle('Preferences & Security', Icons.settings_outlined),
        _buildToggleItem(Icons.notifications_active_outlined, 'Match Reminders (40m Prior)', 'Push notifications and SMS', true),
        const SizedBox(height: 16),
        _buildToggleItem(Icons.flash_on_outlined, 'Slot Drop & Opening Alerts', 'When peak hours become available', true),
        const SizedBox(height: 16),
        _buildToggleItem(Icons.wb_cloudy_outlined, 'Rain & Weather Cancellations', 'Instant auto-refund to wallet', true),
        const SizedBox(height: 20),
        _buildActionItem(Icons.fingerprint, 'Biometric / FaceID Login', 'Apple FaceID Active', 'Enabled'),
        const SizedBox(height: 12),
        _buildActionItem(Icons.security, '2-Factor Authentication', 'SMS code to +94 77 *** 4567', 'Active'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
          },
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('24/7 Player Concierge & Issue\nReporting', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF11182D), height: 1.2)),
                    SizedBox(height: 4),
                    Text('Net tears, lighting issues, or refund\ndisputes', style: TextStyle(fontSize: 11, color: Color(0xFF4A5568))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF737A8E), size: 14),
            ],
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xFFF1F4FF), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF11182D))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF737A8E))),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (_) {},
          activeColor: Colors.white,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF11182D))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF737A8E))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE5EAFF), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton.icon(
            onPressed: () async { final supabase = Supabase.instance.client; await supabase.auth.signOut(); if (!context.mounted) return; Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false); },
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Log Out of SportsBook', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              backgroundColor: const Color(0xFFFFF0F0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'SportsBook LK • V2.4.0 (Build 8114)',
          style: TextStyle(color: Color(0xFF737A8E), fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: AppColors.primary, size: 10),
            SizedBox(width: 4),
            Text(
              'Colombo Sports Authority Certified Partner',
              style: TextStyle(color: Color(0xFF4A5568), fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
