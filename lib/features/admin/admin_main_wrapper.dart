import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_scanner_screen.dart';
import 'admin_schedule_screen.dart';
import 'admin_incidents_screen.dart';
import 'admin_ledger_screen.dart';

class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});

  @override
  State<AdminMainWrapper> createState() => _AdminMainWrapperState();
}

class _AdminMainWrapperState extends State<AdminMainWrapper> {
  int _index = 0;

  static const _tabs = [
    AdminDashboardScreen(),
    AdminScannerScreen(),
    AdminScheduleScreen(),
    AdminIncidentsScreen(),
    AdminLedgerScreen(),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Floor Ops',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_rounded),
            label: 'Incidents',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Ledger',
          ),
        ],
      ),
      backgroundColor: AppColors.surfaceMuted,
    );
  }
}
