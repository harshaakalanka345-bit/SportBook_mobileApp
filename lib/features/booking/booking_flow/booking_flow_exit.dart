import 'package:flutter/material.dart';

/// Confirms abandoning an in-progress booking and returns to the app root.
Future<void> closeBookingFlow(BuildContext context) async {
  final leave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Close booking flow?'),
      content: const Text('Your current slot selection and checkout details will be discarded.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Keep booking')),
        FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Close')),
      ],
    ),
  );
  if (leave == true && context.mounted) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
