import 'package:flutter/material.dart';

import '../features/booking/booking_screen.dart';
import '../features/discovery/dashboard_screen.dart';
import '../features/discovery/search_screen.dart';
import '../features/partners/partners_screen.dart';
import 'app_theme.dart';
import '../features/auth/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  static final ValueNotifier<int?> _tabRequest = ValueNotifier<int?>(null);

  static void selectTab(int index) => _tabRequest.value = index;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    MainWrapper._tabRequest.addListener(_applyTabRequest);
  }

  @override
  void dispose() {
    MainWrapper._tabRequest.removeListener(_applyTabRequest);
    super.dispose();
  }

  void _applyTabRequest() {
    final requestedIndex = MainWrapper._tabRequest.value;
    if (requestedIndex == null) return;
    MainWrapper._tabRequest.value = null;
    if (requestedIndex < 0 || requestedIndex >= _tabs.length) return;
    if (mounted) setState(() => _index = requestedIndex);
  }

  static const _tabs = [
    DashboardScreen(),
    SearchScreen(),
    BookingScreen(),
    PartnersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Courts',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Partners',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      backgroundColor: AppColors.surfaceMuted,
    );
  }
}
