import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import 'auth_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final user = _service.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (user == null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.surfaceMuted,
                        child: Icon(Icons.person_outline,
                            size: 36, color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Guest Player',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to manage your bookings and wallet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AuthScreen()),
                          );
                          if (result == true) setState(() {});
                        },
                        child: const Text('Sign In or Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              FutureBuilder<Map<String, dynamic>?>(
                future: _service.getProfile(),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  final fullName =
                      profile?['full_name'] ?? user.email?.split('@').first ?? 'Member';
                  final balance =
                      (profile?['wallet_balance'] as num?)?.toDouble() ?? 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'M',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email ?? '',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.surfaceMuted,
                            child: Icon(Icons.account_balance_wallet,
                                color: AppColors.primary),
                          ),
                          title: const Text('SportsBook Wallet'),
                          subtitle: Text('Balance: LKR ${balance.toStringAsFixed(0)}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WalletScreen(),
                              ),
                            );
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.surfaceMuted,
                            child: Icon(Icons.logout, color: Colors.redAccent),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          onTap: () async {
                            await _service.signOut();
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
