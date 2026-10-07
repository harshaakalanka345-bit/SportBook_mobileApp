import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==========================================
  // MEMBER 1: AUTH & PROFILE
  // ==========================================

  // Create Profile / Sign Up
  Future<AuthResponse> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  // Sign In with Email & Password
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Read Profile
  Future<Map<String, dynamic>?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  // Update Profile & Wallet
  Future<void> topUpWallet(double amount) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final profile = await getProfile();
    final currentBalance =
        (profile?['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    await _client.from('profiles').update({
      'wallet_balance': currentBalance + amount,
    }).eq('id', user.id);
  }

  // ==========================================
  // MEMBER 2: VENUE DISCOVERY & FILTERS
  // ==========================================

  // Read Venues (Filtered)
  Future<List<Map<String, dynamic>>> getVenues({
    String? sport,
    String? environment,
  }) async {
    var query = _client.from('venues').select();
    if (sport != null && sport != 'All') {
      query = query.eq('sport', sport);
    }
    if (environment != null && environment != 'All') {
      query = query.eq('environment', environment);
    }
    return await query;
  }

  // ==========================================
  // MEMBER 3: BOOKINGS & LOCKS
  // ==========================================

  // Create Booking
  Future<void> createBooking({
    required String venueId,
    required String bookingRef,
    required String courtName,
    required String dateSchedule,
    required String timeSlot,
    required double totalPaid,
    required String qrPin,
    List<Map<String, dynamic>>? addons,
  }) async {
    final user = _client.auth.currentUser;
    await _client.from('bookings').insert({
      'user_id': user?.id,
      'venue_id': venueId,
      'booking_ref': bookingRef,
      'court_name': courtName,
      'date_schedule': dateSchedule,
      'time_slot': timeSlot,
      'total_paid': totalPaid,
      'qr_turnstile_pin': qrPin,
      'status': 'Confirmed',
      'addons': addons ?? [],
    });
  }

  // Read User Bookings
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    return await _client
        .from('bookings')
        .select('*, venues(*)')
        .order('created_at', ascending: false);
  }

  // ==========================================
  // MEMBER 4: RESCHEDULE, CANCEL & BEACONS
  // ==========================================

  // Update: Reschedule Booking
  Future<void> rescheduleBooking(
    String bookingRef,
    String newSlot,
    String newDate,
  ) async {
    await _client.from('bookings').update({
      'time_slot': newSlot,
      'date_schedule': newDate,
      'status': 'Rescheduled',
    }).eq('booking_ref', bookingRef);
  }

  // Delete / Cancel Booking
  Future<void> cancelBooking(String bookingRef) async {
    await _client.from('bookings').update({
      'status': 'Cancelled',
    }).eq('booking_ref', bookingRef);
  }

  // Create Matchmaker Beacon
  Future<void> createMatchBeacon({
    required String sport,
    required String skillLevel,
    required String venueName,
    required String scheduledTime,
  }) async {
    final user = _client.auth.currentUser;
    await _client.from('match_beacons').insert({
      'host_user_id': user?.id,
      'sport': sport,
      'skill_level': skillLevel,
      'venue_name': venueName,
      'scheduled_time': scheduledTime,
    });
  }

  // Read Matchmaker Beacons
  Future<List<Map<String, dynamic>>> getMatchBeacons() async {
    return await _client
        .from('match_beacons')
        .select()
        .order('created_at', ascending: false);
  }

  // ==========================================
  // MEMBER 5: ADMIN CRUD (ARENAS & COURTS)
  // ==========================================

  // Get Admin Venue (Arena Details)
  Future<Map<String, dynamic>?> getAdminVenue(String venueId) async {
    return await _client.from('venues').select().eq('id', venueId).maybeSingle();
  }

  // Update Admin Venue (Arena Details)
  Future<void> updateAdminVenue(String venueId, Map<String, dynamic> data) async {
    await _client.from('venues').update(data).eq('id', venueId);
  }

  // Get Courts for Venue
  Future<List<Map<String, dynamic>>> getVenueCourts(String venueId) async {
    return await _client.from('courts').select().eq('venue_id', venueId).order('created_at', ascending: true);
  }

  // Add Court
  Future<void> addCourt(String venueId, String name, String type) async {
    await _client.from('courts').insert({
      'venue_id': venueId,
      'name': name,
      'type': type,
    });
  }

  // Update Court
  Future<void> updateCourt(String courtId, String name, String type) async {
    await _client.from('courts').update({
      'name': name,
      'type': type,
    }).eq('id', courtId);
  }

  // Delete Court
  Future<void> deleteCourt(String courtId) async {
    await _client.from('courts').delete().eq('id', courtId);
  }
  // Reset Password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

}
