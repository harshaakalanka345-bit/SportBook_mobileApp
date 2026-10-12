import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'auth_screen.dart';
import 'onboarding_screen_4.dart';
import 'onboarding_screen_2.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _background = Color(0xFFFAF8FF);
  static const _ink = Color(0xFF11182D);
  static const _softBlue = Color(0xFFF0F3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _openApp(context),
                        icon: const Text('Skip'),
                        label: const Icon(Icons.arrow_forward_rounded),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _ink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _CourtHero(),
                    const SizedBox(height: 44),
                    const _BrandMark(),
                    const SizedBox(height: 18),
                    const Text(
                      'SportsBook',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 48,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.8,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Instant courts, zero friction.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Find, book, and play on premium basketball,\ntennis, and paddle courts in seconds across\nthe city.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF5D6376),
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Row(
                      children: [
                        Expanded(
                          child: _Benefit(
                            icon: Icons.schedule_rounded,
                            label: 'Real-time\nSlots',
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: _Benefit(
                            icon: Icons.verified_rounded,
                            label: 'Verified\nVenues',
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: _Benefit(
                            icon: Icons.bolt_rounded,
                            label: 'Instant\nConfirm',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton.icon(
                        onPressed: () => _openSecondPage(context),
                        icon: const Text('Get Started'),
                        label: const Icon(Icons.arrow_forward_rounded, size: 28),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () => _openLogin(context),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: Color(0xFF5D6376),
                            fontSize: 18,
                          ),
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
                    const SizedBox(height: 22),
                    const Text(
                      'Official partner... Version 2.4.0 • Colombo Sports\nAuthority',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8C91A1),
                        fontSize: 15,
                        height: 1.45,
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

  void _openSecondPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingScreen2()),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }
}

class _CourtHero extends StatelessWidget {
  const _CourtHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: double.infinity,
        height: 500,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=900&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF233A5D),
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
                  colors: [Colors.transparent, Color(0xB8000000)],
                  stops: [0.48, 1],
                ),
              ),
            ),
            const Positioned(
              top: 28,
              left: 30,
              child: _HeroPill(
                leading: Icon(Icons.circle, size: 14, color: AppColors.primary),
                label: '38 courts available now',
              ),
            ),
            Positioned(
              left: 30,
              right: 30,
              bottom: 30,
              child: Row(
                children: const [
                  Expanded(
                    child: _HeroPill(
                      leading: Icon(Icons.sports_tennis_rounded, color: AppColors.primary),
                      label: 'Tennis',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _HeroPill(
                      leading: Icon(Icons.sports_basketball_rounded, color: AppColors.primary),
                      label: 'Basketball',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _HeroPill(
                      leading: Icon(Icons.sports_handball_rounded, color: AppColors.primary),
                      label: 'Paddle',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: OnboardingScreen._ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.sports_tennis_rounded,
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: OnboardingScreen._softBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFDCE7FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: OnboardingScreen._ink,
              fontSize: 15,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
