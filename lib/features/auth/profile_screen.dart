import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import 'auth_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = SupabaseService();
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);
  double _balance = 1850;

  @override
  Widget build(BuildContext context) {
    final user = _service.currentUser;
    if (user == null) return _guestProfile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _service.getProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final name = profile?['full_name'] ?? user.email?.split('@').first ?? 'SportsBook User';
            final balance = (profile?['wallet_balance'] as num?)?.toDouble() ?? _balance;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _header(),
                const SizedBox(height: 16),
                _profileCard(name, user.email ?? ''),
                const SizedBox(height: 14),
                _stats(),
                const SizedBox(height: 20),
                _credentials(),
                const SizedBox(height: 20),
                _sectionTitle('Booking Preferences', action: 'Auto-Applied'),
                _preferences(),
                const SizedBox(height: 20),
                _sectionTitle('Payment & Credits', action: '+ Add Card'),
                _wallet(balance),
                const SizedBox(height: 20),
                _sectionTitle('Top Booked Venues', action: 'History (18) →'),
                _venues(),
                const SizedBox(height: 20),
                _sectionTitle('Preferences & Security'),
                _security(),
                const SizedBox(height: 22),
                SizedBox(width: double.infinity, child: TextButton.icon(onPressed: () async { await _service.signOut(); if (mounted) setState(() {}); }, icon: const Icon(Icons.logout_rounded, size: 17), label: const Text('Log Out of SportsBook'), style: TextButton.styleFrom(backgroundColor: const Color(0xFFE9ECFF), foregroundColor: Colors.redAccent, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)))),
                const SizedBox(height: 18),
                const Center(child: Text('SportsBook LK • v2.4.0 (Build 894)\n\n• Colombo Sports Authority Certified Partner', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600))),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _header() => Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 23)), const SizedBox(width: 9), const Expanded(child: Text('Sportsbook User\nProfile', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w700, height: 1.1))), IconButton(onPressed: () {}, icon: const Icon(Icons.edit_square, color: _muted, size: 19)), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: _muted)), Container(width: 38, height: 38, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 21))]);

  Widget _profileCard(String name, String email) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(15)), child: Column(children: [Row(children: [const CircleAvatar(radius: 31, backgroundColor: Color(0xFFD0DDFF), child: Icon(Icons.person_rounded, color: AppColors.primary, size: 36)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 3), const Text('#SB-LK-89410   •  GOLD TIER', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 7), const Text('⚡ Frequent Booker • 18 matches', style: TextStyle(color: _muted, fontSize: 11))])), const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18)]), const SizedBox(height: 12), Row(children: [_ContactPill(icon: Icons.mail_outline, text: email), const SizedBox(width: 6), const _ContactPill(icon: Icons.phone_outlined, text: '+94 77 123 4567')]) ]));

  Widget _stats() => Row(children: const [_StatTile(value: '24', label: 'Matches', icon: Icons.flag_outlined), _StatTile(value: '42h', label: 'Court\nTime', icon: Icons.timer_outlined), _StatTile(value: '4.2k', label: 'LKR\nSaved', icon: Icons.savings_outlined), _StatTile(value: '4.9', label: 'Fairplay', icon: Icons.star_rounded)]);

  Widget _credentials() => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _PanelTitle(title: 'Player Credentials', action: 'Edit →'), Row(children: [Expanded(child: _Credential(label: 'BADMINTON', value: 'Competitive', detail: "Advanced Men's Singles", badge: 'BWF 4.2')), const SizedBox(width: 8), Expanded(child: _Credential(label: 'TENNIS', value: 'Intermediate', detail: 'Social Doubles Club', badge: 'ITN 6'))]), const SizedBox(height: 10), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(9)), child: const Row(children: [Icon(Icons.medical_services_outlined, color: Colors.redAccent, size: 20), SizedBox(width: 8), Expanded(child: Text('Emergency ICE Contact\nSuneth P. (Brother)', style: TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w600))), Text('☎ Dial', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))]))]));

  Widget _preferences() => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('SPORT PRIORITY', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Row(children: [Expanded(child: _BlueChoice(label: '⚯ Badminton  Primary')), const SizedBox(width: 6), Expanded(child: _SoftChoice(label: '◉ Tennis Secondary'))]), const SizedBox(height: 13), Row(children: [Expanded(child: _MiniInfo(title: 'PREFERRED SURFACE', value: 'Indoor Parquet\nAlt: Synthetic BWF Mat')), const SizedBox(width: 7), Expanded(child: _MiniInfo(title: 'PREFERRED WINDOW', value: 'Floodlit Evenings\n06:00 PM - 09:00 PM'))]), const SizedBox(height: 10), _MiniInfo(title: 'GEAR & SIZING KIT', value: '⚯ 26 lbs Tension • G4 Towel Grip       ⌁ UK 9 / EUR 43'), const SizedBox(height: 10), Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(9)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Auto-Invite Default Squad  ♧', style: TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w700)), Text('Dimuth K., Sahan P., Naveen R.', style: TextStyle(color: _muted, fontSize: 10))])), Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primary)]))]));

  Widget _wallet(double balance) => Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('COURT CREDIT BALANCE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)), SizedBox(height: 5), Text('LKR 1,850.00', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)), Text('Valid across all registered Colombo courts', style: TextStyle(color: Colors.white70, fontSize: 10))])), FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: const StadiumBorder()), child: const Text('+  Top Up'))])), const SizedBox(height: 10), _Panel(child: Column(children: const [_PaymentRow(label: 'Commercial Bank Debit', detail: '•••• 4821 • Exp 08/27', icon: 'VISA', selected: true), SizedBox(height: 7), _PaymentRow(label: 'Sampath Bank Platinum', detail: '•••• 9012 • Exp 11/26', icon: 'MC', selected: false), SizedBox(height: 10), Row(children: [Expanded(child: _SoftChoice(label: '● Genie by Dialog       Linked')), SizedBox(width: 6), Expanded(child: _SoftChoice(label: '● LankaPay Direct'))])]))]);

  Widget _venues() => _Panel(child: Column(children: const [_VenueRow(name: 'CSA National Sports Arena', detail: 'Torrington Ave, Colombo 07', count: '12 Bookings'), _VenueRow(name: 'Liberty Courts Colombo', detail: 'Kollupitiya, Colombo 03', count: '4 Bookings'), _VenueRow(name: 'Royal College Sports Complex', detail: 'Rajakeeya Mawatha, Colombo 07', count: '2 Bookings')]));

  Widget _security() => _Panel(child: Column(children: [_SecurityRow(icon: Icons.notifications_none, title: 'Match Reminders (60m Prior)', detail: 'Push notifications and SMS'), _SecurityRow(icon: Icons.bolt_rounded, title: 'Slot Drop & Opening Alerts', detail: 'When peak hours become available'), _SecurityRow(icon: Icons.cloud_outlined, title: 'Rain & Weather Cancellations', detail: 'Instant auto-refund to wallet'), const SizedBox(height: 10), _SecurityRow(icon: Icons.fingerprint, title: 'Biometric / FaceID Login', detail: 'Apple FaceID active', badge: 'Enabled'), _SecurityRow(icon: Icons.security_outlined, title: '2-Factor Authentication', detail: 'SMS code to +94 77 •••• 4567', badge: 'Active'), const SizedBox(height: 8), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(9)), child: const Row(children: [Icon(Icons.support_agent, color: AppColors.primary), SizedBox(width: 9), Expanded(child: Text('24/7 Player Concierge & Issue\nReporting\nNet tears, lighting issues, or refund disputes', style: TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w600))), Icon(Icons.chevron_right, color: _muted)]))]));

  Widget _sectionTitle(String title, {String? action}) => Row(children: [Text(title, style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w700)), const Spacer(), if (action != null) Text(action, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))]);

  Widget _guestProfile(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFAF8FF), body: Center(child: FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen())), child: const Text('Sign In or Register'))));
}

