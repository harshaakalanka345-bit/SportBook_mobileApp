/// In-memory state shared by the 4-step booking flow (slot -> checkout -> payment -> confirmation).
class BookingDraft {
  static Map<String, dynamic>? venue;
  static String courtName = 'Court 1';
  static String courtType = '';
  static DateTime date = DateTime.now();
  static List<String> slotLabels = [];
  static String timeRange = '';
  static DateTime? startAt;
  static DateTime? endAt;
  static double hours = 1;

  static double courtFee = 0;
  static double gearFee = 0;
  static double discount = 0;
  static double tax = 0;
  static double total = 0;
  static double share = 0;
  static String gearLabel = '';

  static String paymentLabel = 'Card';
  static String addonsLabel = '';
  static String? bookingRef;
  static String? pin;

  static void start({
    required Map<String, dynamic>? venue,
    required String courtName,
    required String courtType,
    required DateTime date,
    required List<String> slotLabels,
    required String timeRange,
    required double hours,
    required double courtFee,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    BookingDraft.startAt = startAt;
    BookingDraft.endAt = endAt;
    BookingDraft.venue = venue;
    BookingDraft.courtName = courtName;
    BookingDraft.courtType = courtType;
    BookingDraft.date = date;
    BookingDraft.slotLabels = slotLabels;
    BookingDraft.timeRange = timeRange;
    BookingDraft.hours = hours;
    BookingDraft.courtFee = courtFee;
    gearFee = discount = tax = total = share = 0;
    gearLabel = '';
    bookingRef = pin = null;
  }

  static void setCheckout({
    required double gearFee,
    required double discount,
    required double tax,
    required double total,
    required double share,
    required String gearLabel,
  }) {
    BookingDraft.gearFee = gearFee;
    BookingDraft.discount = discount;
    BookingDraft.tax = tax;
    BookingDraft.total = total;
    BookingDraft.share = share;
    BookingDraft.gearLabel = gearLabel;
    addonsLabel = gearLabel == 'No gear selected' ? '' : gearLabel;
  }

  static String get venueName => (venue?['name'] as String?) ?? 'Sports Venue';
  static String get venueArea => (venue?['address'] as String?) ?? (venue?['area'] as String?) ?? '';
  static String get sport => (venue?['sport'] as String?) ?? 'Badminton';
  static String get dateIso => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String get dateLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String money(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    return '${parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}.${parts[1]}';
  }
}
