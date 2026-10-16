import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/sports.dart';
import '../../core/supabase_service.dart';

/// Edit the signed-in player's profile (name, phone, play style, emergency contact). Pops `true` when saved.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final Map<String, dynamic>? profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const sports = kSports;
  static const skills = ['Beginner', 'Intermediate', 'Advanced', 'Competitive'];
  static const surfaces = [
    'Indoor Parquet',
    'Synthetic',
    'Clay',
    'Hard Court',
    'No preference',
  ];
  static const windows = [
    'Early Mornings',
    'Daytime',
    'Floodlit Evenings',
    'Weekends',
    'No preference',
  ];

  final _service = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _iceName;
  late final TextEditingController _icePhone;
  late Set<String> _mySports;
  late String _skill;
  late String _surface;
  late String _window;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile ?? const {};
    final prefs = Map<String, dynamic>.from(
      (p['preferences'] as Map?) ?? const {},
    );
    _name = TextEditingController(text: p['full_name'] as String? ?? '');
    _phone = TextEditingController(text: p['phone'] as String? ?? '');
    _iceName = TextEditingController(text: prefs['ice_name'] as String? ?? '');
    _icePhone = TextEditingController(
      text: prefs['ice_phone'] as String? ?? '',
    );
    _mySports = {
      ...((p['sports'] as List?)?.map((e) => '$e') ?? const <String>[]),
    };
    _skill = skills.contains(prefs['skill'])
        ? prefs['skill'] as String
        : skills[1];
    _surface = surfaces.contains(prefs['surface'])
        ? prefs['surface'] as String
        : surfaces.last;
    _window = windows.contains(prefs['window'])
        ? prefs['window'] as String
        : windows.last;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _iceName, _icePhone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.updateProfile({
        'full_name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'sports': _mySports.toList(),
      });
      await _service.updatePreferences({
        'skill': _skill,
        'surface': _surface,
        'window': _window,
        'ice_name': _iceName.text.trim(),
        'ice_phone': _icePhone.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save profile: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(
      t,
      style: const TextStyle(
        color: muted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _choice(String label, bool selected, VoidCallback onTap) => ChoiceChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    selectedColor: AppColors.primary,
    labelStyle: TextStyle(
      color: selected ? Colors.white : ink,
      fontWeight: FontWeight.w600,
    ),
    onSelected: (_) => onTap(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Full name', Icons.person_outline),
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: _dec('Mobile number', Icons.phone_outlined),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ||
                      RegExp(r'^\+?[0-9 ]{9,15}$').hasMatch(v!.trim())
                  ? null
                  : 'Enter a valid number',
            ),
            _label('MY SPORTS'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in sports)
                  FilterChip(
                    label: Text(s),
                    selected: _mySports.contains(s),
                    selectedColor: const Color(0xFFDCE7FF),
                    checkmarkColor: AppColors.primary,
                    onSelected: (v) => setState(
                      () => v ? _mySports.add(s) : _mySports.remove(s),
                    ),
                  ),
              ],
            ),
            _label('SKILL LEVEL'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in skills)
                  _choice(s, _skill == s, () => setState(() => _skill = s)),
              ],
            ),
            _label('PREFERRED SURFACE'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in surfaces)
                  _choice(s, _surface == s, () => setState(() => _surface = s)),
              ],
            ),
            _label('PREFERRED TIME'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in windows)
                  _choice(s, _window == s, () => setState(() => _window = s)),
              ],
            ),
            _label('EMERGENCY CONTACT'),
            TextFormField(
              controller: _iceName,
              textCapitalization: TextCapitalization.words,
              decoration: _dec(
                'Contact name',
                Icons.contact_emergency_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _icePhone,
              keyboardType: TextInputType.phone,
              decoration: _dec('Contact phone', Icons.phone_in_talk_outlined),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ||
                      RegExp(r'^\+?[0-9 ]{9,15}$').hasMatch(v!.trim())
                  ? null
                  : 'Enter a valid number',
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
