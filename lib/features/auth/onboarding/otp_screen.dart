import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phone;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otp = '';
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    if (_otp.length < 6) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).confirmOtp(widget.verificationId, _otp);
      if (mounted) context.go('/onboarding/email-password');
    } catch (e) {
      setState(() {
        _error = 'Invalid code. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 2,
      totalSteps: 8,
      title: 'Verify your number',
      subtitle: 'Enter the 6-digit code sent to ${widget.phone}',
      child: Column(
        children: [
          PinCodeTextField(
            appContext: context,
            length: 6,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 52,
              fieldWidth: 44,
              activeFillColor: AppColors.surface,
              inactiveFillColor: AppColors.surface,
              selectedFillColor: AppColors.infoCard,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.divider,
              selectedColor: AppColors.primary,
            ),
            enableActiveFill: true,
            onChanged: (val) => _otp = val,
            onCompleted: (_) => _verify(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading || _otp.length < 6 ? null : _verify,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Verify'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Didn\'t receive a code? Go back',
              style: AppTextStyles.link,
            ),
          ),
        ],
      ),
    );
  }
}
