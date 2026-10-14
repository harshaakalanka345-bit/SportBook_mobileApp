import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../auth/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../core/supabase_service.dart';
import 'create_match_beacon_screen.dart';
import '../../core/actions.dart';
import '../../core/toast.dart';
import 'all_beacons_screen.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF697083);
  static const _softBlue = Color(0xFFF0F2FF);

  final _service = SupabaseService();
  final _search = TextEditingController();
  late Future<List<Map<String, dynamic>>> _beacons;
  late Future<List<Map<String, dynamic>>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _beacons = _service.getMatchBeacons();
    _friendsFuture = _service.getFriends();
  }

  void _reloadFriends() => setState(() => _friendsFuture = _service.getFriends());

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    final name = TextEditingController();
    final contact = TextEditingController();
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Friend', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Form(
          key: key,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null),
            TextFormField(
              controller: contact,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email or phone'),
              validator: (v) {
                final s = (v ?? '').trim();
                final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                final isPhone = RegExp(r'^\+?[0-9 ]{9,15}$').hasMatch(s);
                return (isEmail || isPhone) ? null : 'Enter a valid email or phone number';
              },
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () { if (key.currentState!.validate()) Navigator.pop(ctx, true); }, child: const Text('Add')),
        ],
      ),
    );
    final n = name.text.trim();
    final c = contact.text.trim();
    name.dispose();
    contact.dispose();
    if (ok != true) return;
    try {
      await _service.addFriend(name: n, contact: c);
      _reloadFriends();
      toast('$n added to your friends');
    } catch (e) {
      toast('Could not add friend: $e');
    }
  }

  Widget _realFriendCard(Map<String, dynamic> f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: _softBlue, child: Text('${f['friend_name']}'.isEmpty ? '?' : '${f['friend_name']}'[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${f['friend_name']}', style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
          Text('${f['friend_contact']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12)),
        ])),
        FilledButton(
          onPressed: _showCreateBeaconSheet,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 14)),
          child: const Text('Invite', style: TextStyle(fontSize: 12)),
        ),
        IconButton(
          tooltip: 'Remove',
          onPressed: () async {
            await _service.removeFriend('${f['id']}');
            _reloadFriends();
          },
          icon: const Icon(Icons.close_rounded, color: _muted, size: 18),
        ),
      ]),
    );
  }

  Widget _beaconCard(Map<String, dynamic> b) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFDCE6FF), borderRadius: BorderRadius.circular(12)),
            child: Text('${b['sport']}'.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Text('${b['skill_level']}', style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 14),
        Text('${b['venue_name']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(child: Text('${b['scheduled_time']}', style: const TextStyle(color: _muted, fontSize: 13))),
        ]),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => shareText('Match beacon: ${b['sport']} (${b['skill_level']}) at ${b['venue_name']}, ${b['scheduled_time']}. Join me on SportsBook!'),
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Share Beacon'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
          ),
        ),
      ]),
    );
  }

  String _sport = 'Badminton';
  String _format = 'Competitive';

  final _friends = const [
    ('Kasun Jayasuriya', 'Badminton  •  Online • Free from 6:30 PM', 'Played 3 days ago at CSA Arena', 'Level 4.2', 'Invite to Match', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=160&q=80'),
    ('Sahan Perera', 'Tennis & Badminton  •  Playing at Otters AC', 'Otters AC regular • 14 mutual matches', 'Level 4.0', 'Join / Challenge', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=160&q=80'),
    ('Dilhara Senanayake', 'Badminton  •  Looking for Doubles partner', 'Your regular partner • Won last 4 matches', 'Level 5.0', 'Invite to Squad', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=160&q=80'),
    ('Nadeeka Fernando', 'Badminton  •  Offline • Last active 2h ago', 'Played last week at Sugathadasa', 'Level 3.8', 'Ping / Challenge', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=160&q=80'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              _buildHero(),
              const SizedBox(height: 14),
              _buildSearch(),
              const SizedBox(height: 12),
              _buildSportFilters(),
              const SizedBox(height: 10),
              _buildFormatFilters(),
              const SizedBox(height: 18),
              _buildMatchHubs(),
              const SizedBox(height: 22),
              _buildFriends(),
              const SizedBox(height: 22),
              _buildClubs(),
              const SizedBox(height: 22),
              const _PartnersFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 23)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE6ECFF), borderRadius: BorderRadius.circular(16)), child: const Text('SPORTSBOOK', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4))),
        const SizedBox(width: 7),
        const Expanded(child: Text('Find Partners', style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w700))),
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none_rounded, color: _muted)),
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), child: Container(width: 38, height: 38, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 21))),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(17), boxShadow: const [BoxShadow(color: Color(0x300066FF), blurRadius: 12, offset: Offset(0, 7))]),
      child: Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(18)), child: const Text('⚡ Instant\nMatchmaker', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, height: 1.1))), const SizedBox(width: 10), const Text('Colombo 07 • Active\nNow', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 14),
            const Text('Need a Partner Tonight?', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            const Text('Looking for someone to play at 7:00 PM?\nBroadcast a rally or match beacon to 120+\nlocal athletes.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.35)),
            const SizedBox(height: 14),
            FilledButton.icon(onPressed: _showCreateBeaconSheet, icon: const Icon(Icons.add_circle_outline, size: 20), label: const Text('Request a Partner'), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          ]),
          const Positioned(right: 0, bottom: 2, child: Icon(Icons.radar_rounded, color: Colors.white24, size: 112)),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded, color: _muted),
        hintText: 'Search by name, skill, or venue',
        suffixIcon: _search.text.isEmpty
            ? Container(margin: const EdgeInsets.all(7), padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.navigation_rounded, color: AppColors.primary, size: 17), SizedBox(width: 4), Text('Col 07', style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w600))]))
            : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(_search.clear)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSportFilters() {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Badminton', 'Tennis', 'Squash', 'Paddle'].map((sport) => Padding(padding: const EdgeInsets.only(right: 8), child: _Pill(label: sport, selected: _sport == sport, icon: sport == 'Tennis' ? Icons.sports_tennis_rounded : sport == 'Squash' ? Icons.sports_handball_rounded : Icons.sports_tennis_rounded, onTap: () => setState(() => _sport = sport)))).toList()));
  }

  Widget _buildFormatFilters() {
    return Row(
      children: [
        const Text('FORMAT:', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Competitive', 'Casual Rally', 'Doubles Partner'].map((format) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Pill(label: format, selected: _format == format, onTap: () => setState(() => _format = format)),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchHubs() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _beacons,
        builder: (context, snap) {
          final all = snap.data ?? [];
          return Row(children: [
            const Text('Live Match Hubs', style: TextStyle(color: _ink, fontSize: 22, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllBeaconsScreen())),
              child: Text('View All (${all.length})', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ]);
        },
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 190,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _beacons,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Center(child: Text('Could not load match hubs: ${snap.error}', style: const TextStyle(color: _muted)));
            final q = _search.text.trim().toLowerCase();
            final all = (snap.data ?? []).where((b) {
              if (_sport != 'All' && '${b['sport']}' != _sport) return false;
              if (q.isEmpty) return true;
              return '${b['sport']} ${b['skill_level']} ${b['venue_name']} ${b['scheduled_time']}'.toLowerCase().contains(q);
            }).toList();
            if (all.isEmpty) return Center(child: Text('No $_sport beacons yet. Tap "Request a Partner" to start one.', textAlign: TextAlign.center, style: const TextStyle(color: _muted)));
            return ListView(scrollDirection: Axis.horizontal, children: [for (final b in all) _beaconCard(b)]);
          },
        ),
      ),
    ]);
  }

  Widget _buildFriends() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('My Friends', style: TextStyle(color: _ink, fontSize: 22, fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton.icon(onPressed: _addFriend, icon: const Icon(Icons.person_add_alt_1_outlined, size: 17), label: const Text('Add Friend')),
      ]),
      const Text('Connect and schedule matches with your\nclose circle', style: TextStyle(color: _muted, fontSize: 14, height: 1.3)),
      const SizedBox(height: 10),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _friendsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
          if (snap.hasError) return Text('Could not load friends: ${snap.error}', style: const TextStyle(color: _muted));
          final q = _search.text.trim().toLowerCase();
          final list = (snap.data ?? []).where((f) {
            if (q.isEmpty) return true;
            return '${f['friend_name']} ${f['friend_contact']}'.toLowerCase().contains(q);
          }).toList();
          if (list.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No friends yet. Tap "Add Friend" to build your squad.', style: TextStyle(color: _muted)));
          return Column(children: [for (final f in list) _realFriendCard(f)]);
        },
      ),
    ]);
  }

  Widget _friendCard((String, String, String, String, String, String) friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(children: [
            CircleAvatar(radius: 25, backgroundImage: NetworkImage(friend.$6), onBackgroundImageError: (_, _) {}),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(friend.$1, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(friend.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(friend.$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12))])),
            _SmallLevel(label: friend.$4),
          ]),
          const SizedBox(height: 11),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: () => _showMessage('${friend.$5} sent to ${friend.$1}'), icon: const Icon(Icons.sports_tennis_rounded, size: 18), label: Text(friend.$5), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 11), textStyle: const TextStyle(fontSize: 13)))),
            const SizedBox(width: 8),
            IconButton(onPressed: () => _showMessage('Chat with ${friend.$1}'), style: IconButton.styleFrom(backgroundColor: _softBlue), icon: const Icon(Icons.chat_bubble_outline_rounded, color: _muted, size: 20)),
          ]),
        ],
      ),
    );
  }

  Widget _buildClubs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Active Racket Clubs', style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('Join localized training & round-robin groups', style: TextStyle(color: _muted, fontSize: 13))]), const Spacer(), const Icon(Icons.groups_rounded, color: AppColors.primary, size: 27)]),
        const SizedBox(height: 14),
        _clubRow('Colombo Smashers Club', '142 members • 8 matches this week'),
        const SizedBox(height: 8),
        _clubRow('Lanka Rackets Community', '98 members • Reid Ave weekend'),
      ]),
    );
  }

  Widget _clubRow(String title, String detail) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 38, height: 38, decoration: const BoxDecoration(color: Color(0xFFDCE6FF), shape: BoxShape.circle), child: const Icon(Icons.flag_outlined, color: AppColors.primary, size: 19)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w700)), Text(detail, style: const TextStyle(color: _muted, fontSize: 12))])), TextButton(onPressed: () => _showMessage('Joined $title'), style: TextButton.styleFrom(backgroundColor: _softBlue, shape: const StadiumBorder()), child: const Text('Join'))]));
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  void _showCreateBeaconSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateMatchBeaconScreen()),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap, this.selected = false, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: selected ? const [BoxShadow(color: Color(0x270066FF), blurRadius: 8, offset: Offset(0, 4))] : null), child: Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) Icon(icon, color: selected ? Colors.white : _PartnersColors.muted, size: 17), if (icon != null) const SizedBox(width: 5), Text(label, style: TextStyle(color: selected ? Colors.white : _PartnersColors.muted, fontSize: 13, fontWeight: FontWeight.w600))])));
}

