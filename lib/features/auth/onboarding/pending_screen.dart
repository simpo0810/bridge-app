import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/providers/auth_providers.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user document so we auto-navigate when KYC is approved
    ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null && user.kycStatus == KycStatus.verified) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.infoCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    size: 52, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text('Verifying your identity', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              const Text(
                'We\'re reviewing your documents. This usually takes a few minutes, but can take up to 24 hours.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'ll receive an email when your account is verified.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Continue to Bridge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
