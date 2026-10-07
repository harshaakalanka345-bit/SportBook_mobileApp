import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  // Arena State
  String _arenaName = 'Colombo Sports Authority Arena';
  String _arenaBio = 'Premium indoor sports facility with state-of-the-art courts.';
  String _arenaLocation = 'Colombo 07, Sri Lanka';

  // Courts State
  List<Map<String, String>> _courts = [
    {'id': '1', 'name': 'Court 1', 'type': 'Premium Teak Parquet Floor'},
    {'id': '2', 'name': 'Court 2', 'type': 'Synthetic Indoor Shoe Rubber'},
  ];

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

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
              _buildAdminProfileHeader(),
              const SizedBox(height: 24),
              _buildArenaInformation(),
              const SizedBox(height: 24),
              _buildCourtManagement(),
              const SizedBox(height: 24),
              _buildAdminShiftDetails(),
              const SizedBox(height: 32),
              _buildLogoutSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ink),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Admin Profile & Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Center(
              child: Text('SA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('System Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(4)),
                      child: const Text('OWNER', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_arenaName, style: const TextStyle(color: Color(0xFF4A5568), fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArenaInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ARENA INFORMATION', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              GestureDetector(
                onTap: _showEditArenaDialog,
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(Icons.stadium_outlined, 'Arena Name', _arenaName),
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.location_on_outlined, 'Location', _arenaLocation),
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.info_outline, 'Bio / Description', _arenaBio),
        ],
      ),
    );
  }

  Widget _buildCourtManagement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('COURT MANAGEMENT', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              GestureDetector(
                onTap: () => _showCourtDialog(),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text('Add Court', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_courts.isEmpty)
            const Text('No courts added yet.', style: TextStyle(color: muted, fontSize: 13))
          else
            ..._courts.asMap().entries.map((entry) {
              final index = entry.key;
              final court = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.sports_tennis, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(court['name']!, style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(court['type']!, style: const TextStyle(color: muted, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
                        onPressed: () => _showCourtDialog(index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () => _deleteCourt(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAdminShiftDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CURRENT SHIFT', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          _detailRow(Icons.account_balance, 'Active Floor', _arenaName),
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.desktop_windows, 'Desk Terminal', 'Terminal #04'),
          const Divider(height: 24, color: Color(0xFFF1F4FF)),
          _detailRow(Icons.access_time, 'Shift Started', '08:00 AM (4h 31m ago)'),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: muted)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton.icon(
        onPressed: () async {
          final supabase = Supabase.instance.client;
          await supabase.auth.signOut();
          if (!context.mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Log Out of Staff Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent,
          backgroundColor: const Color(0xFFFFF0F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // --- CRUD Operations Dialogs ---

  void _showEditArenaDialog() {
    final nameController = TextEditingController(text: _arenaName);
    final locationController = TextEditingController(text: _arenaLocation);
    final bioController = TextEditingController(text: _arenaBio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Edit Arena Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Arena Name')),
                const SizedBox(height: 12),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 12),
                TextField(controller: bioController, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio / Description')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                setState(() {
                  _arenaName = nameController.text;
                  _arenaLocation = locationController.text;
                  _arenaBio = bioController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCourtDialog({int? index}) {
    final isEditing = index != null;
    final nameController = TextEditingController(text: isEditing ? _courts[index]['name'] : '');
    final typeController = TextEditingController(text: isEditing ? _courts[index]['type'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEditing ? 'Edit Court' : 'Add Court', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Court Name (e.g. Court 3)')),
              const SizedBox(height: 12),
              TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Surface Type (e.g. Synthetic)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                setState(() {
                  if (isEditing) {
                    _courts[index] = {
                      'id': _courts[index]['id']!,
                      'name': nameController.text,
                      'type': typeController.text,
                    };
                  } else {
                    _courts.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': nameController.text,
                      'type': typeController.text,
                    });
                  }
                });
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourt(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Court?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete ${_courts[index]['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _courts.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
