import 'package:flutter/material.dart';

Future<void> showBookingStepPopup(BuildContext context, Widget step) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return Dialog(
        insetPadding: const EdgeInsets.all(18),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size.width > 820 ? 780 : size.width - 36,
          height: size.height > 900 ? 820 : size.height - 36,
          child: step,
        ),
      );
    },
  );
}
