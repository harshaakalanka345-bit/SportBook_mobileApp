import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns Supabase auth errors into messages a user can act on.
String authErrorMessage(AuthException e) {
  final code = (e is AuthApiException ? e.code : null) ?? '';
  final msg = e.message.toLowerCase();
  if (code == 'over_email_send_rate_limit' || msg.contains('email rate limit')) {
    return 'Too many sign-up emails were sent recently. Please wait about an hour and try again, or ask the admin to turn off email confirmation.';
  }
  if (code == 'user_already_exists' || msg.contains('already registered')) {
    return 'An account with this email already exists. Try logging in instead.';
  }
  if (code == 'invalid_credentials' || msg.contains('invalid login')) {
    return 'Incorrect email or password.';
  }
  if (code == 'email_not_confirmed' || msg.contains('not confirmed')) {
    return 'Please verify your email first - check your inbox for the confirmation link.';
  }
  if (code == 'weak_password') return 'That password is too weak. Use at least 8 characters.';
  return e.message;
}
