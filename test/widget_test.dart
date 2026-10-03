import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportsbook_mobile/core/supabase_config.dart';
import 'package:sportsbook_mobile/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('SportsBook renders navigation bar tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
        authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
      );
    } catch (_) {
      // Supabase already initialized in test environment
    }

    await tester.pumpWidget(
      const SportsBookApp(showSplash: false, showOnboarding: false),
    );
    await tester.pump();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Book'), findsOneWidget);
    expect(find.text('Partners'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
