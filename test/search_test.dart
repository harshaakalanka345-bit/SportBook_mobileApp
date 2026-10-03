import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsbook_mobile/features/discovery/search_screen.dart';
import 'package:sportsbook_mobile/features/booking/booking_screen.dart';

void main() {
  testWidgets('SearchScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
    expect(find.byType(SearchScreen), findsOneWidget);
  });
  
  testWidgets('BookingScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BookingScreen()));
    expect(find.byType(BookingScreen), findsOneWidget);
  });
}