class _Panel extends StatelessWidget { const _Panel({required this.child}); final Widget child; @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)), child: child); }
class _PanelTitle extends StatelessWidget { const _PanelTitle({required this.title, required this.action}); final String title; final String action; @override Widget build(BuildContext context) => Row(children: [Text(title, style: const TextStyle(color: _ProfileColors.ink, fontSize: 14, fontWeight: FontWeight.w700)), const Spacer(), Text(action, style: const TextStyle(color: AppColors.primary, fontSize: 11))]); }
class _ContactPill extends StatelessWidget { const _ContactPill({required this.icon, required this.text}); final IconData icon; final String text; @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(icon, color: AppColors.primary, size: 14), const SizedBox(width: 5), Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ProfileColors.muted, fontSize: 10)))]))); }
class _StatTile extends StatelessWidget { const _StatTile({required this.value, required this.label, required this.icon}); final String value; final String label; final IconData icon; @override Widget build(BuildContext context) => Expanded(child: Container(margin: const EdgeInsets.only(right: 5), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)), child: Column(children: [Icon(icon, color: AppColors.primary, size: 18), const SizedBox(height: 5), Text(value, style: const TextStyle(color: _ProfileColors.ink, fontSize: 18, fontWeight: FontWeight.w800)), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _ProfileColors.muted, fontSize: 10))]))); }
class _Credential extends StatelessWidget { const _Credential({required this.label, required this.value, required this.detail, required this.badge}); final String label; final String value; final String detail; final String badge; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _ProfileColors.softBlue, borderRadius: BorderRadius.circular(9)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(label, style: const TextStyle(color: _ProfileColors.muted, fontSize: 9))), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.all(Radius.circular(12))), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))]), const SizedBox(height: 10), Text(value, style: const TextStyle(color: _ProfileColors.ink, fontSize: 16, fontWeight: FontWeight.w700)), Text(detail, style: const TextStyle(color: _ProfileColors.muted, fontSize: 10))])); }
class _BlueChoice extends StatelessWidget { const _BlueChoice({required this.label}); final String label; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))); }
class _SoftChoice extends StatelessWidget { const _SoftChoice({required this.label}); final String label; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: _ProfileColors.softBlue, borderRadius: BorderRadius.circular(8)), child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ProfileColors.ink, fontSize: 10, fontWeight: FontWeight.w600))); }
class _MiniInfo extends StatelessWidget { const _MiniInfo({required this.title, required this.value}); final String title; final String value; @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _ProfileColors.softBlue, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _ProfileColors.muted, fontSize: 9, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(value, style: const TextStyle(color: _ProfileColors.ink, fontSize: 10, fontWeight: FontWeight.w600))])); }
class _PaymentRow extends StatelessWidget { const _PaymentRow({required this.label, required this.detail, required this.icon, required this.selected}); final String label; final String detail; final String icon; final bool selected; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _ProfileColors.softBlue, borderRadius: BorderRadius.circular(8)), child: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), color: Colors.white, child: Text(icon, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800))), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _ProfileColors.ink, fontSize: 10, fontWeight: FontWeight.w600)), Text(detail, style: const TextStyle(color: _ProfileColors.muted, fontSize: 10))])), Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? AppColors.primary : _ProfileColors.muted, size: 16)])); }
class _VenueRow extends StatelessWidget { const _VenueRow({required this.name, required this.detail, required this.count}); final String name; final String detail; final String count; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: _ProfileColors.softBlue, borderRadius: BorderRadius.circular(7)), child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 19)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: _ProfileColors.ink, fontSize: 10, fontWeight: FontWeight.w700)), Text(detail, style: const TextStyle(color: _ProfileColors.muted, fontSize: 9))])), Text(count, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700))]))); }
class _SecurityRow extends StatelessWidget { const _SecurityRow({required this.icon, required this.title, required this.detail, this.badge}); final IconData icon; final String title; final String detail; final String? badge; @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _ProfileColors.softBlue, borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(icon, color: AppColors.primary, size: 18), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _ProfileColors.ink, fontSize: 10, fontWeight: FontWeight.w600)), Text(detail, style: const TextStyle(color: _ProfileColors.muted, fontSize: 9))])), badge == null ? Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primary) : Text(badge!, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))])); }
class _ProfileColors { static const ink = Color(0xFF11182D); static const muted = Color(0xFF697083); static const softBlue = Color(0xFFF0F2FF); }
