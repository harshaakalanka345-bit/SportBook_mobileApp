import 'package:flutter/material.dart';

import '../features/admin/admin_main_wrapper.dart';
import 'app_theme.dart';
import 'main_wrapper.dart';
import 'supabase_service.dart';

/// Sends the signed-in user to the player app or the owner/admin console based on their profile role.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: SupabaseService().getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFFAF8FF),
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final role = snapshot.data ?? 'player';
        return role == 'owner' || role == 'admin' ? const AdminMainWrapper() : const MainWrapper();
      },
    );
  }
}

/// Replaces the whole navigation stack with the role-appropriate home.
void goHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const RoleGate()),
    (route) => false,
  );
}
