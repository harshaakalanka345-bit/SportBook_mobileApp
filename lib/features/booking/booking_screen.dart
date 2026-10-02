import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _service = SupabaseService();

  Future<List<Map<String, dynamic>>> _loadBookings() =>
      _service.getUserBookings();

  void _showQrPass(Map<String, dynamic> booking) {
    final ref = booking['booking_ref'] ?? 'REF';
    final pin = booking['qr_turnstile_pin'] ?? '1234';
    final court = booking['court_name'] ?? 'Court';
    final slot = booking['time_slot'] ?? '';
    final date = booking['date_schedule'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        title: const Text('Turnstile Entry Pass', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(court,
                style: const TextStyle(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('$date · $slot',
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              height: 180,
              child: QrImageView(
                data: 'SPORTSBOOK:$ref:PIN:$pin',
                version: QrVersions.auto,
                size: 180,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'PIN: $pin',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text('Ref: $ref',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> booking) {
    final ref = booking['booking_ref'];
    if (ref == null) return;

    final slotController =
        TextEditingController(text: '07:00 PM - 08:00 PM');
    final dateController = TextEditingController(
      text: DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0],
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'New Date (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slotController,
              decoration: const InputDecoration(labelText: 'New Time Slot'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _service.rescheduleBooking(
                  ref,
                  slotController.text.trim(),
                  dateController.text.trim(),
                );
                if (!mounted) return;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking rescheduled successfully!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reschedule error: $e')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(String ref) async {
    try {
      await _service.cancelBooking(ref);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancellation error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error loading bookings: ${snapshot.error}'),
                ),
              );
            }

            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No bookings yet.\nBook a court from the Discover tab!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final ref = b['booking_ref'] ?? 'REF';
                final court = b['court_name'] ?? 'Court';
                final status = b['status'] ?? 'Confirmed';
                final date = b['date_schedule'] ?? '';
                final slot = b['time_slot'] ?? '';
                final totalPaid = b['total_paid'] ?? 0;

                final isCancelled = status == 'Cancelled';
                final statusColor = status == 'Confirmed'
                    ? Colors.green
                    : status == 'Rescheduled'
                        ? Colors.orange
                        : Colors.red;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                court,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ref: $ref · LKR $totalPaid',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$date | $slot',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.qr_code, size: 18),
                                label: const Text('Pass'),
                                onPressed: () => _showQrPass(b),
                              ),
                            ),
                            if (!isCancelled) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.schedule, size: 18),
                                  label: const Text('Reschedule'),
                                  onPressed: () => _showRescheduleDialog(b),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined,
                                    color: Colors.redAccent),
                                tooltip: 'Cancel Booking',
                                onPressed: () => _cancelBooking(ref),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
