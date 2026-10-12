import 'package:flutter/material.dart';

import '../../core/actions.dart';
import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import 'create_match_beacon_screen.dart';

/// Full list of open match beacons.
class AllBeaconsScreen extends StatefulWidget {
  const AllBeaconsScreen({super.key});

  @override
  State<AllBeaconsScreen> createState() => _AllBeaconsScreenState();
}

class _AllBeaconsScreenState extends State<AllBeaconsScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  final _service = SupabaseService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMatchBeacons();
  }

  Future<void> _refresh() async {
    final f = _service.getMatchBeacons();
    setState(() => _future = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: ink), onPressed: () => Navigator.pop(context)),
        title: const Text('Live Match Hubs', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateMatchBeaconScreen()));
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Request a Partner'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Center(child: Text('Could not load beacons: ${snap.error}', style: const TextStyle(color: muted)));
            final list = snap.data ?? [];
            if (list.isEmpty) return ListView(children: const [SizedBox(height: 120), Center(child: Text('No open beacons right now.', style: TextStyle(color: muted)))]);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final b = list[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${b['sport']} - ${b['skill_level']}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('${b['venue_name']}', style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${b['scheduled_time']}', style: const TextStyle(color: muted, fontSize: 13)),
                      ]),
                    ),
                    IconButton(
                      onPressed: () => shareText('Match beacon: ${b['sport']} (${b['skill_level']}) at ${b['venue_name']}, ${b['scheduled_time']}. Join me on SportsBook!'),
                      icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                    ),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
