import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import 'admin_profile_screen.dart';

/// Owner incident desk: live incidents reported at the owner's venues, with status updates.
class AdminIncidentsScreen extends StatefulWidget {
  const AdminIncidentsScreen({super.key});

  @override
  State<AdminIncidentsScreen> createState() => _AdminIncidentsScreenState();
}

class _AdminIncidentsScreenState extends State<AdminIncidentsScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  final _service = SupabaseService();
  List<Map<String, dynamic>> _incidents = [];
  bool _loading = true;
  String? _error;
  String _filter = 'open'; // open | in_progress | resolved | all

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.getIncidents();
      if (mounted) setState(() => _incidents = rows);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _visible {
    final items = _filter == 'all' ? [..._incidents] : _incidents.where((i) => i['status'] == _filter).toList();
    int priority(Map<String, dynamic> incident) => switch ('${incident['severity']}') {
          'High' => 0,
          'Medium' => 1,
          _ => 2,
        };
    items.sort((a, b) {
      final severityOrder = priority(a).compareTo(priority(b));
      if (severityOrder != 0) return severityOrder;
      return (DateTime.tryParse('${b['created_at']}') ?? DateTime(0))
          .compareTo(DateTime.tryParse('${a['created_at']}') ?? DateTime(0));
    });
    return items;
  }

  int _count(String status) => _incidents.where((i) => i['status'] == status).length;

  Color _severityColor(String s) => switch (s) {
        'High' => Colors.redAccent,
        'Medium' => Colors.orange,
        _ => Colors.green,
      };

  String _ago(String? iso) {
    final d = DateTime.tryParse(iso ?? '')?.toLocal();
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _update(Map<String, dynamic> incident, String status) async {
    String? note;
    if (status == 'resolved' || status == 'in_progress') {
      final controller = TextEditingController(text: incident['resolution_note'] as String? ?? '');
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(status == 'resolved' ? 'Mark as resolved' : 'Mark as in progress', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(labelText: 'Note for the reporter (optional)')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
          ],
        ),
      );
      note = controller.text.trim();
      controller.dispose();
      if (ok != true) return;
    }
    try {
      await _service.updateIncident(incident['id'] as String, status: status, note: (note == null || note.isEmpty) ? null : note);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update incident: $e'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              _appBar(),
              const SizedBox(height: 20),
              const Text('Facility Incident Desk', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Reports from players at your complexes', style: TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _tab('open', 'Open (${_count('open')})'),
                  const SizedBox(width: 8),
                  _tab('in_progress', 'In progress (${_count('in_progress')})'),
                  const SizedBox(width: 8),
                  _tab('resolved', 'Resolved (${_count('resolved')})'),
                  const SizedBox(width: 8),
                  _tab('all', 'All (${_incidents.length})'),
                ]),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(padding: EdgeInsets.only(top: 60), child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                _message(Icons.cloud_off, 'Could not load incidents', _error!, action: FilledButton(onPressed: _load, child: const Text('Retry')))
              else if (items.isEmpty)
                _message(Icons.verified_outlined, 'No ${_filter == 'all' ? '' : '${_filter.replaceAll('_', ' ')} '}incidents', 'Everything is running smoothly.')
              else
                for (final i in items) _card(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() => Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.warning_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OWNER CONSOLE', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
            Text('Incidents', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        ),
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: ink)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ),
      ]);

  Widget _tab(String value, String label) {
    final active = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: active ? const Color(0xFF0D6EFD) : const Color(0xFFF0F2FF), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: active ? Colors.white : ink, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, {Widget? action}) => Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(children: [
          Icon(icon, size: 40, color: muted),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12)),
          if (action != null) ...[const SizedBox(height: 14), action],
        ]),
      );

  Widget _card(Map<String, dynamic> i) {
    final severity = '${i['severity']}';
    final status = '${i['status']}';
    final color = _severityColor(severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: severity == 'High' && status != 'resolved' ? Colors.redAccent.withValues(alpha: 0.4) : const Color(0xFFE9EEFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(severity.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('${i['category']}', style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800))),
          Text(_ago(i['created_at'] as String?), style: const TextStyle(color: muted, fontSize: 10)),
        ]),
        const SizedBox(height: 6),
        Text(
          [(i['venues'] as Map?)?['name'], i['court_name']].where((e) => e != null && '$e'.isNotEmpty).join(' • '),
          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text('${i['description']}', style: const TextStyle(color: ink, fontSize: 13, height: 1.4)),
        if ((i['photo_url'] as String?)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network('${i['photo_url']}', height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
          ),
        ],
        if ((i['resolution_note'] as String?)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text('Note: ${i['resolution_note']}', style: const TextStyle(color: muted, fontSize: 12)),
        ],
        const SizedBox(height: 12),
        if (status == 'resolved')
          const Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 6),
            Text('Resolved', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)),
          ])
        else
          Row(children: [
            if (status == 'open')
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _update(i, 'in_progress'),
                  icon: const Icon(Icons.build, size: 14),
                  label: const Text('Start work'),
                ),
              ),
            if (status == 'open') const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _update(i, 'resolved'),
                icon: const Icon(Icons.check, size: 14),
                label: const Text('Resolve'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),
          ]),
      ]),
    );
  }
}
