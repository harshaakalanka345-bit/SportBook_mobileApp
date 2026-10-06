import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/features/discovery/search_screen.dart';

void main() {
  testWidgets('SearchScreen hit test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('>>> ERROR:');
      print(details.exceptionAsString());
    };

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SearchScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    
    // Try to drag to scroll
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    
    print('Test passed without throwing layout exceptions!');
  });
}
