import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/sports.dart';
import '../../core/supabase_service.dart';

/// Owner flow: add a court to a complex, or edit an existing one when [court] is given.
/// Pops with `true` when something was saved.
class AddCourtScreen extends StatefulWidget {
  const AddCourtScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    this.defaultSport = 'Badminton',
    this.defaultRate,
    this.court,
  });

  final String venueId;
  final String venueName;
  final String defaultSport;
  final double? defaultRate;
  final Map<String, dynamic>? court;

  @override
  State<AddCourtScreen> createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends State<AddCourtScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  static const _surfaces = [
    'Premium Teak Parquet Floor',
    'Synthetic Indoor Shoe Rubber',
    'Hard Court Acrylic',
    'Wooden Parquet',
    'Synthetic Turf',
    'Natural Turf',
    'Hardwood',
    'Synthetic Padel Turf',
    'Synthetic Table Tennis Mat',
    'Glassback Squash Court',
    'Synthetic',
    'Rubber',
    'Concrete',
    'Clay',
    'Grass',
    'Acrylic',
  ];
  static const _sports = kSports;

  final _service = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _rate;
  late String _surface;
  late String _sport;
  late bool _active;
  bool _saving = false;

  bool get _editing => widget.court != null;

  @override
  void initState() {
    super.initState();
    final c = widget.court;
    _name = TextEditingController(text: c?['name'] as String? ?? '');
    final rate = (c?['hourly_rate'] as num?)?.toDouble() ?? widget.defaultRate;
    _rate = TextEditingController(
      text: rate == null
          ? ''
          : rate.toStringAsFixed(rate == rate.roundToDouble() ? 0 : 2),
    );
    _surface = (c?['type'] as String?) ?? _surfaces.first;
    if (!_surfaces.contains(_surface)) _surface = _surfaces.first;
    _sport = (c?['sport'] as String?) ?? widget.defaultSport;
    if (!_sports.contains(_sport)) _sport = _sports.first;
    _active = (c?['is_active'] as bool?) ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final rate = double.parse(_rate.text.trim());
    try {
      if (_editing) {
        await _service.updateCourtDetailed(
          widget.court!['id'] as String,
          name: _name.text.trim(),
          type: _surface,
          sport: _sport,
          hourlyRate: rate,
          isActive: _active,
        );
      } else {
        await _service.addCourtDetailed(
          widget.venueId,
          name: _name.text.trim(),
          type: _surface,
          sport: _sport,
          hourlyRate: rate,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save court: $e'),
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 6),
    child: Text(
      text,
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
    onSelected: (_) => onTap(),
    selectedColor: AppColors.primary,
    labelStyle: TextStyle(
      color: selected ? Colors.white : ink,
      fontWeight: FontWeight.w600,
    ),
    showCheckmark: false,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.venueName.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _editing ? 'Edit Court' : 'Add Court',
              style: const TextStyle(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _dec(
                  'Court name (e.g. Court 3)',
                  Icons.sports_tennis_rounded,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a court name'
                    : null,
              ),
              const SizedBox(height: 18),
              _label('SPORT'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _sports)
                    _choice(s, _sport == s, () => setState(() => _sport = s)),
                ],
              ),
              const SizedBox(height: 18),
              _label('SURFACE'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _surfaces)
                    _choice(
                      s,
                      _surface == s,
                      () => setState(() => _surface = s),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _label('PRICING'),
              TextFormField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _dec('Hourly rate (LKR)', Icons.payments_outlined),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  return (n == null || n <= 0) ? 'Enter a valid rate' : null;
                },
              ),
              if (_editing) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Available for booking',
                    style: TextStyle(fontWeight: FontWeight.w700, color: ink),
                  ),
                  subtitle: const Text(
                    'Turn off while the court is closed for maintenance',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _active,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
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
                      : Text(
                          _editing ? 'Save Changes' : 'Add Court',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
