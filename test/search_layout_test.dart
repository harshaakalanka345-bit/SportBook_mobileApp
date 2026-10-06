import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/features/discovery/search_screen.dart';

void main() {
  testWidgets('SearchScreen layout test 517', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(517.6, 670.4);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SearchScreen(),
      ),
    ));
    print('Test passed without throwing layout exceptions!');
  });
}
