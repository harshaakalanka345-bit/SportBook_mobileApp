import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/actions.dart';
import '../../core/app_theme.dart';
import '../../core/auth_errors.dart';
import '../../core/card_form.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import '../notifications/notifications_screen.dart';
import '../support/help_support_screen.dart';
import 'booking_history_screen.dart';
import 'edit_profile_screen.dart';
import 'wallet_screen.dart';

/// Player profile: details (edit), payment & credits (saved cards CRUD), top venues, preferences & security.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF737A8E);
  static const softBlue = Color(0xFFF1F4FF);

  final _service = SupabaseService();
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _profile == null;
      _error = null;
    });
    try {
      final profile = await _service.getProfile();
      List<Map<String, dynamic>> cards = [];
      List<Map<String, dynamic>> bookings = [];
      try {
        cards = await _service.getSavedCards();
      } catch (_) {}
      try {
        bookings = await _service.getUserBookings();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _cards = cards;
        _bookings = bookings;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  User? get _user => Supabase.instance.client.auth.currentUser;
  String get _name => (_profile?['full_name'] as String?) ?? _user?.email ?? 'SportsBook Member';
  String get _email => (_profile?['email'] as String?) ?? _user?.email ?? '';
  String get _phone => (_profile?['phone'] as String?) ?? '';
  double get _balance => (_profile?['wallet_balance'] as num?)?.toDouble() ?? 0;
  Map<String, dynamic> get _prefs => Map<String, dynamic>.from((_profile?['preferences'] as Map?) ?? const {});

  List<Map<String, dynamic>> get _active => _bookings.where((b) => b['status'] != 'Cancelled').toList();

  List<({String id, String name, String address, int count, String last})> get _topVenues {
    final map = <String, ({String name, String address, int count, String last})>{};
    for (final b in _active) {
      final id = '${b['venue_id']}';
      final v = (b['venues'] as Map?) ?? const {};
      final prev = map[id];
      final date = '${b['date_schedule']}';
      map[id] = (
        name: '${v['name'] ?? 'Venue'}',
        address: '${v['address'] ?? v['area'] ?? ''}',
        count: (prev?.count ?? 0) + 1,
        last: prev == null || date.compareTo(prev.last) > 0 ? date : prev.last,
      );
    }
    final list = map.entries.map((e) => (id: e.key, name: e.value.name, address: e.value.address, count: e.value.count, last: e.value.last)).toList();
    list.sort((a, b) => b.count.compareTo(a.count));
    return list.take(3).toList();
  }

  Future<void> _edit() async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)));
    if (saved == true) {
      await _load();
      toast('Profile updated');
    }
  }

  Future<void> _wallet() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
    _load();
  }

  Future<void> _addCard() async {
    final card = await showAddCardSheet(context);
    if (card == null) return;
    try {
      await _service.addSavedCard(brand: card.brand, last4: card.last4, holder: card.holder, expiry: card.expiry);
      await _load();
      toast('${card.brand} •••• ${card.last4} saved');
    } catch (e) {
      toast('Could not save card: $e');
    }
  }

  Future<void> _makeDefault(Map<String, dynamic> c) async {
    if (c['is_default'] == true) return;
    try {
      await _service.setDefaultCard('${c['id']}');
      await _load();
      toast('${c['brand']} •••• ${c['last4']} is now your default payment method');
    } catch (e) {
      toast('Could not change default card: $e');
    }
  }

  Future<void> _deleteCard(Map<String, dynamic> c) async {
    final ok = await _confirm('Remove card?', 'Remove ${c['brand']} •••• ${c['last4']} from your account?', 'Remove');
    if (ok != true) return;
    try {
      await _service.deleteSavedCard('${c['id']}');
      await _load();
    } catch (e) {
      toast('Could not remove card: $e');
    }
  }

  Future<bool?> _confirm(String title, String body, String action) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action, style: const TextStyle(color: Colors.redAccent))),
          ],
        ),
      );

  Future<void> _setPref(String key, bool value) async {
    final old = _prefs;
    setState(() => _profile = {...?_profile, 'preferences': {...old, key: value}});
    try {
      await _service.updatePreferences({key: value});
    } catch (e) {
      if (mounted) setState(() => _profile = {...?_profile, 'preferences': old});
      toast('Could not save setting: $e');
    }
  }

  Future<void> _changePassword() async {
    final pass = TextEditingController();
    final confirm = TextEditingController();
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Form(
          key: key,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'New password'), validator: (v) => (v ?? '').length < 8 ? 'At least 8 characters' : null),
            TextFormField(controller: confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password'), validator: (v) => v != pass.text ? 'Passwords do not match' : null),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () { if (key.currentState!.validate()) Navigator.pop(ctx, true); }, child: const Text('Update')),
        ],
      ),
    );
    final value = pass.text;
    pass.dispose();
    confirm.dispose();
    if (ok != true) return;
    try {
      await _service.changePassword(value);
      toast('Password updated');
    } on AuthException catch (e) {
      toast(authErrorMessage(e));
    } catch (e) {
      toast('Could not change password: $e');
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
  }

  Future<void> _deleteAccount() async {
    final ok = await _confirm('Delete account?', 'This permanently deletes your account, saved cards and preferences. This cannot be undone.', 'Delete forever');
    if (ok != true) return;
    try {
      await _service.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
    } catch (e) {
      toast('Could not delete account: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    _topBar(),
                    const SizedBox(height: 16),
                    if (_error != null)
                      _card(child: Column(children: [Text('Could not load your profile.\n$_error', textAlign: TextAlign.center, style: const TextStyle(color: muted)), TextButton(onPressed: _load, child: const Text('Retry'))]))
                    else ...[
                      _header(),
                      const SizedBox(height: 16),
                      _stats(),
                      const SizedBox(height: 24),
                      _playerDetails(),
                      const SizedBox(height: 24),
                      _payments(),
                      const SizedBox(height: 24),
                      _topVenuesSection(),
                      const SizedBox(height: 24),
                      _preferences(),
                      const SizedBox(height: 24),
                      _dangerZone(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  // ---------------- sections ----------------

  Widget _topBar() {
    return Row(children: [
      if (Navigator.of(context).canPop())
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: ink))
      else
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
        ),
      const Expanded(child: Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink))),
      IconButton(onPressed: () => shareText('Join me on SportsBook - book courts and find playing partners in Colombo. - $_name'), icon: const Icon(Icons.share_outlined, color: Color(0xFF4A5568))),
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF4A5568))),
    ]);
  }

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(18)}) => Container(
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x0A001844), blurRadius: 16, offset: Offset(0, 6))]),
        child: child,
      );

  Widget _title(String text, IconData icon, {Widget? action}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink))),
          if (action != null) action,
        ]),
      );

  Widget _header() {
    final initials = _name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
    final id = (_profile?['id'] as String?)?.substring(0, 8).toUpperCase() ?? '--------';
    return _card(
      child: Row(children: [
        CircleAvatar(radius: 32, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Text(initials.isEmpty ? '?' : initials, style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800))),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 2),
            Text(_email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568))),
            const SizedBox(height: 2),
            Text('ID: SB-$id', style: const TextStyle(fontSize: 11, color: muted)),
          ]),
        ),
        IconButton.filledTonal(onPressed: _edit, icon: const Icon(Icons.edit_outlined, size: 18), tooltip: 'Edit profile'),
      ]),
    );
  }

  Widget _stats() {
    final spent = _active.fold<double>(0, (s, b) => s + ((b['total_paid'] as num?)?.toDouble() ?? 0));
    final venues = _active.map((b) => b['venue_id']).toSet().length;
    Widget cell(String value, String label) => Expanded(
          child: Column(children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
          ]),
        );
    return _card(child: Row(children: [cell('${_active.length}', 'Bookings'), cell('$venues', 'Venues'), cell('LKR ${spent.toStringAsFixed(0)}', 'Spent')]));
  }

  Widget _kv(IconData icon, String label, String value, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 11, color: muted)),
              Text(value.isEmpty ? 'Not set' : value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: value.isEmpty ? muted : ink)),
            ]),
          ),
          if (trailing != null) trailing,
        ]),
      );

  Widget _playerDetails() {
    final p = _prefs;
    final sports = ((_profile?['sports'] as List?) ?? const []).join(', ');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Player Details', Icons.badge_outlined, action: TextButton(onPressed: _edit, child: const Text('Edit'))),
      _card(
        child: Column(children: [
          _kv(Icons.phone_outlined, 'Mobile', _phone),
          _kv(Icons.sports_tennis_rounded, 'My sports', sports),
          _kv(Icons.leaderboard_outlined, 'Skill level', '${p['skill'] ?? ''}'),
          _kv(Icons.grid_view_rounded, 'Preferred surface', '${p['surface'] ?? ''}'),
          _kv(Icons.schedule_rounded, 'Preferred time', '${p['window'] ?? ''}'),
          _kv(
            Icons.contact_emergency_outlined,
            'Emergency contact',
            [p['ice_name'], p['ice_phone']].where((e) => e != null && '$e'.isNotEmpty).join(' • '),
            trailing: ('${p['ice_phone'] ?? ''}').isEmpty ? null : TextButton(onPressed: () => callNumber('${p['ice_phone']}'), child: const Text('Dial')),
          ),
        ]),
      ),
    ]);
  }

  Widget _payments() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Payment & Credits', Icons.account_balance_wallet_outlined, action: TextButton.icon(onPressed: _addCard, icon: const Icon(Icons.add_circle_outline_rounded, size: 16), label: const Text('Add Card'))),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))]),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('COURT CREDIT BALANCE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('LKR ', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(_balance.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.0)),
              ]),
            ]),
          ),
          FilledButton.icon(
            onPressed: _wallet,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Top Up'),
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      if (_cards.isEmpty)
        _card(child: const Text('No saved cards yet. Tap "Add Card" to save one for faster checkout.', style: TextStyle(color: muted, fontSize: 13)))
      else
        for (final c in _cards) _cardTile(c),
    ]);
  }

  Widget _cardTile(Map<String, dynamic> c) {
    final isDefault = c['is_default'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDefault ? const Color(0xFFF8F9FD) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? AppColors.primary.withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: () => _makeDefault(c),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
          child: Text('${c['brand']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ink)),
        ),
        title: Row(children: [
          Text('•••• ${c['last4']}', style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
          if (isDefault) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(6)), child: const Text('Default', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700))),
          ],
        ]),
        subtitle: Text('${c['holder_name'] ?? ''} • Exp ${c['expiry'] ?? ''}', style: const TextStyle(fontSize: 11)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isDefault ? Icons.check_circle : Icons.radio_button_unchecked, color: isDefault ? AppColors.primary : muted, size: 20),
          IconButton(onPressed: () => _deleteCard(c), icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), tooltip: 'Remove card'),
        ]),
      ),
    );
  }

  Widget _topVenuesSection() {
    final top = _topVenues;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(
        'Top Booked Venues',
        Icons.calendar_month_outlined,
        action: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen())),
          child: Text('History (${_bookings.length}) →'),
        ),
      ),
      if (top.isEmpty)
        _card(child: const Text('Your most-booked venues will show up here once you make a booking.', style: TextStyle(color: muted, fontSize: 13)))
      else
        _card(
          child: Column(children: [
            for (final v in top)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFDCE7FF), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.stadium_outlined, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(v.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
                      Text(v.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: muted)),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${v.count} ${v.count == 1 ? 'Booking' : 'Bookings'}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('Last: ${v.last}', style: const TextStyle(fontSize: 10, color: muted)),
                  ]),
                ]),
              ),
          ]),
        ),
    ]);
  }

  Widget _toggle(IconData icon, String title, String subtitle, String key, {bool defaultValue = true}) {
    final value = (_prefs[key] as bool?) ?? defaultValue;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 18)),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: muted)),
      value: value,
      activeTrackColor: AppColors.primary,
      onChanged: (v) => _setPref(key, v),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {String? badge, Color? color}) => ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle), child: Icon(icon, color: color ?? AppColors.primary, size: 18)),
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color ?? ink)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: muted)),
        trailing: badge != null
            ? Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE5EAFF), borderRadius: BorderRadius.circular(8)), child: Text(badge, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)))
            : const Icon(Icons.chevron_right_rounded, color: muted),
      );

  Widget _preferences() {
    final verified = _user?.emailConfirmedAt != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Preferences & Security', Icons.settings_outlined),
      _card(
        child: Column(children: [
          _toggle(Icons.notifications_active_outlined, 'Match Reminders', 'Remind me before my booked slot', 'notif_reminders'),
          _toggle(Icons.flash_on_outlined, 'Slot Drop & Opening Alerts', 'When peak hours become available', 'notif_slots'),
          _toggle(Icons.wb_cloudy_outlined, 'Rain & Weather Cancellations', 'Auto-refund to wallet', 'notif_weather'),
          const Divider(height: 24),
          _actionTile(Icons.lock_outline_rounded, 'Change Password', 'Update your sign-in password', _changePassword),
          _actionTile(Icons.verified_user_outlined, 'Email Verification', _email, () => toast(verified ? 'Your email is verified' : 'Check your inbox for the verification link'), badge: verified ? 'Verified' : 'Pending'),
          _actionTile(Icons.support_agent_rounded, '24/7 Player Concierge & Issue Reporting', 'Report faults, refunds or get help', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
        ]),
      ),
    ]);
  }

  Widget _dangerZone() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 54,
        child: TextButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('Log Out of SportsBook', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent, backgroundColor: const Color(0xFFFFF0F0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ),
      ),
      const SizedBox(height: 8),
      TextButton(onPressed: _deleteAccount, child: const Text('Delete my account', style: TextStyle(color: muted, fontSize: 12))),
      const SizedBox(height: 8),
      const Text('SportsBook LK • V2.4.0', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}
