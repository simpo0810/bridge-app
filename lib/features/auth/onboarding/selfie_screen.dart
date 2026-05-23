import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';
import 'personal_info_screen.dart';
import 'address_screen.dart';

class SelfieScreen extends ConsumerStatefulWidget {
  const SelfieScreen({super.key});

  @override
  ConsumerState<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends ConsumerState<SelfieScreen> {
  File? _selfie;
  bool _loading = false;
  String? _error;

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _selfie = File(picked.path));
  }

  Future<void> _submit() async {
    if (_selfie == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final uid = authService.currentUser!.uid;

      final firstName = ref.read(onboardingFirstNameProvider);
      final lastName = ref.read(onboardingLastNameProvider);
      final dob = ref.read(onboardingDobProvider);
      final address = ref.read(onboardingAddressProvider);

      // Create the user document in Firestore. KYC docs upload is handled by a
      // Cloud Function triggered after this step (not from client directly).
      final user = AppUser(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: authService.currentUser!.email ?? '',
        phone: authService.currentUser!.phoneNumber ?? '',
        dateOfBirth: dob,
        address: address,
        kycStatus: KycStatus.pending,
        isPrime: false,
        preferredCountry: 'KE',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await authService.createUserDocument(user);

      if (mounted) context.go('/onboarding/pending');
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 7,
      totalSteps: 8,
      title: 'Take a selfie',
      subtitle: 'We need to confirm your identity matches your ID.',
      child: Column(
        children: [
          GestureDetector(
            onTap: _takeSelfie,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: _selfie != null ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
              ),
              child: _selfie != null
                  ? ClipOval(child: Image.file(_selfie!, fit: BoxFit.cover))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.face, size: 56, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text('Tap to take selfie',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Look directly at the camera in a well-lit area.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _selfie != null && !_loading ? _submit : null,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Submit for verification'),
          ),
        ],
      ),
    );
  }
}
