import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportsbook_mobile/core/main_wrapper.dart';
import 'test_support/supabase_test_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final tab in ['Search', 'Bookings', 'Profile']) {
    testWidgets('tab $tab renders', (tester) async {
      await initializeTestSupabase();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: MainWrapper()));
      await tester.pump();
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  }
}
