import 'package:flutter/material.dart';

/// Sports supported by search, venue setup, court setup, and player preferences.
const kSports = <String>[
  'Badminton',
  'Basketball',
  'Cricket',
  'Futsal',
  'Padel',
  'Squash',
  'Table Tennis',
  'Tennis',
];

IconData sportIcon(String sport) => switch (sport.toLowerCase()) {
  'badminton' => Icons.sports_tennis_rounded,
  'basketball' => Icons.sports_basketball_rounded,
  'cricket' => Icons.sports_cricket_rounded,
  'futsal' || 'football' => Icons.sports_soccer_rounded,
  'squash' => Icons.directions_run_rounded,
  'padel' || 'table tennis' || 'tennis' => Icons.sports_tennis_rounded,
  _ => Icons.sports_rounded,
};
