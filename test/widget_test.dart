import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportsbook_mobile/core/main_wrapper.dart';
import 'test_support/supabase_test_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('SportsBook renders current navigation tabs', (tester) async {
    await initializeTestSupabase();

    await tester.pumpWidget(const MaterialApp(home: MainWrapper()));
    await tester.pump();

    expect(find.text('Courts'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Partners'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
