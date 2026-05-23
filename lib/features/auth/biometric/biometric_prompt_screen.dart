import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';

class BiometricPromptScreen extends ConsumerStatefulWidget {
  const BiometricPromptScreen({super.key});

  @override
  ConsumerState<BiometricPromptScreen> createState() =>
      _BiometricPromptScreenState();
}

class _BiometricPromptScreenState
    extends ConsumerState<BiometricPromptScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric prompt on mount
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final success =
        await ref.read(biometricServiceProvider).authenticate(
              reason: 'Use biometrics to sign in to Bridge',
            );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      setState(() {
        _loading = false;
        _error = 'Biometric authentication failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(
                  Icons.fingerprint,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text('Welcome back', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              const Text(
                'Use Face ID or your fingerprint to sign in.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 40),
              if (_loading)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                ElevatedButton(
                  onPressed: _authenticate,
                  child: const Text('Try again'),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text(
                  'Use password instead',
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
