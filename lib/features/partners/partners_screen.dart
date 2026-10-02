import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  final _service = SupabaseService();

  Future<List<Map<String, dynamic>>> _loadBeacons() =>
      _service.getMatchBeacons();

  void _showCreateBeaconSheet() {
    String sport = 'Badminton';
    String skillLevel = 'Intermediate';
    final venueController = TextEditingController(text: 'Torrington Racquet Hub');
    final timeController = TextEditingController(text: 'Tomorrow 06:00 PM');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Broadcast Matchmaker Beacon',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find nearby players looking for a game.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: sport,
                decoration: const InputDecoration(labelText: 'Sport'),
                items: const [
                  DropdownMenuItem(value: 'Badminton', child: Text('Badminton')),
                  DropdownMenuItem(value: 'Tennis', child: Text('Tennis')),
                  DropdownMenuItem(value: 'Futsal', child: Text('Futsal')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => sport = val);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: skillLevel,
                decoration: const InputDecoration(labelText: 'Skill Level'),
                items: const [
                  DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                      value: 'Intermediate', child: Text('Intermediate')),
                  DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => skillLevel = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: venueController,
                decoration: const InputDecoration(labelText: 'Venue Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Scheduled Time'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (venueController.text.isEmpty ||
                      timeController.text.isEmpty) {
                    return;
                  }
                  Navigator.pop(ctx);
                  try {
                    await _service.createMatchBeacon(
                      sport: sport,
                      skillLevel: skillLevel,
                      venueName: venueController.text.trim(),
                      scheduledTime: timeController.text.trim(),
                    );
                    if (!mounted) return;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Matchmaker beacon broadcasted!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Broadcast Beacon'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matchmaker Beacons'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBeaconSheet,
        icon: const Icon(Icons.radar),
        label: const Text('New Beacon'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadBeacons(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error loading beacons: ${snapshot.error}'),
                ),
              );
            }
            final beacons = snapshot.data ?? [];
            if (beacons.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No open matchmaker beacons right now.\nTap "New Beacon" to broadcast one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: beacons.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = beacons[index];
                final sport = b['sport'] ?? 'Badminton';
                final skill = b['skill_level'] ?? 'Intermediate';
                final venue = b['venue_name'] ?? 'Venue';
                final time = b['scheduled_time'] ?? 'Today';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  sport == 'Tennis'
                                      ? Icons.sports_tennis
                                      : sport == 'Futsal'
                                          ? Icons.sports_soccer
                                          : Icons.sports_tennis_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  sport,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          venue,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              time,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connected with match at $venue!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: const Text('Join Match'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
