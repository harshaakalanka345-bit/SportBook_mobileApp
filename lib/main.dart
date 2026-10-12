import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/role_gate.dart';
import 'core/supabase_config.dart';
import 'core/supabase_service.dart';
import 'core/toast.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/auth/splash_screen.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with project credentials
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(
    Provider<SupabaseService>(
      create: (_) => SupabaseService(),
      child: const SportsBookApp(),
    ),
  );
}

// Global Supabase client shorthand
final supabase = Supabase.instance.client;

class SportsBookApp extends StatelessWidget {
  const SportsBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportsBook',
      scaffoldMessengerKey: appMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: MyCustomScrollBehavior(),
      // Define named routes for easier navigation
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/main': (context) => const RoleGate(),
      },
      // Use a custom builder to handle auth state explicitly
      home: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 1500)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          // Default fallback behavior - skip onboarding for demo if needed
          return supabase.auth.currentSession != null ? const RoleGate() : const OnboardingScreen();
        },
      ),
    );
  }
}
