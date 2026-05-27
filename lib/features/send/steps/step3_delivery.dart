import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/corridors.dart';
import '../send_flow_notifier.dart';

class Step3Delivery extends ConsumerWidget {
  const Step3Delivery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(sendFlowProvider).selectedContact;
    final corridor = kSupportedCorridors.firstWhere(
      (c) => c.countryCode == (contact?.country ?? 'KE'),
      orElse: () => kSupportedCorridors.first,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Text('How should they receive it?', style: AppTextStyles.h1),
        const SizedBox(height: 24),
        ...corridor.deliveryMethods.map((method) => _DeliveryOption(
              method: method,
              flag: contact?.countryEmoji ?? '🌍',
              onTap: () => ref
                  .read(sendFlowProvider.notifier)
                  .setDeliveryMethod(method, method),
            )),
        _DeliveryOption(
          method: 'Bank transfer',
          flag: '🏦',
          subtitle: 'Delivers in 1-3 business days',
          onTap: () => ref
              .read(sendFlowProvider.notifier)
              .setDeliveryMethod('Bank transfer', 'Bank'),
        ),
      ],
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  final String method;
  final String flag;
  final String? subtitle;
  final VoidCallback onTap;

  const _DeliveryOption({
    required this.method,
    required this.flag,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Text(flag, style: const TextStyle(fontSize: 28)),
        title: Text(method, style: AppTextStyles.body),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTextStyles.caption)
            : const Text('Mobile delivery', style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
