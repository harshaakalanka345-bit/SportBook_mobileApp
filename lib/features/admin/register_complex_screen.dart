import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_theme.dart';
import '../../core/sports.dart';

import 'dart:typed_data';

import '../../core/supabase_service.dart';

/// Owner flow: register a new sports complex (venue). Pops with the created venue map on success.
class RegisterComplexScreen extends StatefulWidget {
  const RegisterComplexScreen({super.key});

  @override
  State<RegisterComplexScreen> createState() => _RegisterComplexScreenState();
}

class _RegisterComplexScreenState extends State<RegisterComplexScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  static const _sports = kSports;
  static const _allAmenities = [
    'Parking',
    'Changing Rooms',
    'Showers',
    'Floodlights',
    'Drinking Water',
    'Pro Shop',
    'Racket Rental',
    'Cafeteria',
    'Air Conditioned',
    'Lockers',
  ];

  final _service = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _area = TextEditingController(text: 'Colombo 07');
  final _address = TextEditingController();
  final _rate = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  final _tagline = TextEditingController();
  final _website = TextEditingController();
  final _email = TextEditingController();
  final _year = TextEditingController();
  final _parking = TextEditingController();
  final _rules = TextEditingController();
  final _cancellation = TextEditingController(
    text: 'Free cancellation up to 2 hours before the slot starts. No refund for late cancellations or no-shows.',
  );
  XFile? _cover;

  String _sport = 'Badminton';
  String _environment = 'Indoor';
  TimeOfDay _opens = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _closes = const TimeOfDay(hour: 22, minute: 0);
  final Set<String> _amenities = {
    'Parking',
    'Changing Rooms',
    'Drinking Water',
  };
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _area,
      _address,
      _rate,
      _phone,
      _description,
      _tagline,
      _website,
      _email,
      _year,
      _parking,
      _rules,
      _cancellation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool opening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: opening ? _opens : _closes,
    );
    if (picked == null) return;
    setState(() => opening ? _opens = picked : _closes = picked);
  }

  Future<void> _pickCover() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 82,
      );
      if (picked != null && mounted) setState(() => _cover = picked);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the photo picker: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_closes.hour * 60 + _closes.minute <=
        _opens.hour * 60 + _opens.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Closing time must be after opening time.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      String? imageUrl;
      if (_cover != null) {
        final n = _cover!.name.toLowerCase();
        imageUrl = await _service.uploadVenueImage(
          await _cover!.readAsBytes(),
          n.endsWith('.png') ? 'png' : 'jpeg',
        );
      }
      final venue = await _service.registerVenue({
        'image_url': ?imageUrl,
        'tagline': _tagline.text.trim(),
        'website': _website.text.trim(),
        'contact_email': _email.text.trim(),
        if (_year.text.trim().isNotEmpty)
          'established_year': int.parse(_year.text.trim()),
        if (_parking.text.trim().isNotEmpty)
          'parking_slots': int.parse(_parking.text.trim()),
        'house_rules': _rules.text.trim(),
        'cancellation_policy': _cancellation.text.trim(),
        'name': _name.text.trim(),
        'sport': _sport,
        'environment': _environment,
        'area': _area.text.trim(),
        'address': _address.text.trim(),
        'hourly_rate': double.parse(_rate.text.trim()),
        'contact_phone': _phone.text.trim(),
        'description': _description.text.trim(),
        'opening_time': _fmt(_opens),
        'closing_time': _fmt(_closes),
        'amenities': _amenities.toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${venue['name']} registered. Now add its courts.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, venue);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not register complex: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
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

  Widget _timeTile(String label, TimeOfDay value, bool opening) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _pickTime(opening),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: muted, fontSize: 10)),
                Text(
                  value.format(context),
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

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
        title: const Text(
          'Register Court Complex',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const Text(
                'List your sports complex so players can discover and book it. You can add courts right after.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              _label('COMPLEX DETAILS'),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _dec(
                  'Complex name',
                  hint: 'e.g. CSA National Arena',
                  icon: Icons.stadium_outlined,
                ),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Enter the complex name'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _tagline,
                maxLength: 80,
                decoration: _dec(
                  'Tagline',
                  hint: 'e.g. Colombo\'s premier floodlit badminton arena',
                  icon: Icons.short_text_rounded,
                ),
              ),
              TextFormField(
                controller: _description,
                maxLines: 6,
                maxLength: 800,
                decoration: _dec(
                  'About / Bio',
                  hint: 'Tell players about your complex: history, surfaces, coaching, facilities, what makes it special',
                  icon: Icons.info_outline,
                ),
                validator: (v) => (v == null || v.trim().length < 30)
                    ? 'Write at least 30 characters about your complex'
                    : null,
              ),
              const SizedBox(height: 6),
              _label('COVER PHOTO'),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickCover,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _cover == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.primary,
                              size: 30,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Add a cover photo',
                              style: TextStyle(
                                color: ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            FutureBuilder<List<int>>(
                              future: _cover!.readAsBytes(),
                              builder: (_, s) => s.hasData
                                  ? Image.memory(
                                      Uint8List.fromList(s.data!),
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox(),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: IconButton.filled(
                                onPressed: () => setState(() => _cover = null),
                                icon: const Icon(Icons.close, size: 16),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 18),
              _label('MAIN SPORT'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _sports)
                    _choice(s, _sport == s, () => setState(() => _sport = s)),
                ],
              ),
              const SizedBox(height: 18),
              _label('ENVIRONMENT'),
              Row(
                children: [
                  _choice(
                    'Indoor',
                    _environment == 'Indoor',
                    () => setState(() => _environment = 'Indoor'),
                  ),
                  const SizedBox(width: 8),
                  _choice(
                    'Outdoor',
                    _environment == 'Outdoor',
                    () => setState(() => _environment = 'Outdoor'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _label('LOCATION'),
              TextFormField(
                controller: _area,
                decoration: _dec(
                  'Area',
                  hint: 'e.g. Colombo 07',
                  icon: Icons.map_outlined,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter the area' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _address,
                decoration: _dec(
                  'Street address',
                  hint: 'e.g. Reid Avenue, Colombo 07',
                  icon: Icons.location_on_outlined,
                ),
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Enter the street address'
                    : null,
              ),
              const SizedBox(height: 18),
              _label('PRICING & CONTACT'),
              TextFormField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _dec(
                  'Starting hourly rate (LKR)',
                  icon: Icons.payments_outlined,
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  return (n == null || n <= 0) ? 'Enter a valid rate' : null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: _dec(
                  'Contact phone',
                  hint: '+94 77 123 4567',
                  icon: Icons.phone_outlined,
                ),
                validator: (v) =>
                    RegExp(r'^\+?[0-9 ]{9,15}$').hasMatch((v ?? '').trim())
                    ? null
                    : 'Enter a valid phone number',
              ),
              const SizedBox(height: 18),
              _label('OPENING HOURS'),
              Row(
                children: [
                  _timeTile('Opens', _opens, true),
                  const SizedBox(width: 12),
                  _timeTile('Closes', _closes, false),
                ],
              ),
              const SizedBox(height: 18),
              _label('MORE ABOUT YOUR COMPLEX'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('Contact email', icon: Icons.mail_outline),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ||
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v!.trim())
                    ? null
                    : 'Enter a valid email',
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _website,
                keyboardType: TextInputType.url,
                decoration: _dec(
                  'Website or social page (optional)',
                  icon: Icons.language,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _year,
                      keyboardType: TextInputType.number,
                      decoration: _dec(
                        'Established (year)',
                        icon: Icons.history,
                      ),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return null;
                        final y = int.tryParse(v!.trim());
                        return (y == null ||
                                y < 1900 ||
                                y > DateTime.now().year)
                            ? 'Invalid year'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _parking,
                      keyboardType: TextInputType.number,
                      decoration: _dec(
                        'Parking spaces',
                        icon: Icons.local_parking,
                      ),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ||
                              int.tryParse(v!.trim()) != null
                          ? null
                          : 'Number only',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _rules,
                maxLines: 4,
                decoration: _dec(
                  'House rules',
                  hint: 'Non-marking shoes, no food on court, arrive 10 minutes early…',
                  icon: Icons.rule_rounded,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cancellation,
                maxLines: 3,
                decoration: _dec(
                  'Cancellation policy',
                  icon: Icons.event_busy_outlined,
                ),
              ),
              const SizedBox(height: 18),
              _label('AMENITIES'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in _allAmenities)
                    FilterChip(
                      label: Text(a),
                      selected: _amenities.contains(a),
                      onSelected: (v) => setState(
                        () => v ? _amenities.add(a) : _amenities.remove(a),
                      ),
                      selectedColor: const Color(0xFFDCE7FF),
                      checkmarkColor: AppColors.primary,
                    ),
                ],
              ),
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
                      : const Text(
                          'Register Complex',
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
      ),
    );
  }
}
