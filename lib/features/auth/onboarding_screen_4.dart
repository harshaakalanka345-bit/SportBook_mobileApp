import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/main_wrapper.dart';
import 'auth_screen.dart';
import 'registration_screen.dart';

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

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
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _AccessStepBadge(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 32),
                    const _AccessHero(),
                    const SizedBox(height: 40),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contactless Entry with Digital\nMatch Pass',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 39,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Unlock venue turnstiles with dynamic QR codes,\naccess your locker automatically, and never wait in\nline again.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 18,
                          height: 1.52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AccessPill(
                          icon: Icons.qr_code_2_rounded,
                          label: 'Dynamic Turnstile QR',
                        ),
                        SizedBox(height: 12),
                        _AccessPill(
                          icon: Icons.lock_outline_rounded,
                          label: 'Keyless Locker Sync',
                        ),
                        SizedBox(height: 12),
                        _AccessPill(
                          icon: Icons.credit_card_rounded,
                          label: 'Apple / Google Wallet Ready',
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),
                    const _FinalProgressDots(),
                    const SizedBox(height: 44),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton.icon(
                        onPressed: () => _openRegistration(context),
                        icon: const Text('Get Started Now'),
                        label: const Icon(Icons.rocket_launch_outlined, size: 25),
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
                    const Text(
                      '✦  Official partner • Colombo Sports Authority\nVersion 2.4.0 • FastPass Protocol Enabled',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 15,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
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
      MaterialPageRoute(builder: (_) => const MainWrapper()),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _openRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
    );
  }
}

class _AccessStepBadge extends StatelessWidget {
  const _AccessStepBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: _Onboarding4Colors.pill,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 7),
          Text(
            'STEP 3 OF 3 • DIGITAL ACCESS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessHero extends StatelessWidget {
  const _AccessHero();

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
              'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=900&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF155A8A),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
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
                  stops: [0.42, 1],
                ),
              ),
            ),
            const Positioned(
              top: 28,
              left: 24,
              child: _AccessHeroPill(
                leading: Icon(Icons.circle, color: AppColors.primary, size: 14),
                label: 'Zero-Contact Entry • PIN: 8492',
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.93),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turnstile North #04',
                            style: TextStyle(
                              color: _Onboarding4Colors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Instant NFC & Optical Scan',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _Onboarding4Colors.muted,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _Onboarding4Colors.pill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Scan',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessHeroPill extends StatelessWidget {
  const _AccessHeroPill({required this.leading, required this.label});

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
              color: _Onboarding4Colors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessPill extends StatelessWidget {
  const _AccessPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _Onboarding4Colors.pill,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: _Onboarding4Colors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalProgressDots extends StatelessWidget {
  const _FinalProgressDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _FinalDot(),
        const SizedBox(width: 10),
        const _FinalDot(),
        const SizedBox(width: 10),
        Container(
          width: 56,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}

class _FinalDot extends StatelessWidget {
  const _FinalDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Color(0xFFB9C1D9),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Onboarding4Colors {
  static const pill = Color(0xFFE0E7FF);
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF5D6376);
}
