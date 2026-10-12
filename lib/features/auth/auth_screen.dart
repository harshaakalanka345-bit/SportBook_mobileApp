import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth_errors.dart';

import '../../core/app_theme.dart';
import '../../core/role_gate.dart';
import '../../core/supabase_service.dart';
import 'registration_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _service = SupabaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (_isSignUp && fullName.isEmpty) {
      _showError('Please enter your full name.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        final res = await _service.signUp(email, password, fullName);
        if (!mounted) return;
        if (res.session == null) {
          // Email confirmation is enabled: the user must verify before signing in.
          setState(() => _isSignUp = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created. Check your inbox to verify your email, then sign in.'),
              backgroundColor: Colors.green,
            ),
          );
          return;
        }
      } else {
        await _service.signIn(email, password);
      }
      if (!mounted) return;
      goHome(context);
    } on AuthException catch (e) {
      if (mounted) _showError(authErrorMessage(e));
    } catch (e) {
      if (mounted) _showError('Could not reach the server. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 18),
              const _AuthBrandMark(),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppColors.primary, size: 14),
                    SizedBox(width: 8),
                    Text(
                      'FAST-COURT PASS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SportsBook',
                style: TextStyle(
                  color: Color(0xFF11182D),
                  fontSize: 46,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.7,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Instant courts, zero friction.',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isSignUp
                    ? 'Create an account to book your next court\nin seconds.'
                    : 'Sign in to access your booked courts and\ninstant reservations.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5D6376),
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 34),
              _AuthFormCard(
                isSignUp: _isSignUp,
                isLoading: _isLoading,
                emailController: _emailController,
                passwordController: _passwordController,
                fullNameController: _fullNameController,
                isPasswordVisible: _isPasswordVisible,
                onPasswordVisibilityChanged: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                onSubmit: _submit,
                onForgotPassword: _showForgotPassword,
                onSocialLogin: _showSocialLogin,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _isSignUp
                    ? () => setState(() => _isSignUp = false)
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegistrationScreen(),
                          ),
                        );
                      },
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF5D6376),
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: _isSignUp
                            ? 'Already have an account? '
                            : "Don't have an account? ",
                      ),
                      TextSpan(
                        text: _isSignUp ? 'Log In' : 'Register Now',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _VenueStatusCard(),
              const SizedBox(height: 36),
              const Text(
                '✦  OFFICIAL BOOKING PARTNER\nVersion 2.4.0 • Colombo Sports Authority',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8C91A1),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) return;
              try {
                await _service.resetPassword(emailController.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent! Check your inbox.'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign in is coming soon.')),
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.isSignUp,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.fullNameController,
    required this.isPasswordVisible,
    required this.onPasswordVisibilityChanged,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onSocialLogin,
  });

  final bool isSignUp;
  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final bool isPasswordVisible;
  final VoidCallback onPasswordVisibilityChanged;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final ValueChanged<String> onSocialLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12001844),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSignUp) ...[
            const Text(
              'Full Name',
              style: _fieldLabelStyle,
            ),
            const SizedBox(height: 8),
            _AuthField(
              controller: fullNameController,
              hint: 'Alex Morgan',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 18),
          ],
          const Text('Username or Email', style: _fieldLabelStyle),
          const SizedBox(height: 8),
          _AuthField(
            controller: emailController,
            hint: 'alex.morgan@playcourt.io',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          const Text('Password', style: _fieldLabelStyle),
          const SizedBox(height: 8),
          _AuthField(
            controller: passwordController,
            hint: 'champion2025',
            icon: Icons.lock_outline_rounded,
            obscureText: !isPasswordVisible,
            suffixIcon: IconButton(
              onPressed: onPasswordVisibilityChanged,
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF737A8E),
              ),
            ),
          ),
          if (!isSignUp) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 18),
          SizedBox(
            height: 58,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: Text(isSignUp ? 'Register' : 'Log In'),
              label: const Icon(Icons.arrow_forward_rounded, size: 27),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                elevation: 7,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              ),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFE0E4F2))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Or connect with',
                  style: TextStyle(color: Color(0xFF8C91A1), fontSize: 16),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE0E4F2))),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _SocialButton(label: 'G', onPressed: () => onSocialLogin('Google'))),
              const SizedBox(width: 12),
              Expanded(child: _SocialButton(label: '●', onPressed: () => onSocialLogin('Apple'))),
              const SizedBox(width: 12),
              Expanded(child: _SocialButton(label: 'f', onPressed: () => onSocialLogin('Facebook'))),
            ],
          ),
        ],
      ),
    );
  }

  static const _fieldLabelStyle = TextStyle(
    color: Color(0xFF11182D),
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF30374B), fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF737A8E), size: 28),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF0F2FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF30374B), fontSize: 18),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF0F2FF),
          foregroundColor: const Color(0xFF11182D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: TextStyle(
            color: label == 'f' ? const Color(0xFF1877F2) : const Color(0xFF11182D),
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _AuthBrandMark extends StatelessWidget {
  const _AuthBrandMark();

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

class _VenueStatusCard extends StatelessWidget {
  const _VenueStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F1F8)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.sports_tennis_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colombo Central Courts',
                  style: TextStyle(
                    color: Color(0xFF11182D),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '3 prime slots available today',
                  style: TextStyle(color: Color(0xFF858B9D), fontSize: 15),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE5FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Live',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
