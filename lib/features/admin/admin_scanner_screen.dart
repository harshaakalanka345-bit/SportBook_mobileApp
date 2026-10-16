import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/app_theme.dart';
import '../../core/slots.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import 'admin_profile_screen.dart';

/// Gate scanner: scan a match-pass QR (or type a booking reference / 4-digit PIN), verify it and check the player in.
class AdminScannerScreen extends StatefulWidget {
  const AdminScannerScreen({super.key});

  @override
  State<AdminScannerScreen> createState() => _AdminScannerScreenState();
}

class _AdminScannerScreenState extends State<AdminScannerScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  final _service = SupabaseService();
  final _code = TextEditingController();
  MobileScannerController? _camera;
  bool _cameraOn = false;
  bool _busy = false;
  String? _lastCode;

  _Result? _result;
  final List<_Result> _recent = [];

  @override
  void dispose() {
    _code.dispose();
    _camera?.dispose();
    super.dispose();
  }

  void _toggleCamera() {
    if (_cameraOn) {
      _camera?.dispose();
      _camera = null;
      setState(() => _cameraOn = false);
    } else {
      _camera = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
      setState(() => _cameraOn = true);
    }
  }

  String _extract(String raw) {
    final parts = raw.split('|');
    if (parts.length >= 3 && parts.first == 'SPORTSBOOK') return parts[1];
    return raw.trim();
  }

  Future<void> _verify(String raw, {bool fromCamera = false}) async {
    final code = _extract(raw);
    if (code.isEmpty || _busy) return;
    if (fromCamera && code == _lastCode) return;
    _lastCode = code;
    setState(() => _busy = true);
    try {
      final b = await _service.findBookingForCheckin(code);
      final res = _evaluate(code, b);
      if (!mounted) return;
      setState(() {
        _result = res;
        _recent.insert(0, res);
        if (_recent.length > 8) _recent.removeLast();
      });
    } catch (e) {
      toast('Lookup failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Decide whether the pass is valid right now.
  _Result _evaluate(String code, Map<String, dynamic>? b) {
    if (b == null)
      return _Result(
        code: code,
        ok: false,
        title: 'Pass not found',
        reason: 'No booking matches "$code" at your complexes.',
      );
    final status = '${b['status']}';
    final date = '${b['date_schedule']}';
    final today = isoDate(DateTime.now());
    final labels = '${b['time_slot']}'.split(', ');
    final slots = kSlots.where((s) => labels.contains(s.label)).toList();
    String? problem;
    if (status == 'Cancelled') {
      problem = 'This booking was cancelled.';
    } else if (date != today) {
      problem = date.compareTo(today) > 0
          ? 'Booked for a future date ($date).'
          : 'This pass expired on $date.';
    } else if (slots.isNotEmpty) {
      final now = DateTime.now();
      final start = slots.first
          .startOn(DateTime.now())
          .subtract(const Duration(minutes: 30));
      final end = slots.last.endOn(DateTime.now());
      if (now.isBefore(start)) {
        problem = 'Too early - entry opens at ${shortTime(start)}.';
      } else if (now.isAfter(end)) {
        problem = 'Session ended at ${shortTime(end)}.';
      }
    }
    final already = status == 'Checked-in';
    return _Result(
      code: code,
      booking: b,
      ok: problem == null,
      alreadyIn: already && problem == null,
      title: problem != null
          ? 'Access denied'
          : (already ? 'Already checked in' : 'Access granted'),
      reason:
          problem ??
          (already
              ? 'This player has already entered.'
              : 'Valid pass for today.'),
    );
  }

  Future<void> _checkIn(_Result r) async {
    final ref = r.booking?['booking_ref'] as String?;
    if (ref == null) return;
    try {
      await _service.setBookingStatus(ref, 'Checked-in');
      toast('Checked in ${r.booking!['court_name']}');
      setState(() {
        final updated = _Result(
          code: r.code,
          booking: {...r.booking!, 'status': 'Checked-in'},
          ok: true,
          alreadyIn: true,
          title: 'Checked in',
          reason: 'Turnstile unlocked.',
        );
        _result = updated;
        _recent[_recent.indexWhere((x) => x.code == r.code)] = updated;
      });
    } catch (e) {
      toast('Could not check in: $e');
    }
  }

  Future<void> _manualUnlock(_Result r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Manual unlock',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          r.ok
              ? 'Unlock the turnstile for ${r.booking?['booking_ref']} and check the player in?'
              : 'This pass is not valid (${r.reason}). Override and let the player in anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unlock & check in'),
          ),
        ],
      ),
    );
    if (ok == true) await _checkIn(r);
  }

  Future<void> _flagShoes(_Result r) async {
    final b = r.booking;
    if (b == null) return;
    try {
      await _service.createIncident(
        venueId: b['venue_id'] as String?,
        courtName: b['court_name'] as String?,
        category: 'Safety hazard',
        severity: 'Low',
        description:
            'Non-marking shoe check flagged at the gate for booking ${b['booking_ref']}. Player must change footwear before entering the court.',
      );
      toast('Flagged - logged in the incident desk.');
    } catch (e) {
      toast('Could not flag: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GATE CONTROL',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Scanner',
                        style: TextStyle(
                          color: ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminProfileScreen(),
                    ),
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _viewport(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => _verify(v),
                    decoration: InputDecoration(
                      hintText: 'Booking ref or 4-digit PIN',
                      prefixIcon: const Icon(Icons.keyboard_alt_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _busy ? null : () => _verify(_code.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ],
            ),
            if (r != null) ...[const SizedBox(height: 18), _resultCard(r)],
            if (_recent.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text(
                'RECENT SCANS',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final s in _recent)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onTap: () => setState(() => _result = s),
                  leading: Icon(
                    s.ok ? Icons.check_circle : Icons.cancel,
                    color: s.ok ? Colors.green : Colors.redAccent,
                  ),
                  title: Text(
                    s.booking == null
                        ? s.code
                        : '${s.booking!['booking_ref']} • ${s.booking!['court_name']}',
                    style: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    s.title,
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _viewport() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1630),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraOn && _camera != null)
            MobileScanner(
              controller: _camera!,
              onDetect: (capture) {
                final raw = capture.barcodes.isEmpty
                    ? null
                    : capture.barcodes.first.rawValue;
                if (raw != null) _verify(raw, fromCamera: true);
              },
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Camera unavailable: ${error.errorDetails?.message ?? error.errorCode.name}\nUse the code box below instead.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            )
          else
            const Center(
              child: Icon(
                Icons.qr_code_2_rounded,
                color: Colors.white24,
                size: 120,
              ),
            ),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.icon(
                onPressed: _toggleCamera,
                icon: Icon(
                  _cameraOn
                      ? Icons.stop_circle_outlined
                      : Icons.photo_camera_outlined,
                  size: 18,
                ),
                label: Text(_cameraOn ? 'Stop camera' : 'Scan with camera'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ink,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(_Result r) {
    final b = r.booking;
    final color = r.ok ? Colors.green : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                r.ok ? Icons.verified_rounded : Icons.block_rounded,
                color: color,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      r.reason,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (b != null) ...[
            const Divider(height: 24),
            _kv('Booking', '${b['booking_ref']}'),
            _kv('Venue', '${(b['venues'] as Map?)?['name'] ?? ''}'),
            _kv('Court', '${b['court_name']}'),
            _kv('Date', '${b['date_schedule']}'),
            _kv('Time', '${b['time_slot']}'),
            _kv(
              'Player',
              (b['guest_name'] as String?)?.isNotEmpty ?? false
                  ? '${b['guest_name']}'
                  : (b['user_id'] == null ? 'Guest' : 'SportsBook member'),
            ),
            _kv('Paid', 'LKR ${b['total_paid']}'),
            if (SupabaseService.bookingDueAtVenue(b))
              _kv(
                'Due at venue',
                'LKR ${SupabaseService.bookingAmountForDisplay(b).toStringAsFixed(0)}',
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (r.ok && !r.alreadyIn)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _checkIn(r),
                      icon: const Icon(Icons.how_to_reg, size: 18),
                      label: const Text('Check in'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                if (r.ok && !r.alreadyIn) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _manualUnlock(r),
                    icon: const Icon(Icons.lock_open, size: 18),
                    label: const Text('Manual unlock'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _flagShoes(r),
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: const Text('Flag non-marking shoes check'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(k, style: const TextStyle(color: muted, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(
              color: ink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Result {
  const _Result({
    required this.code,
    this.booking,
    required this.ok,
    this.alreadyIn = false,
    required this.title,
    required this.reason,
  });

  final String code;
  final Map<String, dynamic>? booking;
  final bool ok;
  final bool alreadyIn;
  final String title;
  final String reason;
}
