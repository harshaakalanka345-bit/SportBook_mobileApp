import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/main_wrapper.dart';
import 'core/mock_database.dart';
import 'features/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = MockDatabase();
  await database.init();

  runApp(
    ChangeNotifierProvider.value(
      value: database,
      child: const SportsBookApp(),
    ),
  );
}

class SportsBookApp extends StatelessWidget {
  const SportsBookApp({super.key, this.showSplash = true});

  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportsBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: showSplash ? const SplashScreen() : const MainWrapper(),
    );
  }
}
