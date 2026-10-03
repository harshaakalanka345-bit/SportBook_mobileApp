import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'location_access_screen.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);

  final _locationController = TextEditingController(text: 'Badminton in Colombo 07');
  String _sport = 'Badminton';
  String _timeWindow = 'Evening / Floodlit (5 PM - 10 PM)';
  String _radius = '5 km';
  String _environment = 'Indoor Court';
  String _surface = 'Wooden Parquet';
  String _price = 'LKR 2,000 - 3,500';
  final _amenities = <String>{
    'Floodlights / LED Stadium Lights',
    'On-premise Free Parking',
    'Locker Rooms & Hot Showers',
  };
  final _scrollController = ScrollController();

  final _sports = const ['Badminton', 'Tennis', 'Squash', 'Paddle'];
  final _dates = const [
    ('TODAY', '24', 'Oct'),
    ('FRI', '25', 'Oct'),
    ('SAT', '26', 'Oct'),
    ('SUN', '27', 'Oct'),
  ];
  final _amenityOptions = const [
    'Floodlights / LED Stadium Lights',
    'On-premise Free Parking',
    'Locker Rooms & Hot Showers',
    'Air Conditioned Players Lounge',
    'Racket & Grip Equipment Rental',
    'Non-marking Shoe Rental Desk',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 10),
              _buildLocationStatus(),
              const SizedBox(height: 18),
              _buildSportFilter(),
              const SizedBox(height: 18),
              _buildDateTimeCard(),
              const SizedBox(height: 18),
              _buildDistanceCard(),
              const SizedBox(height: 18),
              _buildEnvironmentCard(),
              const SizedBox(height: 18),
              _buildSurfaceCard(),
              const SizedBox(height: 18),
              _buildPriceCard(),
              const SizedBox(height: 18),
              _buildAmenitiesCard(),
              const SizedBox(height: 18),
              _buildCoverageCard(),
              const SizedBox(height: 18),
              _buildResultsBar(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE9EEFF),
              foregroundColor: _ink,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 9),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 7),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPORTSBOOK', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                Text('Select Your Slot', style: TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w600, height: 1.1)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.person_outline_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _locationController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              suffixIcon: IconButton(onPressed: () => _locationController.clear(), icon: const Icon(Icons.close_rounded, size: 18)),
              hintText: 'Search courts or areas',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: _ink, fontSize: 14),
          ),
        ),
        TextButton(onPressed: _resetFilters, child: const Text('Reset', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildLocationStatus() {
    return Row(
      children: [
        const Icon(Icons.circle, color: AppColors.primary, size: 10),
        const SizedBox(width: 6),
        const Expanded(child: Text('COLOMBO DISTRICT • LIVE\nAVAILABILITY', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700, height: 1.25))),
        TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LocationAccessScreen())), child: const Text('7 Filters\napplied', textAlign: TextAlign.right, style: TextStyle(color: _muted, fontSize: 12, height: 1.2))),
      ],
    );
  }

  Widget _buildSportFilter() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('SPORT CATEGORY', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)), const Spacer(), const Text('Racquet Sports', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))]),
      const SizedBox(height: 8),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _sports.map((sport) => Padding(padding: const EdgeInsets.only(right: 8), child: _FilterChip(label: sport, selected: _sport == sport, onTap: () => setState(() => _sport = sport)))).toList())),
    ]);
  }

  Widget _buildDateTimeCard() {
    return _FilterCard(
      title: 'Date & Time',
      icon: Icons.calendar_today_outlined,
      trailing: _SmallTag(label: 'FLEXIBLE'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: _dates.asMap().entries.map((entry) => Expanded(child: Padding(padding: EdgeInsets.only(right: entry.key == _dates.length - 1 ? 0 : 6), child: _DateTile(day: entry.value.$1, date: entry.value.$2, month: entry.value.$3, selected: entry.key == 0)))).toList()),
        const SizedBox(height: 14),
        const Text('PREFERRED TIME WINDOW', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 7, runSpacing: 8, children: ['Any time', 'Morning (6 AM - 12 PM)', 'Evening / Floodlit (5 PM - 10 PM)', 'Afternoon (12 PM - 5 PM)'].map((time) => _FilterChip(label: time, selected: _timeWindow == time, onTap: () => setState(() => _timeWindow = time))).toList()),
      ]),
    );
  }

  Widget _buildDistanceCard() {
    return _FilterCard(
      title: 'Distance Radius',
      icon: Icons.near_me_outlined,
      trailing: _SmallTag(label: _radius),
      child: Column(children: [
        Row(children: ['< 2 km', '5 km', '10 km', '15 km+'].map((radius) => Expanded(child: _Segment(label: radius, selected: _radius == radius, onTap: () => setState(() => _radius = radius)))).toList()),
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(10)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.location_on_outlined, color: AppColors.primary, size: 17), SizedBox(width: 6), Expanded(child: Text('Colombo 07 & Cinnamon Gardens\nIncludes Torrington, Racecourse grounds & Maitland Crescent hubs.', style: TextStyle(color: _muted, fontSize: 12, height: 1.3)))])),
      ]),
    );
  }

  Widget _buildEnvironmentCard() {
    return _FilterCard(
      title: 'Court Environment',
      icon: Icons.house_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['Indoor Court', 'Outdoor Court', 'Covered Rooftop', 'All Environments'].map((environment) {
          final subtitle = environment == 'Indoor Court'
              ? 'Climate shielded'
              : environment == 'Outdoor Court'
                  ? 'Open skies'
                  : environment == 'Covered Rooftop'
                      ? 'High elevation'
                      : 'Any arena';
          return SizedBox(
            width: 150,
            height: 54,
            child: _OptionTile(
              label: environment,
              subtitle: subtitle,
              selected: _environment == environment,
              onTap: () => setState(() => _environment = environment),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSurfaceCard() {
    return _FilterCard(title: 'Surface Type', icon: Icons.layers_outlined, trailing: Text('${_surface == 'Wooden Parquet' ? 2 : 1} selected', style: const TextStyle(color: AppColors.primary, fontSize: 12)), child: Wrap(spacing: 8, runSpacing: 8, children: ['Wooden Parquet', 'Synthetic BWF Mat', 'Clay Court', 'Hard Court Acrylic', 'Natural / Turf Grass'].map((surface) => _FilterChip(label: surface, selected: _surface == surface, onTap: () => setState(() => _surface = surface))).toList()));
  }

  Widget _buildPriceCard() {
    return _FilterCard(title: 'Hourly Rate', icon: Icons.payments_outlined, trailing: Text(_price, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w600)), child: Column(children: [
      SizedBox(width: double.infinity, height: 72, child: CustomPaint(painter: _RateChartPainter(), child: const SizedBox.expand())),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('LKR 1,000', style: TextStyle(color: _muted, fontSize: 10)), Text('LKR 3,000', style: TextStyle(color: _muted, fontSize: 10)), Text('LKR 5,000+', style: TextStyle(color: _muted, fontSize: 10))]),
      const SizedBox(height: 12),
      Wrap(spacing: 7, children: ['Under LKR 2,000', 'LKR 2,000 - 3,500', 'Premium LKR 3,500+'].map((price) => _FilterChip(label: price, selected: _price == price, onTap: () => setState(() => _price = price))).toList()),
    ]));
  }

  Widget _buildAmenitiesCard() {
    return _FilterCard(
      title: 'Facilities & Amenities',
      icon: Icons.tune_rounded,
      trailing: Text('${_amenities.length} ACTIVE', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
      child: Column(
        children: _amenityOptions.map((amenity) => _AmenityRow(
          label: amenity,
          selected: _amenities.contains(amenity),
          onTap: () => setState(() {
            if (_amenities.contains(amenity)) {
              _amenities.remove(amenity);
            } else {
              _amenities.add(amenity);
            }
          }),
        )).toList(),
      ),
    );
  }

  Widget _buildCoverageCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('https://tile.openstreetmap.org/13/7480/4962.png', fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFFBDE3EA))),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xB0002344)]))),
            const Positioned(left: 14, bottom: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SEARCH COVERAGE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)), Text('Colombo 07 • 18 Venues Verified', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))])),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x18001844), blurRadius: 12, offset: Offset(0, -4))]),
      child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('● 18 Courts', style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w700)), Text('Ready for Oct 24 • Colombo 07', style: TextStyle(color: _muted, fontSize: 12))])), FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchResultsScreen())), icon: const Text('Show Results'), label: const Icon(Icons.arrow_forward_rounded, size: 19), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13)))],),
    );
  }

  void _resetFilters() {
    setState(() {
      _sport = 'Badminton';
      _timeWindow = 'Evening / Floodlit (5 PM - 10 PM)';
      _radius = '5 km';
      _environment = 'Indoor Court';
      _surface = 'Wooden Parquet';
      _price = 'LKR 2,000 - 3,500';
      _amenities
        ..clear()
        ..addAll(['Floodlights / LED Stadium Lights', 'On-premise Free Parking', 'Locker Rooms & Hot Showers']);
    });
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.title, required this.icon, required this.child, this.trailing});

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 6), Text(title, style: const TextStyle(color: _SearchScreenState._ink, fontSize: 18, fontWeight: FontWeight.w600)), const Spacer(), ?trailing]), const SizedBox(height: 13), child]));
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: selected ? AppColors.primary : _SearchScreenState._softBlue, borderRadius: BorderRadius.circular(22), boxShadow: selected ? const [BoxShadow(color: Color(0x250066FF), blurRadius: 8, offset: Offset(0, 4))] : null), child: Text(label, style: TextStyle(color: selected ? Colors.white : _SearchScreenState._muted, fontSize: 13, fontWeight: FontWeight.w500))));
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.day, required this.date, required this.month, required this.selected});

  final String day;
  final String date;
  final String month;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: selected ? AppColors.primary : _SearchScreenState._softBlue, borderRadius: BorderRadius.circular(9)), child: Column(children: [Text(day, style: TextStyle(color: selected ? Colors.white : _SearchScreenState._muted, fontSize: 10, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(date, style: TextStyle(color: selected ? Colors.white : _SearchScreenState._ink, fontSize: 18, fontWeight: FontWeight.w600)), Text(month, style: TextStyle(color: selected ? Colors.white : _SearchScreenState._muted, fontSize: 10))]));
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: _SearchScreenState._softBlue, borderRadius: BorderRadius.circular(15)), child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)));
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : _SearchScreenState._softBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : _SearchScreenState._muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.subtitle, required this.selected, required this.onTap});

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected ? AppColors.primary : _SearchScreenState._softBlue, borderRadius: BorderRadius.circular(11)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? Colors.white : _SearchScreenState._ink, fontSize: 12, fontWeight: FontWeight.w600)), Text(subtitle, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? Colors.white70 : _SearchScreenState._muted, fontSize: 10))])));
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8), decoration: BoxDecoration(color: _SearchScreenState._softBlue, borderRadius: BorderRadius.circular(8)), child: Row(children: [Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFFDCE6FF), shape: BoxShape.circle), child: Icon(Icons.circle_outlined, color: selected ? AppColors.primary : _SearchScreenState._muted, size: 16)), const SizedBox(width: 8), Expanded(child: Text(label, style: const TextStyle(color: _SearchScreenState._ink, fontSize: 12))), Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? AppColors.primary : const Color(0xFFD5DBEE), size: 18)])));
}

class _RateChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = const Color(0xFFDCE5FF);
    final barPaint = Paint()..color = AppColors.primary;
    final lightPaint = Paint()..color = const Color(0xFF9DBAE8);
    const widths = <double>[22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22];
    const heights = <double>[10, 18, 32, 53, 43, 58, 40, 28, 18, 11, 8, 6];
    var x = 2.0;
    for (var index = 0; index < widths.length; index++) {
      final paint = index >= 3 && index <= 7 ? barPaint : index == 2 || index == 8 ? lightPaint : basePaint;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - heights[index] - 10, widths[index] - 4, heights[index]), const Radius.circular(4)), paint);
      x += widths[index] + 2;
    }
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, size.height - 7, size.width, 5), const Radius.circular(3)), basePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height - 7, size.width * 0.55, 5), const Radius.circular(3)), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
