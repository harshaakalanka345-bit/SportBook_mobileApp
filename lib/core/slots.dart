/// The standard bookable time slots shared by the player booking flow and the owner schedule.
/// Slot labels double as the keys stored in `bookings.time_slot`, `slot_blocks.time_slot` and `slot_surges.time_slot`.
class SlotDef {
  const SlotDef(this.id, this.label, this.startHour, [this.startMinute = 0]);

  final int id;
  final String label;
  final int startHour;
  final int startMinute;

  DateTime startOn(DateTime day) => DateTime(day.year, day.month, day.day, startHour, startMinute);
  DateTime endOn(DateTime day) => startOn(day).add(const Duration(hours: 1));

  /// Base price for this slot: cheaper in the morning, standard in the afternoon, full rate in the evening.
  int priceFor(double baseRate) {
    final mult = startHour < 12 ? 0.8 : (startHour < 17 ? 0.9 : 1.0);
    return ((baseRate * mult) / 50).round() * 50;
  }
}

const kSlots = <SlotDef>[
  SlotDef(0, '06:00 - 07:00 AM', 6),
  SlotDef(1, '07:00 - 08:00 AM', 7),
  SlotDef(2, '08:00 - 09:00 AM', 8),
  SlotDef(3, '09:30 - 10:30 AM', 9, 30),
  SlotDef(4, '01:00 - 02:00 PM', 13),
  SlotDef(5, '03:00 - 04:00 PM', 15),
  SlotDef(6, '04:00 - 05:00 PM', 16),
  SlotDef(7, '06:00 - 07:00 PM', 18),
  SlotDef(8, '07:00 - 08:00 PM', 19),
  SlotDef(9, '08:00 - 09:00 PM', 20),
  SlotDef(10, '09:00 - 10:00 PM', 21),
];

String isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String shortTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
}
