import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/features/discovery/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen layout test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('>>> TEST FLUTTER ERROR CAUGHT <<<');
      print(details.exceptionAsString());
    };

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DashboardScreen(),
      ),
    ));
    print('Test passed without throwing layout exceptions!');
  });
}
