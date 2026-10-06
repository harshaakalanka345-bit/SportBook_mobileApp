import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportsbook_mobile/core/main_wrapper.dart';
import 'package:sportsbook_mobile/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final tab in ['Search', 'Bookings', 'Profile']) {
    testWidgets('golden $tab', (tester) async {
      SharedPreferences.setMockInitialValues({});
      try {
        await Supabase.initialize(
          url: SupabaseConfig.url,
          publishableKey: SupabaseConfig.publishableKey,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        );
      } catch (_) {}
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: MainWrapper()));
      await tester.pump();
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(milliseconds: 500));
      while (tester.takeException() != null) {}
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$tab.png'),
      );
    });
  }
}