class _SmallLevel extends StatelessWidget {
  const _SmallLevel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFDCE6FF), borderRadius: BorderRadius.circular(12)), child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)));
}

class _MatchHubCard extends StatelessWidget {
  const _MatchHubCard({this.single = false});

  final bool single;

  @override
  Widget build(BuildContext context) => Container(width: 305, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFDCE6FF), borderRadius: BorderRadius.circular(12)), child: Text(single ? 'SINGLES' : 'DOUBLES', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700))), const Spacer(), const Text('1 Spot Left!', style: TextStyle(color: Color(0xFFE34A4A), fontSize: 11, fontWeight: FontWeight.w700))]), const SizedBox(height: 12), Text(single ? 'Morning Singles at CSA' : "Tonight's Smash @ Otters AC", style: const TextStyle(color: _PartnersColors.ink, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 5), const Text('◷ Today, 7:30 PM • Court 2', style: TextStyle(color: _PartnersColors.muted, fontSize: 12)), const Spacer(), Row(children: [const Expanded(child: Text('Split Fee\nLKR 450', style: TextStyle(color: _PartnersColors.muted, fontSize: 12, fontWeight: FontWeight.w600))), FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined match hub!'))), style: FilledButton.styleFrom(minimumSize: const Size(64, 36), backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder()), child: const Text('Join Slot'))]) ]));
}

class _PartnersFooter extends StatelessWidget {
  const _PartnersFooter();

  @override
  Widget build(BuildContext context) => const Column(children: [Text('♢  ACCREDITED BY COLOMBO SPORTS AUTHORITY •\nVERIFIED ATHLETES', textAlign: TextAlign.center, style: TextStyle(color: _PartnersColors.muted, fontSize: 12, height: 1.5, fontWeight: FontWeight.w700)), SizedBox(height: 7), Text('SportsBook version 2.4.0', style: TextStyle(color: Color(0xFF9AA0AF), fontSize: 11))]);
}

class _PartnersColors {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
}
