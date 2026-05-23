import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

// Temporary state carriers for the onboarding flow
final onboardingFirstNameProvider = StateProvider<String>((ref) => '');
final onboardingLastNameProvider = StateProvider<String>((ref) => '');
final onboardingDobProvider = StateProvider<DateTime?>((ref) => null);

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  DateTime? _dob;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: 'Select date of birth',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _continue() {
    final first = _firstCtrl.text.trim();
    final last = _lastCtrl.text.trim();
    if (first.isEmpty || last.isEmpty || _dob == null) return;

    ref.read(onboardingFirstNameProvider.notifier).state = first;
    ref.read(onboardingLastNameProvider.notifier).state = last;
    ref.read(onboardingDobProvider.notifier).state = _dob;

    context.go('/onboarding/address');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
      totalSteps: 8,
      title: 'Your personal information',
      subtitle: 'Required for identity verification and compliance.',
      child: Column(
        children: [
          TextField(
            controller: _firstCtrl,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'First name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lastCtrl,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Last name'),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    _dob != null
                        ? DateFormat('MMMM d, yyyy').format(_dob!)
                        : 'Date of birth',
                    style: _dob != null
                        ? const TextStyle(fontSize: 15, color: AppColors.textPrimary)
                        : const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _firstCtrl.text.isNotEmpty && _lastCtrl.text.isNotEmpty && _dob != null
                ? _continue
                : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
