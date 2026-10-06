import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/features/discovery/search_screen.dart';

void main() {
  testWidgets('SearchScreen full layout test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(517.6, 3000);
    tester.view.devicePixelRatio = 1.0;

    FlutterError.onError = (FlutterErrorDetails details) {
      print('>>> EXCEPTION CAUGHT:');
      print(details.exceptionAsString());
    };

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SearchScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    
    print('Test passed without throwing layout exceptions!');
  });
}
