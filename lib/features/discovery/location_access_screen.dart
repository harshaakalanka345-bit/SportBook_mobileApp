import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/actions.dart';
import '../../core/location_service.dart';

class LocationAccessScreen extends StatefulWidget {
  const LocationAccessScreen({super.key});

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {

  static const _background = Color(0xFFFAF8FF);
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF5D6376);
  static const _softBlue = Color(0xFFE0E7FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 28),
              const _LocationGraphic(),
              const SizedBox(height: 38),
              const Text(
                'Find Courts Near\nYou Automatically',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 40,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Enable location access so SportsBook can show\nreal-time court availability, instant travel times,\nand local tournaments across Colombo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 34),
              const Column(
                children: [
                  _LocationFeature(
                    icon: Icons.explore_outlined,
                    title: 'Nearest Court Discovery',
                    description: 'Instant distance calculation to top-rated\nindoor & outdoor arenas.',
                  ),
                  SizedBox(height: 14),
                  _LocationFeature(
                    icon: Icons.access_time_rounded,
                    title: 'Real-Time Slot Availability',
                    description: 'Prioritize courts you can reach in under 15\nminutes.',
                  ),
                  SizedBox(height: 14),
                  _LocationFeature(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Live Weather & Court Conditions',
                    description: 'Accurate outdoor court playability warnings\nbefore you depart.',
                  ),
                ],
              ),
              const SizedBox(height: 38),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: FilledButton.icon(
                  onPressed: () => _requestLocation(context),
                  icon: const Icon(Icons.location_on_outlined, size: 26),
                  label: Text(_requesting ? 'Requesting Location…' : 'Enable Location Access'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: TextButton.icon(
                  onPressed: () => _enterLocationManually(context),
                  icon: const Icon(Icons.search_rounded, size: 27),
                  label: const Text('Enter Location Manually'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF0F2FF),
                    foregroundColor: _ink,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.lock_outline_rounded, color: _muted, size: 21),
                  ),
                  SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      'We only use your location while using the app to show\nnearby facilities. Your privacy is protected.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 15, height: 1.55),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Colombo Sports Authority Partner • Version 2.4.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF858B9D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFEAF0FF),
            foregroundColor: _ink,
            fixedSize: const Size(64, 64),
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 31),
        ),
        const SizedBox(width: 15),
        const _LocationBrandMark(),
        const SizedBox(width: 10),
        const Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Sports', style: TextStyle(color: _ink)),
                TextSpan(text: 'Book', style: TextStyle(color: AppColors.primary)),
              ],
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -0.7),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFF0F2FF),
            foregroundColor: _muted,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: const Text('Maybe Later'),
        ),
      ],
    );
  }

  bool _requesting = false;

  Future<void> _requestLocation(BuildContext context) async {
    if (_requesting) return;
    setState(() => _requesting = true);
    final position = await requestCurrentLocation();
    if (!mounted) return;
    setState(() => _requesting = false);
    if (position != null) {
      Navigator.of(context).pop(LocationSelection(
        label: 'CURRENT LOCATION (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
        location: position,
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location access was not granted. Check your browser or device settings and try again.')),
    );
  }

  void _enterLocationManually(BuildContext context) {
    final controller = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose your area'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(dialogContext).pop(controller.text),
          decoration: const InputDecoration(hintText: 'e.g. Colombo 07, Rajagiriya'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: const Text('Show courts')),
        ],
      ),
    ).then((value) {
      controller.dispose();
      final area = value?.trim() ?? '';
      if (!mounted || area.isEmpty) return;
      Navigator.of(context).pop(LocationSelection(label: area.toUpperCase(), searchText: area));
    });
  }
}

class _LocationGraphic extends StatelessWidget {
  const _LocationGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 470,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 410, height: 410, decoration: const BoxDecoration(color: Color(0xFFE8ECFF), shape: BoxShape.circle)),
          Container(width: 315, height: 315, decoration: const BoxDecoration(color: Color(0xFFDDE4FF), shape: BoxShape.circle)),
          Container(width: 225, height: 225, decoration: const BoxDecoration(color: Color(0xFFD3DFFF), shape: BoxShape.circle)),
          Container(
            width: 146,
            height: 146,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 65),
          ),
          const Positioned(top: 24, left: 10, child: _MapTag(icon: Icons.sports_tennis_rounded, title: 'CSA Arena', subtitle: '0.8 km')),
          const Positioned(top: 68, right: 8, child: _DistanceTag(label: 'Colombo 07')),
          const Positioned(bottom: 24, right: 4, child: _MapTag(icon: Icons.sports_handball_rounded, title: 'Liberty Courts', subtitle: '1.5 km')),
          const Positioned(child: Align(alignment: Alignment(0.32, 0.25), child: _MapPinBadge())),
        ],
      ),
    );
  }
}

class _MapTag extends StatelessWidget {
  const _MapTag({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: const [BoxShadow(color: Color(0x18001844), blurRadius: 11, offset: Offset(0, 6))]),
      child: Row(children: [Container(width: 42, height: 42, decoration: const BoxDecoration(color: Color(0xFFF0F2FF), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 23)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _LocationAccessColors.ink, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _LocationAccessColors.muted, fontSize: 15))])]),
    );
  }
}

class _DistanceTag extends StatelessWidget {
  const _DistanceTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x12001844), blurRadius: 8, offset: Offset(0, 4))]), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.circle, color: AppColors.primary, size: 13), const SizedBox(width: 8), Text(label, style: const TextStyle(color: _LocationAccessColors.muted, fontSize: 16, fontWeight: FontWeight.w600))]));
}

class _MapPinBadge extends StatelessWidget {
  const _MapPinBadge();

  @override
  Widget build(BuildContext context) => Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x18001844), blurRadius: 8, offset: Offset(0, 4))]), child: const Icon(Icons.location_searching_rounded, color: AppColors.primary, size: 27));
}

class _LocationFeature extends StatelessWidget {
  const _LocationFeature({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x0C001844), blurRadius: 9, offset: Offset(0, 4))]), child: Row(children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: _LocationAccessColors.softBlue, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: AppColors.primary, size: 29)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _LocationAccessColors.ink, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(description, style: const TextStyle(color: _LocationAccessColors.muted, fontSize: 15, height: 1.35))]))]));
}

class _LocationBrandMark extends StatelessWidget {
  const _LocationBrandMark();

  @override
  Widget build(BuildContext context) => Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 27));
}

class _LocationAccessColors {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF5D6376);
  static const softBlue = Color(0xFFF0F2FF);
}
