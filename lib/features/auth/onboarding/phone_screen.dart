import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final authService = ref.read(authServiceProvider);
    // Prefix with +1 (Canada) if not already present
    final fullPhone = phone.startsWith('+') ? phone : '+1$phone';

    await authService.verifyPhone(
      phoneNumber: fullPhone,
      onAutoVerified: (credential) {
        // Auto-verified on Android — proceed directly
        if (mounted) context.go('/onboarding/email-password');
      },
      onCodeSent: (verificationId, _) {
        if (mounted) {
          context.go(
            '/onboarding/otp',
            extra: {'verificationId': verificationId, 'phone': fullPhone},
          );
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _error = e.message ?? 'Failed to send code. Check the number and try again.';
            _loading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 1,
      totalSteps: 8,
      title: 'Enter your phone number',
      subtitle: 'We\'ll send a verification code to confirm it\'s you.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('🇨🇦', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 6),
                    Text('+1', style: AppTextStyles.body),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: '(514) 000-0000',
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
