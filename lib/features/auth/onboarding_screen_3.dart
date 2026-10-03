import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/main_wrapper.dart';
import 'auth_screen.dart';
import 'onboarding_screen_4.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  static const _background = Color(0xFFFAF8FF);
  static const _ink = Color(0xFF11182D);
  static const _muted = Color(0xFF5D6376);
  static const _pill = Color(0xFFE0E7FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: _pill,
                            foregroundColor: _ink,
                            fixedSize: const Size(78, 78),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 34),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Center(child: _StepBadge())),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 38),
                    const _SquadHero(),
                    const SizedBox(height: 46),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _pill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share_outlined, color: AppColors.primary, size: 21),
                          SizedBox(width: 8),
                          Text(
                            'SQUAD & SPLIT',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Rally Your Squad &\nSplit Bills Effortlessly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 40,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Coordinate matches with your regular crew,\nauto-invite teammates via WhatsApp, and split\ncourt costs automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 18,
                        height: 1.52,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        _BenefitPill(
                          icon: Icons.send_outlined,
                          label: '1-Tap Team Invites',
                        ),
                        _BenefitPill(
                          icon: Icons.pie_chart_outline_rounded,
                          label: 'Fair cost split',
                        ),
                        _BenefitPill(
                          icon: Icons.verified_outlined,
                          label: 'Zero hassle booking',
                        ),
                      ],
                    ),
                    const SizedBox(height: 42),
                    const _ProgressDots(),
                    const SizedBox(height: 44),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton.icon(
                        onPressed: () => _openFourthPage(context),
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
                    const Row(
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
      MaterialPageRoute(builder: (_) => const MainWrapper()),
    );
  }

  void _openFourthPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen4()),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
      decoration: BoxDecoration(
        color: _Onboarding3Colors.pill,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: AppColors.primary, size: 13),
          SizedBox(width: 9),
          Text(
            'STEP 2 OF 3',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SquadHero extends StatelessWidget {
  const _SquadHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: double.infinity,
        height: 516,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=900&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF155A8A),
                child: Icon(
                  Icons.groups_rounded,
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
                  colors: [Color(0x1800162F), Color(0xD800162F)],
                  stops: [0.48, 1],
                ),
              ),
            ),
            const Positioned(
              top: 28,
              left: 26,
              child: _HeroPill(
                leading: Icon(Icons.groups_rounded, color: AppColors.primary, size: 23),
                label: 'Instant Squad Split  •  4 PLAYERS',
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    const SizedBox(
                      width: 160,
                      height: 48,
                      child: Stack(
                        children: [
                          _Avatar(letter: 'S', left: 0),
                          _Avatar(letter: 'A', left: 36),
                          _Avatar(letter: 'D', left: 72, muted: true),
                          _Avatar(letter: 'K', left: 108),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SHARE',
                            style: TextStyle(
                              color: OnboardingScreen3._muted,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$12.50/ea',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                      decoration: BoxDecoration(
                        color: _Onboarding3Colors.pill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.primary, size: 21),
                          SizedBox(width: 4),
                          Text(
                            'AUTO PAY',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              color: _Onboarding3Colors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter, required this.left, this.muted = false});

  final String letter;
  final double left;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: muted ? const Color(0xFF77849B) : AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          letter,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _BenefitPill extends StatelessWidget {
  const _BenefitPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: _Onboarding3Colors.pill,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: _Onboarding3Colors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
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
        const _Dot(active: false),
        const SizedBox(width: 10),
        Container(
          width: 56,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        const _Dot(active: false),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFDCE4FF),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Onboarding3Colors {
  static const pill = Color(0xFFE0E7FF);
  static const ink = Color(0xFF11182D);
}
