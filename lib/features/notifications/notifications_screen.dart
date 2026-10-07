import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);
  static const border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.sports_tennis, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
            const Text('Notifications', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.flag_outlined, color: ink), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: ink), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderControls(),
            _buildTabs(),
            const SizedBox(height: 16),
            _buildSectionHeader('TODAY', '3 alerts'),
            _buildTicketNotification(),
            _buildInviteNotification(),
            _buildPromoNotification(),
            const SizedBox(height: 16),
            _buildSectionHeader('YESTERDAY', '2 alerts'),
            _buildReminderNotification(),
            _buildPaymentNotification(),
            const SizedBox(height: 16),
            _buildSectionHeader('EARLIER THIS WEEK', 'Oct 22'),
            _buildRefundNotification(),
            const SizedBox(height: 32),
            _buildFooter(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
            child: const Text('CSA PARTNER FEED', style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Text('3 New', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const Spacer(),
          const Icon(Icons.done_all, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildTab('All', ' (5)', true),
          const SizedBox(width: 8),
          _buildTab('Bookings', ' (2)', false),
          const SizedBox(width: 8),
          _buildTab('Reminders', ' (1)', false),
          const SizedBox(width: 8),
          _buildTab('Partner', '', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String count, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : border),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: isSelected ? Colors.white : ink, fontSize: 13, fontWeight: FontWeight.w700)),
          if (count.isNotEmpty)
            Text(count, style: TextStyle(color: isSelected ? Colors.white70 : muted, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: ink, letterSpacing: 0.5)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: muted)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required Widget icon,
    required String title,
    required String time,
    required Widget content,
    bool unread = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
                  child: icon,
                ),
                if (unread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink))),
                      const SizedBox(width: 8),
                      Text(time, style: const TextStyle(fontSize: 11, color: muted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  content,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketNotification() {
    return _buildNotificationCard(
      unread: true,
      icon: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 20),
      title: 'Court 3 Reserved at CSA ...',
      time: '12m ago',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today, 6:00 PM - 7:00 PM • Slot locked. Your digital pass and QR code are ready for entrance scan.', style: TextStyle(fontSize: 13, color: muted, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 14),
                    SizedBox(width: 6),
                    Text('Gate Pass ...', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Text('View Pass', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteNotification() {
    return _buildNotificationCard(
      unread: true,
      icon: const Icon(Icons.group_add_outlined, color: AppColors.primary, size: 20),
      title: 'Doubles Partner Match In...',
      time: '45m ago',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: muted, height: 1.4, fontFamily: 'Nunito'),
              children: [
                TextSpan(text: 'Kasun Silva ', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
                TextSpan(text: 'invited you to a Doubles match at Liberty Badminton Courts.'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.access_time, color: muted, size: 12),
              SizedBox(width: 4),
              Text('Tomorrow at 7:30 PM • Badminton\n(Intermediate)', style: TextStyle(fontSize: 11, color: muted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Accept', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Decline', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoNotification() {
    return _buildNotificationCard(
      unread: true,
      icon: const Icon(Icons.bolt, color: AppColors.primary, size: 20),
      title: '20% Off Indo...',
      time: '2h ago',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(4)),
                child: const Text('FLASH SALE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Royal Sports Complex opened prime slots tonight after 8:00 PM at discounted community rates.', style: TextStyle(fontSize: 13, color: muted, height: 1.4)),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text('Check Availability', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, color: AppColors.primary, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderNotification() {
    return _buildNotificationCard(
      icon: const Icon(Icons.alarm, color: muted, size: 20),
      title: 'Upcoming Match...',
      time: 'Yesterday, 6:15 PM',
      content: const Text("CSA Arena, Court 1. Don't forget your non-marking badminton shoes and spare grips.", style: TextStyle(fontSize: 13, color: muted, height: 1.4)),
    );
  }

  Widget _buildPaymentNotification() {
    return _buildNotificationCard(
      icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 20),
      title: 'Payment of LKR ...',
      time: 'Yesterday, 2:30 PM',
      content: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 13, color: muted, height: 1.4, fontFamily: 'Nunito'),
          children: [
            TextSpan(text: 'Transaction ID '),
            TextSpan(text: '#SB-89241 ', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
            TextSpan(text: 'via Commercial Bank Visa ending in 4120.'),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundNotification() {
    return _buildNotificationCard(
      icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
      title: 'Refund Credited to Wallet',
      time: 'Oct 22',
      content: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 13, color: muted, height: 1.4, fontFamily: 'Nunito'),
          children: [
            TextSpan(text: 'Weather rain-check refund: '),
            TextSpan(text: 'LKR 1,200 ', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
            TextSpan(text: 'has been deposited into your SportsBook Wallet balance.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: muted, size: 16),
            const SizedBox(width: 4),
            const Text('Clear read notifications', style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 24),
        const Text('COLOMBO SPORTS AUTHORITY PARTNER • VERSION 2.4.0', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        const Text('Encrypted Booking Receipts & Real-time Court\nSynchronization', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 10)),
      ],
    );
  }
}
