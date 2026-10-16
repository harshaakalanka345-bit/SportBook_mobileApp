import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/features/discovery/search_screen.dart';
import 'test_support/supabase_test_client.dart';

void main() {
  testWidgets('SearchScreen full layout test', (WidgetTester tester) async {
    await initializeTestSupabase();
    tester.view.physicalSize = const Size(517.6, 3000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SearchScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    
    expect(tester.takeException(), isNull);
  });
}
