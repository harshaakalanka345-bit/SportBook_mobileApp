import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import 'auth_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _service = SupabaseService();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _sports = <String>{'Badminton', 'Basketball'};
  bool _acceptedTerms = false;
  bool _passwordVisible = false;
  bool _isLoading = false;

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Please complete your name, email, and password.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }
    if (!_acceptedTerms) {
      _showMessage('Please accept the SportsBook terms to continue.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _service.signUp(email, password, name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        final message = error is AuthException ? error.message : error.toString();
        _showMessage('Registration error: $message');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E7FF),
                      foregroundColor: const Color(0xFF11182D),
                      fixedSize: const Size(62, 62),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 30),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Text('Skip'),
                    label: const Icon(Icons.arrow_forward_rounded),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF11182D),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _RegistrationBrandMark(),
              const SizedBox(height: 20),
              const _RegistrationBadge(),
              const SizedBox(height: 22),
              const Text(
                'Join SportsBook',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF11182D),
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Instant access to verified Colombo\ncourts & squad match splitting',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5D6376),
                  fontSize: 18,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),
              _RegistrationCard(
                nameController: _nameController,
                mobileController: _mobileController,
                emailController: _emailController,
                passwordController: _passwordController,
                passwordVisible: _passwordVisible,
                onPasswordVisibilityChanged: () {
                  setState(() => _passwordVisible = !_passwordVisible);
                },
                selectedSports: _sports,
                onSportChanged: (sport) {
                  setState(() {
                    if (_sports.contains(sport)) {
                      _sports.remove(sport);
                    } else {
                      _sports.add(sport);
                    }
                  });
                },
                acceptedTerms: _acceptedTerms,
                onTermsChanged: (value) => setState(() => _acceptedTerms = value),
                isLoading: _isLoading,
                onSubmit: _createAccount,
              ),
              const SizedBox(height: 22),
              const _ConnectDivider(),
              const SizedBox(height: 16),
              const _SocialRow(),
              const SizedBox(height: 22),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Color(0xFF5D6376), fontSize: 18),
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
              const SizedBox(height: 24),
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
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({
    required this.nameController,
    required this.mobileController,
    required this.emailController,
    required this.passwordController,
    required this.passwordVisible,
    required this.onPasswordVisibilityChanged,
    required this.selectedSports,
    required this.onSportChanged,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final VoidCallback onPasswordVisibilityChanged;
  final Set<String> selectedSports;
  final ValueChanged<String> onSportChanged;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x12001844), blurRadius: 22, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldTitle('Full Name', trailing: 'REQUIRED'),
          const SizedBox(height: 8),
          _RegistrationField(controller: nameController, hint: 'e.g. Kasun Perera', icon: Icons.person_outline_rounded),
          const SizedBox(height: 18),
          const _FieldTitle('Mobile Number', trailing: 'SMS OTP'),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
                ),
                child: const Center(
                  child: Text('+94', style: TextStyle(color: Color(0xFF30374B), fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
              Expanded(
                child: _RegistrationField(
                  controller: mobileController,
                  hint: '77 123 4567',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _FieldTitle('Email Address'),
          const SizedBox(height: 8),
          _RegistrationField(controller: emailController, hint: 'kasun.perera@gmail.com', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 18),
          const _FieldTitle('Create Password'),
          const SizedBox(height: 8),
          _RegistrationField(
            controller: passwordController,
            hint: 'AthletePass2025!',
            icon: Icons.lock_outline_rounded,
            obscureText: !passwordVisible,
            suffixIcon: IconButton(
              onPressed: onPasswordVisibilityChanged,
              icon: Icon(passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF737A8E)),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.circle, color: AppColors.primary, size: 11),
              SizedBox(width: 7),
              Expanded(child: Text('Strong password', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600))),
              SizedBox(width: 5),
              Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              Spacer(),
              _StrengthBars(),
            ],
          ),
          const SizedBox(height: 24),
          const _FieldTitle('Favorite Sports', trailing: 'Pick at least 1'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SportChip(label: 'Badminton', icon: Icons.sports_tennis_rounded, selected: selectedSports.contains('Badminton'), onTap: () => onSportChanged('Badminton')),
              _SportChip(label: 'Tennis', icon: Icons.sports_tennis_rounded, selected: selectedSports.contains('Tennis'), onTap: () => onSportChanged('Tennis')),
              _SportChip(label: 'Basketball', icon: Icons.sports_basketball_rounded, selected: selectedSports.contains('Basketball'), onTap: () => onSportChanged('Basketball')),
              _SportChip(label: 'Padel & TT', icon: Icons.sports_handball_rounded, selected: selectedSports.contains('Padel & TT'), onTap: () => onSportChanged('Padel & TT')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: acceptedTerms,
                onChanged: (value) => onTermsChanged(value ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 11),
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(color: Color(0xFF5D6376), fontSize: 16, height: 1.4),
                      children: [
                        TextSpan(text: 'SportsBook Terms', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        TextSpan(text: ' and Colombo Sports Authority Venue Policies.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: Text(isLoading ? 'Creating...' : 'Create Account'),
              label: const Icon(Icons.arrow_forward_rounded, size: 27),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                elevation: 7,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  const _FieldTitle(this.title, {this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF11182D), fontSize: 17, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (trailing != null) Text(trailing!, style: const TextStyle(color: Color(0xFF858B9D), fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _RegistrationField extends StatelessWidget {
  const _RegistrationField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.borderRadius,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF30374B), fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF737A8E), size: 27),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF0F2FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        border: OutlineInputBorder(borderRadius: borderRadius ?? BorderRadius.circular(24), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: borderRadius ?? BorderRadius.circular(24), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: borderRadius ?? BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        hintStyle: const TextStyle(color: Color(0xFF858B9D), fontSize: 18),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text(label),
      avatar: Icon(icon, color: selected ? Colors.white : AppColors.primary, size: 19),
      labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF5D6376), fontSize: 16, fontWeight: FontWeight.w500),
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFF0F2FF),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _StrengthBars extends StatelessWidget {
  const _StrengthBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        4,
        (_) => Container(
          width: 20,
          height: 6,
          margin: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}

class _RegistrationBrandMark extends StatelessWidget {
  const _RegistrationBrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 22, spreadRadius: 4, offset: const Offset(0, 9))],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.sports_tennis_rounded, color: Colors.white, size: 50),
      ),
    );
  }
}

class _RegistrationBadge extends StatelessWidget {
  const _RegistrationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
      decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(24)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 7),
          Text('ATHLETE REGISTRATION', style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
        ],
      ),
    );
  }
}

class _ConnectDivider extends StatelessWidget {
  const _ConnectDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFDDE2F2))),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR REGISTER WITH', style: TextStyle(color: Color(0xFF858B9D), fontSize: 15, fontWeight: FontWeight.w700))),
        Expanded(child: Divider(color: Color(0xFFDDE2F2))),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _RegisterSocial(label: 'G')),
        SizedBox(width: 12),
        Expanded(child: _RegisterSocial(label: '●')),
        SizedBox(width: 12),
        Expanded(child: _RegisterSocial(label: 'f')),
      ],
    );
  }
}

class _RegisterSocial extends StatelessWidget {
  const _RegisterSocial({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: TextButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Social registration is coming soon.'))),
        style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF11182D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        child: Text(label),
      ),
    );
  }
}
