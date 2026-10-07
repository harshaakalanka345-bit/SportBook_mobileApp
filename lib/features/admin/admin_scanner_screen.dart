import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'admin_profile_screen.dart';
import '../notifications/notifications_screen.dart';

class AdminScannerScreen extends StatelessWidget {
  const AdminScannerScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildAppBar(),
            const SizedBox(height: 20),
            _buildGateHeader(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            _buildScannerViewport(),
            const SizedBox(height: 16),
            _buildScannerControls(),
            const SizedBox(height: 24),
            _buildAccessGrantedCard(),
            const SizedBox(height: 32),
            const Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, color: muted, size: 12),
                      SizedBox(width: 4),
                      Text('COLOMBO SPORTS AUTHORITY • SECURE OPTICAL GATE', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Floor Terminal #02 (Gate B) • FastPass v2.4.0 • Node ID:\nCSA-COL-091', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 8, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('FLOOR OPS', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
              Text('Scanner', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Builder(
          builder: (ctx) => Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                icon: const Icon(Icons.notifications_none_rounded, color: ink, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGateHeader() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.arrow_back, color: ink, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Gate Pass Sca', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(4)),
                        child: const Text('FASTPASS', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const Text('Turnstile Gate B (South) • CSA Natio...', style: TextStyle(color: muted, fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.flashlight_on_outlined, color: ink, size: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.cameraswitch_outlined, color: ink, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.circle, color: AppColors.primary, size: 6),
                SizedBox(width: 4),
                Text('Gate 02\nOnline', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.circle, color: muted, size: 4),
                SizedBox(width: 4),
                Text('Ultra-low Latency\n(12ms)', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w600)),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.lock_outline, color: AppColors.primary, size: 10),
                SizedBox(width: 4),
                Text('Auto-Sync\nActive', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.center_focus_strong_outlined, color: AppColors.primary, size: 14),
                  SizedBox(width: 6),
                  Text('Optical Viewfinder', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.dialpad, color: muted, size: 14),
                SizedBox(width: 6),
                Text('Manual Entry PIN', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerViewport() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1504450758481-7338eba7524a?q=80&w=600&auto=format&fit=crop'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // Top status bar inside scanner
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.circle, color: AppColors.primary, size: 6),
                    SizedBox(width: 6),
                    Text('SCANNING ACTIVE (30 FPS)', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Text('Flash:\nON', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF0D6EFD), borderRadius: BorderRadius.circular(12)),
                  child: const Text('AUTO-\nDETECT', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          
          // QR Frame
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30, width: 2),
              ),
              child: Stack(
                children: [
                  // Blue corners
                  Positioned(top: -2, left: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.primary, width: 4), left: BorderSide(color: AppColors.primary, width: 4))))),
                  Positioned(top: -2, right: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.primary, width: 4), right: BorderSide(color: AppColors.primary, width: 4))))),
                  Positioned(bottom: -2, left: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.primary, width: 4), left: BorderSide(color: AppColors.primary, width: 4))))),
                  Positioned(bottom: -2, right: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.primary, width: 4), right: BorderSide(color: AppColors.primary, width: 4))))),
                  
                  // Scanning Laser
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)],
                      ),
                    ),
                  ),
                  
                  // Faint QR code icon in center
                  const Center(child: Icon(Icons.qr_code_2, color: Colors.white54, size: 64)),
                ],
              ),
            ),
          ),
          
          // Bottom instructions
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.center_focus_strong, color: AppColors.primary, size: 14),
                    SizedBox(width: 8),
                    Text('Align dynamic Pass QR inside frame', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerControls() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Simulate\nScan Match', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, height: 1.2), textAlign: TextAlign.center),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          flex: 2,
          child: Text('Tap to inspect\nsheet', style: TextStyle(color: muted, fontSize: 10, height: 1.2)),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(Icons.cell_wifi, color: AppColors.primary, size: 16),
              SizedBox(width: 4),
              Text('RFID NFC Tap\nReady', style: TextStyle(color: ink, fontSize: 9, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessGrantedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: softBlue),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFE5EDFF), shape: BoxShape.circle),
                child: const Icon(Icons.verified, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Access\nGranted', style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w800, height: 1.2)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(12)),
                          child: const Text('VERIFIED', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Gate Autoclose in 7s', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ),
              const Text('Turnstile #04\nCleared', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w600, height: 1.2), textAlign: TextAlign.right),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Profile
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAF8FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: NetworkImage('https://ui-avatars.com/api/?name=Kasun+Perera&background=0D8ABC&color=fff'), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.workspace_premium, color: Colors.white, size: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Kasun Perera', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Gold Tier', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Text('Booking Ref: ', style: TextStyle(color: muted, fontSize: 10)),
                          Text('#SB-COL-8941', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
                          SizedBox(width: 4),
                          Icon(Icons.copy, color: AppColors.primary, size: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Court and Slot
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.sports_tennis, color: AppColors.primary, size: 12),
                          SizedBox(width: 4),
                          Text('COURT ASSIGN', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Court 1 (PRO)', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                      const Text('Teak Parquet Floor', style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.access_time, color: AppColors.primary, size: 12),
                          SizedBox(width: 4),
                          Text('SLOT WINDOW', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('18:00 – 20:00', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                      const Text('Starts in 6 mins', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Squad Access
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SQUAD ACCESS', style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('4 Players (All Paid)', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
                SizedBox(
                  width: 80,
                  height: 28,
                  child: Stack(
                    children: [
                      Positioned(right: 48, child: _avatar('A')),
                      Positioned(right: 24, child: _avatar('B')),
                      Positioned(right: 0, child: _avatar('C')),
                      Positioned(
                        right: -10, // Adjust overlap to fit 4 elements within width
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: const Color(0xFF0D6EFD), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Center(child: Text('+1', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Lockers
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.door_sliding_outlined, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text('Lockers #14 & #15', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800)),
                          SizedBox(width: 6),
                          Icon(Icons.circle, color: AppColors.primary, size: 4),
                          SizedBox(width: 6),
                          Text('North Bay', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Keyless BLE Auto-paired • Master\nPIN: 6420', style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.bluetooth, color: muted, size: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_open, size: 16),
              label: const Text('Manual Unlock Turnstile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.warning_amber_rounded, size: 16),
              label: const Text('Flag Non-Marking Shoes Check', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: ink,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String initial) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(image: NetworkImage('https://ui-avatars.com/api/?name=$initial&background=random&color=fff'), fit: BoxFit.cover),
      ),
    );
  }
}
