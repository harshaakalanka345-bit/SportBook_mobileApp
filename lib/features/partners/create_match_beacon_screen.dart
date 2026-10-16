import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/sports.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';

class CreateMatchBeaconScreen extends StatefulWidget {
  const CreateMatchBeaconScreen({super.key});

  @override
  State<CreateMatchBeaconScreen> createState() =>
      _CreateMatchBeaconScreenState();
}

class _CreateMatchBeaconScreenState extends State<CreateMatchBeaconScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);

  final _service = SupabaseService();
  String _sport = 'Badminton';
  String _skill = 'Intermediate';
  String? _venueId;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  late Future<List<Map<String, dynamic>>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _venuesFuture = _service.getVenues(sport: _sport);
  }

  Map<String, dynamic>? _selectedVenue(List<Map<String, dynamic>> venues) {
    for (final venue in venues) {
      if ('${venue['id']}' == _venueId) return venue;
    }
    return null;
  }

  String _dateText(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _timeText(TimeOfDay time) =>
      '${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _postRequest(Map<String, dynamic> venue) async {
    if (_date == null || _time == null) return;
    if (_service.currentUser == null) {
      toast('Sign in to post a partner request.');
      return;
    }
    final scheduled = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    setState(() => _saving = true);
    try {
      await _service.createMatchBeacon(
        sport: _sport,
        skillLevel: _skill,
        venueName: '${venue['name']}',
        scheduledTime: scheduled.toIso8601String(),
      );
      if (!mounted) return;
      toast('Partner request posted.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) toast('Could not post the partner request: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: const Text(
          'Request a Partner',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _venuesFuture,
          builder: (context, snapshot) {
            final venues = snapshot.data ?? const <Map<String, dynamic>>[];
            final venue = _selectedVenue(venues);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF5A8DFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.groups_rounded, color: Colors.white, size: 28),
                      SizedBox(height: 12),
                      Text(
                        'Find someone to play with',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Choose a sport, venue and time. Your request will appear in the partner list.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('SPORT', Icons.sports_tennis_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final sport in kSports)
                      ChoiceChip(
                        label: Text(sport),
                        selected: _sport == sport,
                        onSelected: (_) => setState(() {
                          _sport = sport;
                          _venueId = null;
                          _venuesFuture = _service.getVenues(sport: sport);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _sectionTitle('SKILL LEVEL', Icons.trending_up_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final level in const [
                      'Beginner',
                      'Intermediate',
                      'Advanced',
                    ])
                      ChoiceChip(
                        label: Text(level),
                        selected: _skill == level,
                        onSelected: (_) => setState(() => _skill = level),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _sectionTitle('VENUE', Icons.location_on_outlined),
                const SizedBox(height: 10),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator()
                else if (snapshot.hasError)
                  _infoCard(
                    'Venue list could not load. Refresh to try again.',
                    action: TextButton.icon(
                      onPressed: () => setState(() {
                        _venuesFuture = _service.getVenues(sport: _sport);
                      }),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  )
                else if (venues.isEmpty)
                  _infoCard('No $_sport venues are listed yet.')
                else
                  _venuePicker(venues, venue),
                const SizedBox(height: 22),
                _sectionTitle('DATE & TIME', Icons.calendar_month_outlined),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _pickButton(
                        Icons.calendar_today_outlined,
                        _date == null ? 'Choose date' : _dateText(_date!),
                        _pickDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _pickButton(
                        Icons.access_time_rounded,
                        _time == null ? 'Choose time' : _timeText(_time!),
                        _pickTime,
                      ),
                    ),
                  ],
                ),
                if (venue != null && _date != null && _time != null) ...[
                  const SizedBox(height: 20),
                  _infoCard(
                    '${venue['name']} • ${_dateText(_date!)} • ${_timeText(_time!)}',
                  ),
                ],
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _venuesFuture,
            builder: (context, snapshot) {
              final venue = _selectedVenue(snapshot.data ?? const []);
              final canPost =
                  venue != null && _date != null && _time != null && !_saving;
              return FilledButton.icon(
                onPressed: canPost ? () => _postRequest(venue) : null,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_saving ? 'Posting…' : 'Post partner request'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          color: _ink,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    ],
  );

  Widget _infoCard(String message, {Widget? action}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE9EEFF)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ),
        ?action,
      ],
    ),
  );

  Widget _venuePicker(
    List<Map<String, dynamic>> venues,
    Map<String, dynamic>? selected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EEFF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selected == null ? null : '${selected['id']}',
          hint: const Text('Select a venue'),
          items: [
            for (final venue in venues)
              DropdownMenuItem(
                value: '${venue['id']}',
                child: Text(
                  '${venue['name']} • ${venue['area'] ?? 'Area not listed'}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _venueId = value),
        ),
      ),
    );
  }

  Widget _pickButton(IconData icon, String label, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: Color(0xFFDCE3F4)),
        ),
      );
}
