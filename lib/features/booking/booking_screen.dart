import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/mock_database.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: db.bookings.isEmpty
          ? const Center(
              child: Text(
                'No bookings yet. Checkout arrives in this tab.',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: db.bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = db.bookings[index];
                final court = db.courtById(booking.courtId);
                return Card(
                  child: ListTile(
                    title: Text(court?.name ?? booking.courtId),
                    subtitle: Text('${booking.slotLabel} · ${booking.status}'),
                  ),
                );
              },
            ),
    );
  }
}
