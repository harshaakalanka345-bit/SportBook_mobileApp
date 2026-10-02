import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportsbook_mobile/core/mock_database.dart';
import 'package:sportsbook_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('SportsBook home tab lists seeded courts', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final database = MockDatabase();
    await database.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: database,
        child: const SportsBookApp(showSplash: false),
      ),
    );

    expect(find.text('SportsBook'), findsNothing);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Royal Indoor Badminton'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
