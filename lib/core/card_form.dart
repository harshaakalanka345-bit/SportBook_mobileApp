import 'package:flutter/material.dart';

import 'app_theme.dart';

class CardDetails {
  const CardDetails({required this.brand, required this.last4, required this.holder, required this.expiry});

  final String brand;
  final String last4;
  final String holder;
  final String expiry;
}

bool _luhn(String digits) {
  var sum = 0;
  var alt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.parse(digits[i]);
    if (alt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alt = !alt;
  }
  return sum % 10 == 0;
}

String _brandOf(String digits) {
  if (digits.startsWith('4')) return 'Visa';
  if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) return 'Mastercard';
  if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
  return 'Card';
}

/// Bottom sheet that collects and validates card details. Returns only display details
/// (brand, last 4, holder, expiry) - the full number and CVV are never kept.
Future<CardDetails?> showAddCardSheet(BuildContext context) async {
  final number = TextEditingController();
  final name = TextEditingController();
  final exp = TextEditingController();
  final cvv = TextEditingController();
  final formKey = GlobalKey<FormState>();
  const ink = Color(0xFF11182D);

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Credit / Debit Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
              const SizedBox(height: 16),
              TextFormField(
                controller: number,
                keyboardType: TextInputType.number,
                maxLength: 19,
                decoration: const InputDecoration(labelText: 'Card number', counterText: ''),
                validator: (v) {
                  final d = (v ?? '').replaceAll(RegExp(r'\s'), '');
                  return (d.length >= 13 && d.length <= 19 && RegExp(r'^\d+$').hasMatch(d) && _luhn(d)) ? null : 'Enter a valid card number';
                },
              ),
              TextFormField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name on card'),
                validator: (v) => (v ?? '').trim().length < 2 ? 'Enter the cardholder name' : null,
              ),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: exp,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', counterText: ''),
                    validator: (v) {
                      final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch((v ?? '').trim());
                      if (m == null) return 'Use MM/YY';
                      final month = int.parse(m.group(1)!);
                      final year = 2000 + int.parse(m.group(2)!);
                      if (month < 1 || month > 12) return 'Invalid month';
                      if (DateTime(year, month + 1).isBefore(DateTime.now())) return 'Card expired';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: cvv,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(labelText: 'CVV', counterText: ''),
                    validator: (v) => RegExp(r'^\d{3,4}$').hasMatch((v ?? '').trim()) ? null : 'Invalid CVV',
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save card'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  CardDetails? result;
  if (ok == true) {
    final digits = number.text.replaceAll(RegExp(r'\s'), '');
    result = CardDetails(brand: _brandOf(digits), last4: digits.substring(digits.length - 4), holder: name.text.trim(), expiry: exp.text.trim());
  }
  for (final c in [number, name, exp, cvv]) {
    c.dispose();
  }
  return result;
}
