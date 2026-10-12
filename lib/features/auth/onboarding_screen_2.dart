import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'auth_screen.dart';
import 'onboarding_screen_4.dart';
import 'onboarding_screen_3.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  static const _background = Color(0xFFFAF8FF);
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF5D6376);
  static const _card = Color(0xFFF0F3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 46),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: AppColors.primary, size: 14),
                              SizedBox(width: 9),
                              Text(
                                'STEP 1 OF 3 • DISCOVER',
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _openApp(context),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _DiscoveryHero(),
                    const SizedBox(height: 42),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Find & Book Verified\nCourts in Seconds',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 42,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Explore premium indoor badminton, tennis, and\npaddle courts near you with live availability and\ninstant slot lock.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 18,
                          height: 1.52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Column(
                      children: [
                        _FeatureTile(
                          icon: Icons.alternate_email_rounded,
                          title: 'Real-time Slot Radar',
                          subtitle: 'Direct sync with stadium lighting timers',
                        ),
                        SizedBox(height: 12),
                        _FeatureTile(
                          icon: Icons.home_work_outlined,
                          title: '100% Weatherproof Arenas',
                          subtitle: 'Zero rain cancellations, climate-controlled',
                        ),
                        SizedBox(height: 12),
                        _FeatureTile(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Verified Facility Quality',
                          subtitle: 'BWF & ITF grade shock-absorbing mats',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _ProgressDots(),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton.icon(
                        onPressed: () => _openThirdPage(context),
                        icon: const Text('Next'),
                        label: const Icon(Icons.arrow_forward_rounded, size: 28),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => _openLogin(context),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: _muted, fontSize: 18),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, color: _muted, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'OFFICIAL PARTNER • COLOMBO SPORTS AUTHORITY',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen4()),
    );
  }

  void _openThirdPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen3()),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }
}

class _DiscoveryHero extends StatelessWidget {
  const _DiscoveryHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: double.infinity,
        height: 518,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=900&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF294B70),
                child: Icon(
                  Icons.sports_tennis_rounded,
                  color: Colors.white,
                  size: 96,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x08000000), Color(0xC000162F)],
                  stops: [0.42, 1],
                ),
              ),
            ),
            const Positioned(
              top: 28,
              left: 26,
              child: _Pill(
                leading: Icon(Icons.wifi_tethering_rounded, color: AppColors.primary, size: 18),
                label: '38+ Courts Available Now in Colombo',
              ),
            ),
            const Positioned(
              top: 28,
              right: 26,
              child: CircleAvatar(
                radius: 31,
                backgroundColor: Colors.white,
                child: Icon(Icons.verified_rounded, color: AppColors.primary, size: 30),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Wrap(
                spacing: 10,
                runSpacing: 12,
                children: const [
                  _Pill(leading: Text('🏸', style: TextStyle(fontSize: 17)), label: 'Badminton'),
                  _Pill(leading: Text('🎾', style: TextStyle(fontSize: 17)), label: 'Tennis'),
                  _Pill(leading: Text('🏀', style: TextStyle(fontSize: 17)), label: 'Basketball'),
                  _Pill(leading: Text('🏓', style: TextStyle(fontSize: 17)), label: 'Padel'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: OnboardingScreen2._ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: OnboardingScreen2._card,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFDCE7FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: OnboardingScreen2._ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: OnboardingScreen2._muted,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        ...List.generate(
          2,
          (_) => Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFB9C1D9),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
