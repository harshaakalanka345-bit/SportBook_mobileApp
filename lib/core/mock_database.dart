import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Court {
  const Court({
    required this.id,
    required this.name,
    required this.area,
    required this.sport,
    required this.hourlyRateLkr,
  });

  final String id;
  final String name;
  final String area;
  final String sport;
  final int hourlyRateLkr;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'area': area,
        'sport': sport,
        'hourlyRateLkr': hourlyRateLkr,
      };

  factory Court.fromJson(Map<String, dynamic> json) => Court(
        id: json['id'] as String,
        name: json['name'] as String,
        area: json['area'] as String,
        sport: json['sport'] as String,
        hourlyRateLkr: json['hourlyRateLkr'] as int,
      );
}

class Booking {
  const Booking({
    required this.id,
    required this.courtId,
    required this.slotLabel,
    required this.status,
  });

  final String id;
  final String courtId;
  final String slotLabel;
  final String status;

  Booking copyWith({String? status}) => Booking(
        id: id,
        courtId: courtId,
        slotLabel: slotLabel,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courtId': courtId,
        'slotLabel': slotLabel,
        'status': status,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        courtId: json['courtId'] as String,
        slotLabel: json['slotLabel'] as String,
        status: json['status'] as String,
      );
}

/// In-memory cache with SharedPreferences persistence for viva demos.
class MockDatabase extends ChangeNotifier {
  static const _courtsKey = 'sportsbook.courts';
  static const _bookingsKey = 'sportsbook.bookings';
  static const _walletKey = 'sportsbook.walletLkr';
  static const _displayNameKey = 'sportsbook.displayName';

  SharedPreferences? _prefs;

  List<Court> courts = const [];
  List<Booking> bookings = const [];
  int walletLkr = 0;
  String displayName = 'Guest';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final storedCourts = _prefs!.getString(_courtsKey);
    if (storedCourts == null) {
      courts = List<Court>.from(_seedCourts);
      bookings = const [];
      walletLkr = 2500;
      displayName = 'Guest';
      await _persist();
    } else {
      courts = (jsonDecode(storedCourts) as List)
          .map((e) => Court.fromJson(e as Map<String, dynamic>))
          .toList();
      final storedBookings = _prefs!.getString(_bookingsKey) ?? '[]';
      bookings = (jsonDecode(storedBookings) as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
      walletLkr = _prefs!.getInt(_walletKey) ?? 0;
      displayName = _prefs!.getString(_displayNameKey) ?? 'Guest';
    }
    notifyListeners();
  }

  Future<void> upsertCourt(Court court) async {
    final index = courts.indexWhere((c) => c.id == court.id);
    if (index >= 0) {
      courts = [...courts]..[index] = court;
    } else {
      courts = [...courts, court];
    }
    await _persist();
  }

  Future<void> deleteCourt(String id) async {
    courts = courts.where((c) => c.id != id).toList();
    bookings = bookings.where((b) => b.courtId != id).toList();
    await _persist();
  }

  Future<void> createBooking(Booking booking) async {
    bookings = [...bookings, booking];
    await _persist();
  }

  Future<void> updateBooking(Booking booking) async {
    bookings = [
      for (final existing in bookings)
        if (existing.id == booking.id) booking else existing,
    ];
    await _persist();
  }

  Future<void> deleteBooking(String id) async {
    bookings = bookings.where((b) => b.id != id).toList();
    await _persist();
  }

  Future<void> setWalletLkr(int amount) async {
    walletLkr = amount;
    await _persist();
  }

  Future<void> setDisplayName(String name) async {
    displayName = name;
    await _persist();
  }

  Court? courtById(String id) {
    for (final court in courts) {
      if (court.id == id) return court;
    }
    return null;
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(
      _courtsKey,
      jsonEncode(courts.map((c) => c.toJson()).toList()),
    );
    await prefs.setString(
      _bookingsKey,
      jsonEncode(bookings.map((b) => b.toJson()).toList()),
    );
    await prefs.setInt(_walletKey, walletLkr);
    await prefs.setString(_displayNameKey, displayName);
    notifyListeners();
  }

  static const _seedCourts = [
    Court(
      id: 'court-colombo-01',
      name: 'Royal Indoor Badminton',
      area: 'Colombo 07',
      sport: 'Badminton',
      hourlyRateLkr: 1800,
    ),
    Court(
      id: 'court-colombo-02',
      name: 'Torrington Racquet Hub',
      area: 'Colombo 05',
      sport: 'Badminton',
      hourlyRateLkr: 1500,
    ),
    Court(
      id: 'court-colombo-03',
      name: 'Bambalapitiya Smash Courts',
      area: 'Colombo 04',
      sport: 'Badminton',
      hourlyRateLkr: 1600,
    ),
    Court(
      id: 'court-colombo-04',
      name: 'Nugegoda Night League',
      area: 'Nugegoda',
      sport: 'Badminton',
      hourlyRateLkr: 1400,
    ),
  ];
}
