import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/core/main_wrapper.dart';
import 'test_support/supabase_test_client.dart';

void main() {
  testWidgets('MainWrapper layout test', (WidgetTester tester) async {
    await initializeTestSupabase();

    await tester.pumpWidget(const MaterialApp(
      home: MainWrapper(),
    ));
    // Tap on Search tab
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    
    expect(tester.takeException(), isNull);
  });
}
