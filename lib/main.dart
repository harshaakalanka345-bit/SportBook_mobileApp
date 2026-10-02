import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/main_wrapper.dart';
import 'core/mock_database.dart';
import 'core/supabase_config.dart';
import 'core/supabase_service.dart';
import 'features/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with project credentials
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final database = MockDatabase();
  await database.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: database),
        Provider(create: (_) => SupabaseService()),
      ],
      child: const SportsBookApp(),
    ),
  );
}

// Global Supabase client shorthand
final supabase = Supabase.instance.client;
final supabaseService = SupabaseService();

class SportsBookApp extends StatelessWidget {
  const SportsBookApp({super.key, this.showSplash = false});

  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportsBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: showSplash ? const SplashScreen() : const MainWrapper(),
    );
  }
}
