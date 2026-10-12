import 'package:flutter/material.dart';

/// Help centre content. Kept in one place so the FAQ list and the Rules & Help screen stay consistent
/// with how the app actually behaves (booking, cancellation, refunds, passes).
class FaqEntry {
  const FaqEntry(this.icon, this.question, this.answer);

  final IconData icon;
  final String question;
  final String answer;
}

const faqs = <FaqEntry>[
  FaqEntry(
    Icons.event_busy_outlined,
    'Court Cancellations & Refund Policy',
    'You can cancel free of charge up to 2 hours before your slot starts: open Bookings, tap Cancel and choose a refund destination.\n\n'
        '• Refund to SportsBook Wallet - credited instantly.\n'
        '• Refund to your card - arrives in 2-3 business days.\n\n'
        'Cancellations inside the 2-hour window, or no-shows, are not refunded. You can reschedule once for free using Modify Slot, as long as the new slot is available.',
  ),
  FaqEntry(
    Icons.do_not_step_outlined,
    'Non-Marking Shoe Requirements',
    'Indoor courts (badminton, futsal, basketball, table tennis) require clean, non-marking soles. Outdoor sneakers and black-soled shoes are not allowed on timber or synthetic floors.\n\n'
        'You can add non-marking court shoes as a rental at checkout. Staff may ask you to change shoes before you enter the court.',
  ),
  FaqEntry(
    Icons.people_outline,
    'Split Payment with Teammates',
    'At checkout, switch on "Split with Friends" to divide the total equally between four players. As the host you pay your share to confirm the booking; the other players receive their payment links by message.\n\n'
        'If a teammate does not pay, the host remains responsible for the unpaid share.',
  ),
  FaqEntry(
    Icons.thunderstorm_outlined,
    'Bad Weather & Outdoor Rain Guarantee',
    'If an outdoor court is closed by the venue because of rain or unsafe conditions, your booking is cancelled and the full amount is refunded to your SportsBook Wallet automatically. Indoor bookings are not affected by weather.\n\n'
        'You can turn weather alerts on or off in Profile > Preferences & Security.',
  ),
  FaqEntry(
    Icons.qr_code_scanner_rounded,
    'Digital Match Pass & Gate Scanners',
    'After booking, open Bookings > View Pass & QR Code. Show the QR code at the gate scanner to check in. If the scanner is not working, give the reception desk the 4-digit PIN shown under the QR code.\n\n'
        'The pass works only for the booked court and time, and is cancelled automatically if you cancel the booking.',
  ),
  FaqEntry(
    Icons.account_balance_wallet_outlined,
    'Wallet, Top-ups & Saved Cards',
    'Add money to your wallet from Profile > Payment & Credits > Top Up. Wallet credit can be used for any booking. You can save cards in the same section; only the brand, last four digits and expiry are stored - never your full card number or CVV.',
  ),
  FaqEntry(
    Icons.report_problem_outlined,
    'Reporting a Problem at a Venue',
    'Use "Report a Fault" on this page to tell the venue manager about damaged courts, lighting, safety hazards or injuries. Choose High severity for anything that makes play unsafe. You can follow the status of your reports at the bottom of the report screen.',
  ),
];

class RuleSection {
  const RuleSection(this.icon, this.title, this.items);

  final IconData icon;
  final String title;
  final List<String> items;
}

const ruleSections = <RuleSection>[
  RuleSection(Icons.event_available_outlined, 'Booking rules', [
    'A booking is confirmed once payment (or the counter deposit) is completed and you receive your match pass.',
    'Slots are held for you from the booked start time. Please arrive 10 minutes early to check in.',
    'You may extend your session on the day only if the next slot on that court is free.',
    'Maximum booking length is 3 hours per court per day to keep courts available for everyone.',
  ]),
  RuleSection(Icons.currency_exchange, 'Cancellations & refunds', [
    'Free cancellation until 2 hours before the slot starts.',
    'Wallet refunds are instant. Card refunds take 2-3 business days.',
    'One free reschedule per booking, subject to availability.',
    'Venue-initiated closures (maintenance, weather) are always refunded in full.',
  ]),
  RuleSection(Icons.sports_tennis_rounded, 'On the court', [
    'Wear clean, non-marking shoes on indoor courts.',
    'Only booked players may use the court. Spectators should stay in the seating area.',
    'Leave the court on time so the next group can start promptly.',
    'Report any damage or hazard immediately using Report a Fault.',
  ]),
  RuleSection(Icons.health_and_safety_outlined, 'Safety & conduct', [
    'Treat staff, other players and equipment with respect. Abusive behaviour can lead to a ban.',
    'Do not play if you feel unwell. Tell the venue desk about any injury straight away.',
    'Glass bottles, food and smoking are not allowed on the court surface.',
    'Children under 12 must be accompanied by an adult.',
  ]),
  RuleSection(Icons.lock_outline_rounded, 'Account & payments', [
    'Keep your password private. SportsBook staff will never ask for it or for your full card number.',
    'Gate passes are personal to the booking; sharing the PIN with outsiders is not permitted.',
    'Delete your account any time from Profile. This removes your saved cards and preferences.',
  ]),
];

class HelpGuide {
  const HelpGuide(this.title, this.steps);

  final String title;
  final List<String> steps;
}

const helpGuides = <HelpGuide>[
  HelpGuide('How to book a court', [
    'Open Courts or Search and pick a venue.',
    'Tap Book Court Now, then choose the date, court, duration and time slot.',
    'Review add-ons and the price on the checkout page, then pay.',
    'Your match pass appears in Bookings.',
  ]),
  HelpGuide('How to change or cancel a booking', [
    'Go to Bookings and find your upcoming booking.',
    'Tap Modify Slot to pick a new time, or Cancel to cancel and choose a refund method.',
  ]),
  HelpGuide('How to find a playing partner', [
    'Open Partners and tap Request a Partner.',
    'Choose the sport, format, skill level and time, then broadcast your beacon.',
    'Share the beacon with friends, or browse beacons from other players.',
  ]),
  HelpGuide('How to report a problem', [
    'Open Help & Support and tap Submit Report (or the flag icon).',
    'Pick the venue, what happened, how urgent it is, and add a photo if you can.',
    'The venue manager is notified and you can track the status in the same screen.',
  ]),
];
