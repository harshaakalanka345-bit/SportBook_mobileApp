import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/mock_database.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Courts near Colombo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 12),
          ...db.courts.map(
            (court) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  title: Text(court.name),
                  subtitle: Text('${court.area} · ${court.sport}'),
                  trailing: Text('LKR ${court.hourlyRateLkr}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
