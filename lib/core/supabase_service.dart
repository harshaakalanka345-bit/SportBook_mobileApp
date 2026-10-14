import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Resolve lazily so screens can be constructed before app initialization
  // (for example during widget tests or while the startup gate is loading).
  SupabaseClient get _client => Supabase.instance.client;

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
    String fullName, {
    String? phone,
    String role = 'player',
    List<String> sports = const [],
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'role': role,
        if (sports.isNotEmpty) 'sports': sports,
      },
    );
  }

  /// 'player' (default), 'owner' or 'admin'. Falls back to 'player' if the profile can't be read.
  Future<String> getRole() async {
    try {
      final profile = await getProfile();
      return (profile?['role'] as String?) ?? 'player';
    } catch (_) {
      return 'player';
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').update({...data, 'updated_at': DateTime.now().toIso8601String()}).eq('id', user.id);
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
    final row = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (row != null) return row;
    // Profile missing (e.g. the sign-up trigger failed): create it now.
    try {
      return await _client
          .from('profiles')
          .insert({
            'id': user.id,
            'email': user.email,
            'full_name': (user.userMetadata?['full_name'] as String?) ?? 'SportsBook Member',
          })
          .select()
          .single();
    } catch (_) {
      return null;
    }
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
    final rows = await query.order('created_at', ascending: true);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
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
    final user = _client.auth.currentUser;
    if (user == null) return [];
    return await _client
        .from('bookings')
        .select('*, venues(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }

  /// Slots already taken at a venue on a date (any user). Backed by a SECURITY DEFINER RPC.
  /// Returns `court_name` + `time_slot` (comma-separated slot labels) rows.
  Future<List<Map<String, dynamic>>> getBookedSlots(String venueId, String dateIso) async {
    final res = await _client.rpc('get_booked_slots', params: {'p_venue_id': venueId, 'p_date': dateIso});
    return (res as List).cast<Map<String, dynamic>>();
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

  Future<void> setBookingStatus(String bookingRef, String status) async {
    await _client.from('bookings').update({'status': status}).eq('booking_ref', bookingRef);
  }

  // Delete / Cancel Booking
  Future<void> cancelBooking(String bookingRef, {String? reason}) async {
    await _client.from('bookings').update({
      'status': 'Cancelled',
      if (reason != null) 'cancel_reason': reason,
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

  // ==========================================
  // COURT COMPLEXES (OWNER)
  // ==========================================

  /// Registers a new sports complex owned by the signed-in user.
  Future<Map<String, dynamic>> registerVenue(Map<String, dynamic> data) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('You must be signed in to register a complex.');
    return await _client.from('venues').insert({...data, 'owner_id': user.id}).select().single();
  }

  Future<List<Map<String, dynamic>>> getMyVenues() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    return await _client.from('venues').select().eq('owner_id', user.id).order('created_at', ascending: true);
  }

  Future<void> deleteVenue(String venueId) async {
    await _client.from('venues').delete().eq('id', venueId);
  }

  /// Adds a court with full details.
  Future<void> addCourtDetailed(
    String venueId, {
    required String name,
    required String type,
    String? sport,
    double? hourlyRate,
  }) async {
    await _client.from('courts').insert({
      'venue_id': venueId,
      'name': name,
      'type': type,
      if (sport != null) 'sport': sport,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
    });
  }

  Future<void> updateCourtDetailed(
    String courtId, {
    required String name,
    required String type,
    String? sport,
    double? hourlyRate,
    bool? isActive,
  }) async {
    await _client.from('courts').update({
      'name': name,
      'type': type,
      if (sport != null) 'sport': sport,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
      if (isActive != null) 'is_active': isActive,
    }).eq('id', courtId);
  }

  /// Bookings for every venue the signed-in user owns.
  Future<List<Map<String, dynamic>>> getOwnerBookings() async {
    final venues = await getMyVenues();
    if (venues.isEmpty) return [];
    final ids = venues.map((v) => v['id'] as String).toList();
    return await _client.from('bookings').select('*, venues(name, area, address)').inFilter('venue_id', ids).order('created_at', ascending: false);
  }

  // ==========================================
  // INCIDENTS
  // ==========================================

  Future<void> createIncident({
    String? venueId,
    String? courtName,
    required String category,
    required String severity,
    required String description,
    String? photoUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('You must be signed in to report an incident.');
    await _client.from('incidents').insert({
      'reporter_id': user.id,
      'venue_id': venueId,
      'court_name': courtName,
      'category': category,
      'severity': severity,
      'description': description,
      if (photoUrl != null) 'photo_url': photoUrl,
    });
  }

  /// Incidents visible to the current user (their own reports, or those at venues they own).
  Future<List<Map<String, dynamic>>> getIncidents() async {
    return await _client.from('incidents').select('*, venues(name)').order('created_at', ascending: false);
  }

  Future<void> updateIncident(String id, {required String status, String? note}) async {
    await _client.from('incidents').update({
      'status': status,
      if (note != null) 'resolution_note': note,
      if (status == 'resolved') 'resolved_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ==========================================
  // REVIEWS
  // ==========================================

  Future<void> createReview({required String bookingRef, String? venueId, required int rating, String? comment}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('You must be signed in to leave a review.');
    await _client.from('reviews').insert({
      'user_id': user.id,
      'booking_ref': bookingRef,
      'venue_id': venueId,
      'rating': rating,
      'comment': comment,
    });
  }

  // ==========================================
  // FAVOURITES, SLOT ALERTS, FRIENDS
  // ==========================================

  Future<bool> isFavorite(String venueId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final row = await _client.from('favorite_venues').select('venue_id').eq('user_id', user.id).eq('venue_id', venueId).maybeSingle();
    return row != null;
  }

  /// Returns the new favourite state.
  Future<bool> toggleFavorite(String venueId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Sign in to save venues.');
    if (await isFavorite(venueId)) {
      await _client.from('favorite_venues').delete().eq('user_id', user.id).eq('venue_id', venueId);
      return false;
    }
    await _client.from('favorite_venues').insert({'user_id': user.id, 'venue_id': venueId});
    return true;
  }

  /// "Notify me" when a slot opens for this sport / area.
  Future<void> addSlotAlert({required String sport, required String area}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Sign in to create alerts.');
    await _client.from('slot_alerts').insert({'user_id': user.id, 'sport': sport, 'area': area});
  }

  Future<List<Map<String, dynamic>>> getFriends() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    return await _client.from('friends').select().eq('user_id', user.id).order('created_at', ascending: false);
  }

  Future<void> addFriend({required String name, required String contact}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Sign in to add friends.');
    await _client.from('friends').insert({'user_id': user.id, 'friend_name': name, 'friend_contact': contact});
  }

  Future<void> removeFriend(String id) async {
    await _client.from('friends').delete().eq('id', id);
  }

  // ==========================================
  // PROFILE PREFERENCES, SAVED CARDS, ACCOUNT
  // ==========================================

  /// Merges [changes] into the profile's `preferences` JSON.
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> changes) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');
    final profile = await getProfile();
    final current = Map<String, dynamic>.from((profile?['preferences'] as Map?) ?? const {});
    current.addAll(changes);
    await _client.from('profiles').update({'preferences': current, 'updated_at': DateTime.now().toIso8601String()}).eq('id', user.id);
    return current;
  }

  Future<List<Map<String, dynamic>>> getSavedCards() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    return await _client.from('payment_methods').select().eq('user_id', user.id).order('is_default', ascending: false).order('created_at', ascending: true);
  }

  /// Stores card display details only (brand, last 4, holder, expiry) - never the full number or CVV.
  Future<void> addSavedCard({required String brand, required String last4, required String holder, required String expiry}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');
    final existing = await getSavedCards();
    await _client.from('payment_methods').insert({
      'user_id': user.id,
      'brand': brand,
      'last4': last4,
      'holder_name': holder,
      'expiry': expiry,
      'is_default': existing.isEmpty,
    });
  }

  Future<void> setDefaultCard(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');
    await _client.from('payment_methods').update({'is_default': false}).eq('user_id', user.id);
    await _client.from('payment_methods').update({'is_default': true}).eq('id', id);
  }

  Future<void> deleteSavedCard(String id) async {
    await _client.from('payment_methods').delete().eq('id', id);
  }

  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Permanently deletes the signed-in account (profile, bookings link, cards...) via a SECURITY DEFINER RPC.
  Future<void> deleteAccount() async {
    await _client.rpc('delete_my_account');
    await _client.auth.signOut();
  }

  // ==========================================
  // SUPPORT: PHOTO EVIDENCE + VENUE SUGGESTIONS
  // ==========================================

  /// Uploads an incident photo and returns its public URL.
  Future<String> uploadIncidentPhoto(List<int> bytes, String extension) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Sign in to attach photos.');
    final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _client.storage.from('incident-photos').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: 'image/$extension'),
        );
    return _client.storage.from('incident-photos').getPublicUrl(path);
  }

  Future<void> suggestVenue({required String name, required String area, String? sport, String? notes}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Sign in to suggest a venue.');
    await _client.from('venue_suggestions').insert({
      'user_id': user.id,
      'name': name,
      'area': area,
      if (sport != null) 'sport': sport,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  /// Uploads a complex cover image and returns its public URL.
  Future<String> uploadVenueImage(List<int> bytes, String extension) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Sign in to upload images.');
    final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _client.storage.from('venue-images').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: 'image/$extension'),
        );
    return _client.storage.from('venue-images').getPublicUrl(path);
  }

  // ==========================================
  // OWNER SCHEDULE: bookings, blocks, surges, walk-ins
  // ==========================================

  /// All non-cancelled bookings for a venue on a date (owner view).
  Future<List<Map<String, dynamic>>> getVenueBookingsOn(String venueId, String dateIso) async {
    return await _client.from('bookings').select().eq('venue_id', venueId).eq('date_schedule', dateIso).neq('status', 'Cancelled').order('created_at');
  }

  /// Names / phones for customer ids (visible to owners for people who booked at their venues).
  Future<Map<String, Map<String, dynamic>>> getCustomers(List<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await _client.from('profiles').select('id, full_name, phone').inFilter('id', ids);
    return {for (final r in rows) r['id'] as String: Map<String, dynamic>.from(r)};
  }

  Future<List<Map<String, dynamic>>> getSlotBlocks(String venueId, String dateIso) async {
    final rows = await _client.from('slot_blocks').select().eq('venue_id', venueId).eq('date_schedule', dateIso);
    final now = DateTime.now().toUtc();
    return rows.where((r) {
      final exp = r['expires_at'] as String?;
      return exp == null || DateTime.parse(exp).isAfter(now);
    }).toList();
  }

  Future<void> addSlotBlocks({
    required String venueId,
    required String courtName,
    required String dateIso,
    required List<String> slotLabels,
    required String reason,
    String? note,
    DateTime? expiresAt,
  }) async {
    final user = _client.auth.currentUser;
    await _client.from('slot_blocks').upsert(
      [
        for (final s in slotLabels)
          {
            'venue_id': venueId,
            'court_name': courtName,
            'date_schedule': dateIso,
            'time_slot': s,
            'reason': reason,
            'note': note,
            'expires_at': expiresAt?.toUtc().toIso8601String(),
            'created_by': user?.id,
          },
      ],
      onConflict: 'venue_id,court_name,date_schedule,time_slot',
    );
  }

  Future<void> removeSlotBlocks(List<String> ids) async {
    if (ids.isEmpty) return;
    await _client.from('slot_blocks').delete().inFilter('id', ids);
  }

  Future<List<Map<String, dynamic>>> getSurges(String venueId, String dateIso) async {
    return await _client.from('slot_surges').select().eq('venue_id', venueId).eq('date_schedule', dateIso);
  }

  Future<void> setSurge({
    required String venueId,
    required String courtName,
    required String dateIso,
    required List<String> slotLabels,
    required double amount,
  }) async {
    if (amount <= 0) {
      await _client.from('slot_surges').delete().eq('venue_id', venueId).eq('court_name', courtName).eq('date_schedule', dateIso).inFilter('time_slot', slotLabels);
      return;
    }
    await _client.from('slot_surges').upsert(
      [
        for (final s in slotLabels) {'venue_id': venueId, 'court_name': courtName, 'date_schedule': dateIso, 'time_slot': s, 'amount': amount},
      ],
      onConflict: 'venue_id,court_name,date_schedule,time_slot',
    );
  }

  /// Extends a booking by appending slots and adding the extra amount to what was paid.
  Future<void> extendBooking(String bookingRef, {required String newTimeSlot, required double newTotal}) async {
    await _client.from('bookings').update({'time_slot': newTimeSlot, 'total_paid': newTotal}).eq('booking_ref', bookingRef);
  }

  Future<Map<String, dynamic>?> lookupCustomer(String phone) async {
    final res = await _client.rpc('lookup_customer', params: {'p_phone': phone});
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.isEmpty ? null : list.first;
  }

  Future<void> debitCustomerWallet(String userId, double amount) async {
    await _client.rpc('debit_customer_wallet', params: {'p_user': userId, 'p_amount': amount});
  }

  /// Creates a counter (walk-in) booking at a venue the signed-in owner manages.
  Future<void> createWalkInBooking({
    required String venueId,
    required String bookingRef,
    required String courtName,
    required String dateIso,
    required String timeSlot,
    required double total,
    required String pin,
    required String paymentMethod,
    String? customerId,
    String? guestName,
    String? guestPhone,
    List<Map<String, dynamic>>? addons,
  }) async {
    await _client.from('bookings').insert({
      'venue_id': venueId,
      'user_id': customerId,
      'booking_ref': bookingRef,
      'court_name': courtName,
      'date_schedule': dateIso,
      'time_slot': timeSlot,
      'total_paid': total,
      'qr_turnstile_pin': pin,
      'status': 'Confirmed',
      'addons': addons ?? [],
      'source': 'walk_in',
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'payment_method': paymentMethod,
    });
  }

  // ==========================================
  // OWNER: CHECK-IN, LEDGER, SHIFTS
  // ==========================================

  /// Finds an owner-visible booking by reference or by 4-digit gate PIN (today first).
  Future<Map<String, dynamic>?> findBookingForCheckin(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    final byRef = await _client.from('bookings').select('*, venues(name, owner_id)').eq('booking_ref', c).maybeSingle();
    if (byRef != null) return byRef;
    final rows = await _client.from('bookings').select('*, venues(name, owner_id)').eq('qr_turnstile_pin', c).neq('status', 'Cancelled').order('date_schedule', ascending: false).limit(10);
    if (rows.isEmpty) return null;
    final today = DateTime.now();
    final iso = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return rows.firstWhere((r) => r['date_schedule'] == iso, orElse: () => rows.first);
  }

  Future<void> markBookingRefunded(String bookingRef, String method) async {
    await _client.from('bookings').update({'refunded_at': DateTime.now().toUtc().toIso8601String(), 'refund_method': method}).eq('booking_ref', bookingRef);
  }

  Future<void> refundBooking(Map<String, dynamic> booking, {required bool toWallet}) async {
    final amount = (booking['total_paid'] as num?)?.toDouble() ?? 0;
    final userId = booking['user_id'] as String?;
    if (toWallet) {
      if (userId == null) throw Exception('Guest bookings have no wallet. Refund in cash instead.');
      await _client.rpc('credit_customer_wallet', params: {'p_user': userId, 'p_amount': amount});
    }
    await _client.from('bookings').update({'refunded_at': DateTime.now().toUtc().toIso8601String(), 'refund_method': toWallet ? 'wallet' : 'card'}).eq('booking_ref', booking['booking_ref'] as String);
  }

  Future<void> closeShift({
    required String venueId,
    required String shiftDate,
    required int bookingsCount,
    required double cashTotal,
    required double digitalTotal,
    required double refundsTotal,
    double? countedCash,
    String? note,
  }) async {
    final user = _client.auth.currentUser;
    await _client.from('shift_closures').insert({
      'venue_id': venueId,
      'closed_by': user?.id,
      'shift_date': shiftDate,
      'bookings_count': bookingsCount,
      'cash_total': cashTotal,
      'digital_total': digitalTotal,
      'refunds_total': refundsTotal,
      'counted_cash': countedCash,
      'note': note,
    });
  }

  Future<List<Map<String, dynamic>>> getShiftClosures() async {
    return await _client.from('shift_closures').select('*, venues(name)').order('created_at', ascending: false).limit(10);
  }
}
