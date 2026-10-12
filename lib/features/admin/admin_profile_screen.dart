import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import 'add_court_screen.dart';
import 'register_complex_screen.dart';

/// Owner console: profile, registered complexes, and court management.
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  final SupabaseService _service = SupabaseService();
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _venues = [];
  int _venueIndex = 0;
  List<Map<String, dynamic>> _courts = [];

  Map<String, dynamic>? get _venue => _venues.isEmpty ? null : _venues[_venueIndex];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({String? selectVenueId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await _service.getProfile();
      final venues = await _service.getMyVenues();
      var index = _venueIndex;
      if (selectVenueId != null) index = venues.indexWhere((v) => v['id'] == selectVenueId);
      if (index < 0 || index >= venues.length) index = 0;
      final courts = venues.isEmpty ? <Map<String, dynamic>>[] : await _service.getVenueCourts(venues[index]['id'] as String);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _venues = venues;
        _venueIndex = index;
        _courts = courts;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? Colors.redAccent : null));
  }

  Future<void> _registerComplex() async {
    final venue = await Navigator.push<Map<String, dynamic>>(context, MaterialPageRoute(builder: (_) => const RegisterComplexScreen()));
    if (venue == null) return;
    await _loadData(selectVenueId: venue['id'] as String?);
    if (mounted) await _openCourtForm();
  }

  Future<void> _openCourtForm({Map<String, dynamic>? court}) async {
    final v = _venue;
    if (v == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCourtScreen(
          venueId: v['id'] as String,
          venueName: v['name'] as String? ?? 'Complex',
          defaultSport: v['sport'] as String? ?? 'Badminton',
          defaultRate: (v['hourly_rate'] as num?)?.toDouble(),
          court: court,
        ),
      ),
    );
    if (saved == true) {
      await _loadData();
      _snack(court == null ? 'Court added' : 'Court updated');
    }
  }

  Future<void> _confirm(String title, String body, Future<void> Function() action, {String confirmLabel = 'Delete'}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel, style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await action();
      await _loadData();
    } catch (e) {
      _snack('Error: $e', error: true);
    }
  }

  Future<void> _editComplex() async {
    final v = _venue!;
    final name = TextEditingController(text: v['name'] as String? ?? '');
    final address = TextEditingController(text: v['address'] as String? ?? '');
    final phone = TextEditingController(text: v['contact_phone'] as String? ?? '');
    final desc = TextEditingController(text: v['description'] as String? ?? '');
    final rate = TextEditingController(text: '${(v['hourly_rate'] as num?)?.toStringAsFixed(0) ?? ''}');
    final tagline = TextEditingController(text: v['tagline'] as String? ?? '');
    final website = TextEditingController(text: v['website'] as String? ?? '');
    final email = TextEditingController(text: v['contact_email'] as String? ?? '');
    final rules = TextEditingController(text: v['house_rules'] as String? ?? '');
    final cancel = TextEditingController(text: v['cancellation_policy'] as String? ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Complex', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Complex name')),
            TextField(controller: address, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact phone')),
            TextField(controller: rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Starting hourly rate (LKR)')),
            TextField(controller: tagline, decoration: const InputDecoration(labelText: 'Tagline')),
            TextField(controller: desc, maxLines: 4, decoration: const InputDecoration(labelText: 'About / Bio')),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Contact email')),
            TextField(controller: website, decoration: const InputDecoration(labelText: 'Website')),
            TextField(controller: rules, maxLines: 3, decoration: const InputDecoration(labelText: 'House rules')),
            TextField(controller: cancel, maxLines: 2, decoration: const InputDecoration(labelText: 'Cancellation policy')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final parsedRate = double.tryParse(rate.text.trim());
              if (name.text.trim().isEmpty || parsedRate == null || parsedRate <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter a name and a valid rate')));
                return;
              }
              try {
                await _service.updateAdminVenue(v['id'] as String, {
                  'name': name.text.trim(),
                  'address': address.text.trim(),
                  'contact_phone': phone.text.trim(),
                  'description': desc.text.trim(),
                  'tagline': tagline.text.trim(),
                  'website': website.text.trim(),
                  'contact_email': email.text.trim(),
                  'house_rules': rules.text.trim(),
                  'cancellation_policy': cancel.text.trim(),
                  'hourly_rate': parsedRate,
                });
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    for (final c in [name, address, phone, desc, rate, tagline, website, email, rules, cancel]) {
      c.dispose();
    }
    if (saved == true) {
      await _loadData();
      _snack('Complex updated');
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    _topBar(),
                    const SizedBox(height: 24),
                    _profileHeader(),
                    const SizedBox(height: 24),
                    if (_error != null) _errorCard() else if (_venue == null) _emptyState() else ..._venueSections(),
                    const SizedBox(height: 32),
                    _logoutButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _topBar() => Row(children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ink)),
        const SizedBox(width: 8),
        const Expanded(child: Text('Owner Profile & Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink))),
      ]);

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: child,
      );

  Widget _profileHeader() {
    final name = (_profile?['full_name'] as String?) ?? 'Owner';
    final email = (_profile?['email'] as String?) ?? Supabase.instance.client.auth.currentUser?.email ?? '';
    final initials = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
    final role = ((_profile?['role'] as String?) ?? 'owner').toUpperCase();
    return _card(
      child: Row(children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(initials.isEmpty ? '?' : initials, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(4)),
                child: Text(role, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: muted, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _errorCard() => _card(
        child: Column(children: [
          const Icon(Icons.cloud_off, color: Colors.redAccent, size: 32),
          const SizedBox(height: 8),
          Text('Could not load your complexes.\n$_error', textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          FilledButton(onPressed: _loadData, child: const Text('Retry')),
        ]),
      );

  Widget _emptyState() => _card(
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: softBlue, shape: BoxShape.circle),
            child: const Icon(Icons.add_business_outlined, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Register your court complex', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Add your venue details and courts so players can find and book them.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _registerComplex,
            icon: const Icon(Icons.add),
            label: const Text('Register Complex'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          ),
        ]),
      );

  List<Widget> _venueSections() {
    final v = _venue!;
    return [
      if (_venues.length > 1) ...[
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _venues.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(
              label: Text(_venues[i]['name'] as String? ?? 'Complex'),
              selected: i == _venueIndex,
              selectedColor: AppColors.primary,
              showCheckmark: false,
              labelStyle: TextStyle(color: i == _venueIndex ? Colors.white : ink, fontWeight: FontWeight.w600),
              onSelected: (_) {
                _venueIndex = i;
                _loadData();
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('COMPLEX INFORMATION', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            InkWell(
              onTap: _editComplex,
              child: const Row(children: [
                Icon(Icons.edit, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          if ((v['image_url'] as String?)?.isNotEmpty ?? false) ...[
            ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network('${v['image_url']}', height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
            const SizedBox(height: 14),
          ],
          _detailRow(Icons.stadium_outlined, 'Name', v['name'] as String? ?? '-'),
          if ((v['tagline'] as String?)?.isNotEmpty ?? false) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.short_text_rounded, 'Tagline', v['tagline'] as String),
          ],
          if ((v['description'] as String?)?.isNotEmpty ?? false) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.info_outline, 'About / Bio', v['description'] as String),
          ],
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.location_on_outlined, 'Location', '${v['address'] ?? ''}'.trim().isEmpty ? '${v['area'] ?? '-'}' : '${v['address']}'),
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.sports_tennis, 'Sport & type', '${v['sport'] ?? '-'} • ${v['environment'] ?? '-'}'),
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.schedule, 'Hours', '${v['opening_time'] ?? '06:00'} - ${v['closing_time'] ?? '22:00'}'),
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.payments_outlined, 'From', 'LKR ${(v['hourly_rate'] as num?)?.toStringAsFixed(0) ?? '-'} / hr'),
          if ((v['contact_phone'] as String?)?.isNotEmpty ?? false) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.phone_outlined, 'Contact', v['contact_phone'] as String),
          ],
          if ((v['contact_email'] as String?)?.isNotEmpty ?? false) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.mail_outline, 'Email', v['contact_email'] as String),
          ],
          if ((v['website'] as String?)?.isNotEmpty ?? false) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.language, 'Website', v['website'] as String),
          ],
          if (v['established_year'] != null) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.history, 'Established', '${v['established_year']}'),
          ],
          if ((v['house_rules'] as String?)?.isNotEmpty ?? false) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.rule_rounded, 'House rules', v['house_rules'] as String),
          ],
          if ((v['cancellation_policy'] as String?)?.isNotEmpty ?? false) ...[
            const Divider(height: 24, color: Color(0xFFF1F4FF)),
            _detailRow(Icons.event_busy_outlined, 'Cancellation policy', v['cancellation_policy'] as String),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _confirm(
                'Remove complex?',
                'This permanently removes ${v['name']} along with its courts. Existing bookings stay on record.',
                () => _service.deleteVenue(v['id'] as String),
                confirmLabel: 'Remove',
              ),
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              label: const Text('Remove complex', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('COURTS (${_courts.length})', style: const TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            InkWell(
              onTap: () => _openCourtForm(),
              child: const Row(children: [
                Icon(Icons.add, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text('Add Court', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          if (_courts.isEmpty)
            const Text('No courts added yet. Tap "Add Court" to create the first one.', style: TextStyle(color: muted, fontSize: 13))
          else
            for (final court in _courts) _courtTile(court),
        ]),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _registerComplex,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Register another complex'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    ];
  }

  Widget _courtTile(Map<String, dynamic> court) {
    final active = (court['is_active'] as bool?) ?? true;
    final rate = (court['hourly_rate'] as num?)?.toDouble();
    final sub = [court['sport'], court['type'], if (rate != null) 'LKR ${rate.toStringAsFixed(0)}/hr'].where((e) => e != null && '$e'.isNotEmpty).join(' • ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.sports_tennis, color: active ? AppColors.primary : muted, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(court['name'] as String? ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800))),
                if (!active) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFFE9E9), borderRadius: BorderRadius.circular(4)),
                    child: const Text('CLOSED', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(color: muted, fontSize: 11)),
            ]),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18), onPressed: () => _openCourtForm(court: court)),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            onPressed: () => _confirm('Delete court?', 'Delete ${court['name']}?', () => _service.deleteCourt(court['id'] as String)),
          ),
        ]),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) => Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: muted)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
          ]),
        ),
      ]);

  Widget _logoutButton() => SizedBox(
        height: 56,
        child: TextButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('Log Out of Owner Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
            backgroundColor: const Color(0xFFFFF0F0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
}
