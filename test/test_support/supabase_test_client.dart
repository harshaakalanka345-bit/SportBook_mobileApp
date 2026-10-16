import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportsbook_mobile/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase with an in-memory REST response for widget tests.
/// No test should make requests to the configured production project.
Future<void> initializeTestSupabase() async {
  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockStreamHandler(
    const EventChannel('com.llfbandit.app_links/events'),
    MockStreamHandler.inline(onListen: (_, _) {}),
  );
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
    httpClient: MockClient((request) async {
      final isRead = request.method == 'GET' || request.method == 'HEAD';
      return http.Response(
        isRead ? '[]' : '{}',
        200,
        headers: const {'content-type': 'application/json'},
        request: request,
      );
    }),
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: false,
      persistSession: false,
    ),
  );
}
