import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';

/// Player flow: report a facility incident to the venue owner, and track the status of past reports.
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key, this.initialCategory, this.initialSeverity, this.initialDescription});

  final String? initialDescription;

  final String? initialCategory;
  final String? initialSeverity;

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  static const _categories = {
    'Court damage': Icons.sports_tennis,
    'Lighting': Icons.bolt,
    'Injury': Icons.healing,
    'Safety hazard': Icons.warning_amber_rounded,
    'Cleanliness': Icons.cleaning_services_outlined,
    'Lockers & showers': Icons.shower_outlined,
    'Other': Icons.more_horiz,
  };

  final _service = SupabaseService();
  final _description = TextEditingController();
  final _court = TextEditingController();

  List<Map<String, dynamic>> _venues = [];
  List<Map<String, dynamic>> _reports = [];
  String? _venueId;
  late String _category;
  late String _severity;
  bool _loading = true;
  bool _submitting = false;
  XFile? _photo;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _category = _categories.containsKey(widget.initialCategory) ? widget.initialCategory! : 'Court damage';
    _severity = widget.initialSeverity ?? 'Medium';
    _description.text = widget.initialDescription ?? '';
    _load();
  }

  @override
  void dispose() {
    _description.dispose();
    _court.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final venues = await _service.getVenues();
      List<Map<String, dynamic>> reports = [];
      try {
        reports = await _service.getIncidents();
      } catch (_) {
        // incidents table may not exist yet; the form still works once the migration is applied
      }
      if (!mounted) return;
      setState(() {
        _venues = venues;
        _reports = reports;
        _venueId ??= venues.isNotEmpty ? venues.first['id'] as String : null;
      });
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 80);
      if (picked != null && mounted) setState(() => _photo = picked);
    } catch (e) {
      _snack('Could not open the photo picker: $e', error: true);
    }
  }

  Future<void> _submit() async {
    if (_venueId == null) {
      _snack('Choose the venue where this happened.');
      return;
    }
    if (_description.text.trim().length < 10) {
      _snack('Please describe the issue (at least 10 characters).');
      return;
    }
    setState(() => _submitting = true);
    try {
      String? photoUrl;
      if (_photo != null) {
        final name = _photo!.name.toLowerCase();
        final ext = name.endsWith('.png') ? 'png' : 'jpeg';
        photoUrl = await _service.uploadIncidentPhoto(await _photo!.readAsBytes(), ext);
      }
      await _service.createIncident(
        photoUrl: photoUrl,
        venueId: _venueId,
        courtName: _court.text.trim().isEmpty ? null : _court.text.trim(),
        category: _category,
        severity: _severity,
        description: _description.text.trim(),
      );
      if (!mounted) return;
      _description.clear();
      _court.clear();
      _photo = null;
      _snack('Report sent to the arena manager.', ok: true);
      await _load();
    } catch (e) {
      if (mounted) _snack('Could not send report: $e', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg, {bool ok = false, bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : (error ? Colors.redAccent : null)));
  }

  Color _statusColor(String s) => switch (s) {
        'resolved' => Colors.green,
        'in_progress' => Colors.orange,
        _ => Colors.redAccent,
      };

  String _statusLabel(String s) => switch (s) {
        'resolved' => 'Resolved',
        'in_progress' => 'In progress',
        _ => 'Open',
      };

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 6),
        child: Text(text, style: const TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: ink), onPressed: () => Navigator.pop(context)),
        title: const Text('Report an Incident', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.cloud_off, size: 36, color: Colors.redAccent),
                        const SizedBox(height: 8),
                        Text('Could not load venues.\n$_loadError', textAlign: TextAlign.center, style: const TextStyle(color: muted)),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ]),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      const Text('Tell the arena manager what needs attention. Urgent hazards are shown first on their incident desk.', style: TextStyle(color: muted, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 16),
                      _label('VENUE'),
                      DropdownButtonFormField<String>(
                        initialValue: _venueId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.stadium_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        items: [for (final v in _venues) DropdownMenuItem(value: v['id'] as String, child: Text('${v['name']} • ${v['area'] ?? ''}', overflow: TextOverflow.ellipsis))],
                        onChanged: (v) => setState(() => _venueId = v),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _court,
                        decoration: InputDecoration(
                          labelText: 'Court / area (optional)',
                          hintText: 'e.g. Court 2, changing room',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.place_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _label('WHAT HAPPENED?'),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final e in _categories.entries)
                          ChoiceChip(
                            avatar: Icon(e.value, size: 16, color: _category == e.key ? Colors.white : AppColors.primary),
                            label: Text(e.key),
                            selected: _category == e.key,
                            showCheckmark: false,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(color: _category == e.key ? Colors.white : ink, fontWeight: FontWeight.w600),
                            onSelected: (_) => setState(() => _category = e.key),
                          ),
                      ]),
                      const SizedBox(height: 18),
                      _label('SEVERITY'),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Low', label: Text('Low')),
                          ButtonSegment(value: 'Medium', label: Text('Medium')),
                          ButtonSegment(value: 'High', label: Text('High / Urgent')),
                        ],
                        selected: {_severity},
                        onSelectionChanged: (s) => setState(() => _severity = s.first),
                      ),
                      const SizedBox(height: 18),
                      _label('DESCRIPTION'),
                      TextField(
                        controller: _description,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'Describe the problem, where it is and anyone affected…',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _label('PHOTO EVIDENCE (OPTIONAL)'),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _pickPhoto,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(color: const Color(0xFFF0F2FF), borderRadius: BorderRadius.circular(14)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(_photo == null ? Icons.camera_alt_outlined : Icons.check_circle, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Flexible(child: Text(_photo == null ? 'Add a photo of the issue' : _photo!.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 13))),
                            if (_photo != null) IconButton(onPressed: () => setState(() => _photo = null), icon: const Icon(Icons.close, size: 18)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Submit Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                      if (_reports.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _label('YOUR RECENT REPORTS'),
                        for (final r in _reports.take(10))
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEFF))),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text('${r['category']} • ${(r['venues'] as Map?)?['name'] ?? 'Venue'}', style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 13))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: _statusColor('${r['status']}').withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                                  child: Text(_statusLabel('${r['status']}'), style: TextStyle(color: _statusColor('${r['status']}'), fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Text('${r['description']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12)),
                              if ((r['resolution_note'] as String?)?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 6),
                                Text('Manager: ${r['resolution_note']}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ]),
                          ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
