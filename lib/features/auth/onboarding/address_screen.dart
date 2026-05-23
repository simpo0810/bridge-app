import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

final onboardingAddressProvider = StateProvider<UserAddress?>((ref) => null);

const List<String> _canadianProvinces = [
  'AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT',
];

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  String? _province;

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final street = _streetCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final postal = _postalCtrl.text.trim().toUpperCase();
    if (street.isEmpty || city.isEmpty || _province == null || postal.isEmpty) return;

    ref.read(onboardingAddressProvider.notifier).state = UserAddress(
      street: street,
      city: city,
      province: _province!,
      postalCode: postal,
    );

    context.go('/onboarding/id-upload');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 5,
      totalSteps: 8,
      title: 'Your Canadian address',
      subtitle: 'Your current residential address in Canada.',
      child: Column(
        children: [
          TextField(
            controller: _streetCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'Street address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cityCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'City'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _province,
            decoration: const InputDecoration(hintText: 'Province'),
            items: _canadianProvinces
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) => setState(() => _province = val),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _postalCtrl,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Postal code (e.g. H2X 2B3)'),
            onSubmitted: (_) => _continue(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _continue,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
