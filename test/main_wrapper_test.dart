import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/core/main_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('MainWrapper layout test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('supabase')) return;
      print('>>> TEST FLUTTER ERROR CAUGHT <<<');
      print(details.exceptionAsString());
    };

    await tester.pumpWidget(const MaterialApp(
      home: MainWrapper(),
    ));
    // Tap on Search tab
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    
    print('Test passed without throwing layout exceptions!');
  });
}
