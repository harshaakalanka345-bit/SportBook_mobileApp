import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F3FF);

  String _sport = 'Badminton';
  String _timeWindow = 'Evening / Floodlit (5 PM - 10 PM)';
  String _radius = '5 km';
  List<String> _surface = ['Wooden Parquet', 'Synthetic BWF Mat'];
  String _price = 'LKR 2,000 - 3,500';
  List<String> _amenities = ['Floodlights / LED Stadium Lights', 'On-premise Free Parking', 'Locker Rooms & Hot Showers'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildLocationStatus(),
                  const SizedBox(height: 20),
                  _buildSportFilter(),
                  const SizedBox(height: 20),
                  _buildDateTimeCard(),
                  const SizedBox(height: 16),
                  _buildDistanceCard(),
                  const SizedBox(height: 16),
                  _buildEnvironmentCard(),
                  const SizedBox(height: 16),
                  _buildSurfaceCard(),
                  const SizedBox(height: 16),
                  _buildPriceCard(),
                  const SizedBox(height: 16),
                  _buildAmenitiesCard(),
                  const SizedBox(height: 16),
                  _buildCoverageCard(),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: _buildResultsBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_rounded, color: _ink),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFE9EEFF)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPORTSBOOK', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                Text('Select Your Slot', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
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
            decoration: InputDecoration(
              hintText: 'Badminton in Colombo 07',
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              suffixIcon: const Icon(Icons.close_rounded, color: _muted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(onPressed: () {}, child: const Text('Reset', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildLocationStatus() {
    return Row(
      children: [
        const Icon(Icons.circle, color: AppColors.primary, size: 10),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('COLOMBO DISTRICT * LIVE\nAVAILABILITY', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const Text('7 Filters\napplied', textAlign: TextAlign.right, style: TextStyle(color: _muted, fontSize: 11)),
      ],
    );
  }

  Widget _buildSportFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SPORT CATEGORY', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.bold)),
            const Text('Racquet Sports', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min, // FIXED
            children: ['Badminton', 'Tennis', 'Squash'].map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(s),
                selected: _sport == s,
                onSelected: (v) => setState(() => _sport = s),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(color: _sport == s ? Colors.white : _muted, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _sport == s ? AppColors.primary : Colors.grey.shade300)),
                showCheckmark: true,
                checkmarkColor: Colors.white,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _ink))),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return _buildCard(
      title: 'Date & Time',
      icon: Icons.calendar_today_outlined,
      trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(10)), child: const Text('FLEXIBLE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dateBox('TODAY', '24', 'Oct', true),
              const SizedBox(width: 8),
              _dateBox('FRI', '25', 'Oct', false),
              const SizedBox(width: 8),
              _dateBox('SAT', '26', 'Oct', false),
              const SizedBox(width: 8),
              _dateBox('SUN', '27', 'Oct', false),
            ],
          ),
          const SizedBox(height: 16),
          const Text('PREFERRED TIME WINDOW', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Any time', 'Morning (6 AM - 12 PM)', 'Evening / Floodlit (5 PM - 10 PM)', 'Afternoon (12 PM - 5 PM)'].map((t) => ChoiceChip(
              label: Text(t),
              selected: _timeWindow == t,
              onSelected: (v) => setState(() => _timeWindow = t),
              selectedColor: AppColors.primary,
              backgroundColor: _softBlue,
              labelStyle: TextStyle(color: _timeWindow == t ? Colors.white : _muted, fontSize: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _dateBox(String day, String date, String month, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: selected ? AppColors.primary : _softBlue, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(day, style: TextStyle(color: selected ? Colors.white : _muted, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(date, style: TextStyle(color: selected ? Colors.white : _ink, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(month, style: TextStyle(color: selected ? Colors.white : _muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceCard() {
    return _buildCard(
      title: 'Distance Radius',
      icon: Icons.near_me_outlined,
      trailing: const Text('5 km', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
      child: Column(
        children: [
          Row(
            children: ['< 2 km', '5 km', '10 km', '15 km+'].map((r) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _radius = r),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: _radius == r ? AppColors.primary : _softBlue, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(r, style: TextStyle(color: _radius == r ? Colors.white : _muted, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Colombo 07 & Cinnamon Gardens', style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.bold)),
                      const Text('Includes Torrington, Racecourse grounds & Maitland Crescent hubs.', style: TextStyle(color: _muted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard() {
    return _buildCard(
      title: 'Court Environment',
      icon: Icons.house_outlined,
      child: Wrap(
        spacing: 10, runSpacing: 10,
        children: [
          _envBox('Indoor Court', 'Climate shielded', Icons.domain, true),
          _envBox('Outdoor Court', 'Open skies', Icons.wb_sunny, false),
          _envBox('Covered Rooftop', 'High elevation', Icons.roofing, false),
          _envBox('All Environments', 'Any arena', Icons.view_list, false),
        ],
      ),
    );
  }

  Widget _envBox(String title, String sub, IconData icon, bool selected) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: selected ? AppColors.primary : _softBlue, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: TextStyle(color: selected ? Colors.white : _ink, fontSize: 12, fontWeight: FontWeight.bold))),
              Icon(icon, color: selected ? Colors.white : Colors.orange, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: selected ? Colors.white70 : _muted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSurfaceCard() {
    return _buildCard(
      title: 'Surface Type',
      icon: Icons.layers_outlined,
      trailing: const Text('2 selected', style: TextStyle(color: AppColors.primary, fontSize: 12)),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: ['Wooden Parquet', 'Synthetic BWF Mat', 'Clay Court', 'Hard Court Acrylic', 'Natural / Turf Grass'].map((s) => ChoiceChip(
          label: Text(s),
          selected: _surface.contains(s),
          onSelected: (v) => setState(() => v ? _surface.add(s) : _surface.remove(s)),
          selectedColor: AppColors.primary,
          backgroundColor: _softBlue,
          labelStyle: TextStyle(color: _surface.contains(s) ? Colors.white : _muted, fontSize: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
          showCheckmark: true,
          checkmarkColor: Colors.white,
        )).toList(),
      ),
    );
  }

  Widget _buildPriceCard() {
    return _buildCard(
      title: 'Hourly Rate',
      icon: Icons.payments_outlined,
      trailing: const Text('LKR 1,500 - 3,500 / hr', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min, // FIXED
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _chartBar(15, false), const SizedBox(width: 4),
                _chartBar(20, false), const SizedBox(width: 4),
                _chartBar(30, false), const SizedBox(width: 4),
                _chartBar(45, true), const SizedBox(width: 4),
                _chartBar(55, true), const SizedBox(width: 4),
                _chartBar(40, true), const SizedBox(width: 4),
                _chartBar(35, true), const SizedBox(width: 4),
                _chartBar(25, false), const SizedBox(width: 4),
                _chartBar(15, false), const SizedBox(width: 4),
                _chartBar(10, false), const SizedBox(width: 4),
                _chartBar(10, false),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LKR 1,000', style: TextStyle(color: _muted, fontSize: 10)),
              Text('LKR 3,000', style: TextStyle(color: _muted, fontSize: 10)),
              Text('LKR 5,000+', style: TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Under LKR 2,000', 'LKR 2,000 - 3,500', 'Premium LKR 3,500+'].map((p) => ChoiceChip(
              label: Text(p),
              selected: _price == p,
              onSelected: (v) => setState(() => _price = p),
              selectedColor: AppColors.primary,
              backgroundColor: _softBlue,
              labelStyle: TextStyle(color: _price == p ? Colors.white : _muted, fontSize: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(double height, bool active) {
    return Container(
      width: 22, height: height,
      decoration: BoxDecoration(color: active ? AppColors.primary : const Color(0xFFDCE5FF), borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget _buildAmenitiesCard() {
    return _buildCard(
      title: 'Facilities & Amenities',
      icon: Icons.tune_rounded,
      trailing: const Text('3 ACTIVE', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
      child: Column(
        children: [
          'Floodlights / LED Stadium Lights', 'On-premise Free Parking', 'Locker Rooms & Hot Showers',
          'Air Conditioned Players Lounge', 'Racket & Grip Equipment Rental', 'Non-marking Shoe Rental Desk'
        ].map((a) => GestureDetector(
          onTap: () => setState(() => _amenities.contains(a) ? _amenities.remove(a) : _amenities.add(a)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(_amenities.contains(a) ? Icons.lightbulb : Icons.lightbulb_outline, color: _amenities.contains(a) ? AppColors.primary : _muted, size: 16),
                const SizedBox(width: 10),
                Expanded(child: Text(a, style: TextStyle(color: _ink, fontSize: 12, fontWeight: _amenities.contains(a) ? FontWeight.bold : FontWeight.normal))),
                Icon(_amenities.contains(a) ? Icons.check_circle : Icons.circle_outlined, color: _amenities.contains(a) ? AppColors.primary : const Color(0xFFDCE5FF), size: 18),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCoverageCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _softBlue,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withOpacity(0.1),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SEARCH COVERAGE', style: TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('Colombo 07 * 18 Venues Verified', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('* 18 Courts', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Ready for Oct 24 * Colombo 07', style: TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchResultsScreen()),
              );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(64, 48), // override global infinity width theme
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, // FIXED
              children: [
                Text('Show Results', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
