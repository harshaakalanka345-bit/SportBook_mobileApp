import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _service = SupabaseService();
  String _query = '';
  List<Map<String, dynamic>> _venues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    setState(() => _isLoading = true);
    try {
      final venues = await _service.getVenues();
      if (mounted) {
        setState(() {
          _venues = venues;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _venues.where((v) {
      final name = (v['name'] ?? '').toString().toLowerCase();
      final area = (v['area'] ?? '').toString().toLowerCase();
      final sport = (v['sport'] ?? '').toString().toLowerCase();
      final q = _query.toLowerCase();
      return name.contains(q) || area.contains(q) || sport.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Venue, area, or sport in Colombo',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            'No venues match that search.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final venue = results[index];
                            final hourlyRate = venue['hourly_rate'] ?? 1500;
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.place,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(venue['name'] ?? ''),
                                subtitle: Text(
                                  '${venue['area']} · ${venue['sport']} (${venue['environment'] ?? 'Indoor'})',
                                ),
                                trailing: Text(
                                  'LKR $hourlyRate',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
