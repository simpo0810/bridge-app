import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class IdUploadScreen extends StatefulWidget {
  const IdUploadScreen({super.key});

  @override
  State<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  File? _frontImage;
  String? _selectedDocType;
  static const _docTypes = ['Passport', 'Driver\'s license', 'Provincial ID'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) setState(() => _frontImage = File(picked.path));
  }

  void _continue() {
    if (_frontImage == null || _selectedDocType == null) return;
    // In Phase 1, we proceed to selfie. Upload happens after selfie via Cloud Function.
    context.go('/onboarding/selfie');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 6,
      totalSteps: 8,
      title: 'Verify your identity',
      subtitle: 'We need a government-issued ID to comply with Canadian regulations.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doc type selector
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _docTypes.map((type) {
              final selected = _selectedDocType == type;
              return ChoiceChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) => setState(() => _selectedDocType = type),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.divider,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Upload area
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _frontImage != null ? AppColors.primary : AppColors.divider,
                  style: BorderStyle.solid,
                ),
              ),
              child: _frontImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_frontImage!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 40, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('Tap to take a photo', style: AppTextStyles.bodySecondary),
                        SizedBox(height: 4),
                        Text('Make sure your ID is fully visible and in focus',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _frontImage != null && _selectedDocType != null ? _continue : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
