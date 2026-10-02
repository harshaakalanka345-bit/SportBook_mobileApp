import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://hveuhkdtmlujxjinnecs.supabase.co';
  static const String publishableKey =
      'sb_publishable_j7fr6Q9Hf2VXp5d28AY81w_lEdEDRGH';

  /// Shortcut accessor for Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}
