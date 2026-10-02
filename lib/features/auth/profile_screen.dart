import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/mock_database.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            db.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Member · Colombo',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              title: const Text('Wallet'),
              subtitle: Text('LKR ${db.walletLkr}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WalletScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
