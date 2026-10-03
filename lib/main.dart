import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/main_wrapper.dart';
import 'core/supabase_config.dart';
import 'core/supabase_service.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/auth/splash_screen.dart';

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
final supabaseService = SupabaseService();

class SportsBookApp extends StatelessWidget {
  const SportsBookApp({
    super.key,
    this.showSplash = false,
    this.showOnboarding = true,
  });

  final bool showSplash;
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportsBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) => _MobilePreviewFrame(
        child: child ?? const SizedBox.shrink(),
      ),
      home: showOnboarding
          ? const OnboardingScreen()
          : showSplash
          ? const SplashScreen()
          : const MainWrapper(),
    );
  }
}

class _MobilePreviewFrame extends StatelessWidget {
  const _MobilePreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktopViewport = mediaQuery.size.width > 600;

    if (!isDesktopViewport) return child;

    final phoneWidth = 390.0;
    final phoneSize = Size(phoneWidth, mediaQuery.size.height);
    final phoneMediaQuery = mediaQuery.copyWith(size: phoneSize);

    return ColoredBox(
      color: const Color(0xFFE9ECF5),
      child: Center(
        child: SizedBox(
          width: phoneWidth,
          height: mediaQuery.size.height,
          child: MediaQuery(
            data: phoneMediaQuery,
            child: child,
          ),
        ),
      ),
    );
  }
}
