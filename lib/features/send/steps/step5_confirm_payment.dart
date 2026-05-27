import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';
import '../send_flow_notifier.dart';

class Step5ConfirmPayment extends ConsumerWidget {
  const Step5ConfirmPayment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendFlowProvider);
    final method = state.paymentMethod ?? 'interac';
    final detail = state.paymentDetail ?? '';
    final rate = state.exchangeRate ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Confirm payment method', style: AppTextStyles.h1),
          const SizedBox(height: 24),

          // Selected method (highlighted)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(_iconForMethod(method), style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_labelForMethod(method), style: AppTextStyles.h3),
                      Text(
                        '⚡ ${_deliveryForMethod(method, ref.watch(currentUserProvider).valueOrNull?.isPrime ?? false)}',
                        style: AppTextStyles.caption,
                      ),
                      if (detail.isNotEmpty)
                        Text(detail, style: AppTextStyles.caption),
                      if (rate > 0)
                        Text('1 CAD = ${rate.toStringAsFixed(2)} ${_currencyFor(state.selectedContact?.country)}',
                            style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: AppColors.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('Other payment methods', style: AppTextStyles.h3),
          const SizedBox(height: 12),

          _OtherMethod(
            icon: '💳',
            title: 'Add new card',
            subtitle: '⚡ Delivers instantly',
            rate: '1 CAD = ${rate.toStringAsFixed(2)} KES',
            onTap: () {},
          ),
          const Divider(height: 0),
          _OtherMethod(
            icon: '🏦',
            title: 'Add bank account',
            subtitle: 'Delivers in 3 to 6 days',
            rate: '1 CAD = ${rate.toStringAsFixed(2)} KES',
            onTap: () {},
          ),

          const Spacer(),
          ElevatedButton(
            onPressed: () => ref.read(sendFlowProvider.notifier).nextStep(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _iconForMethod(String method) {
    switch (method) {
      case 'prime':
        return '👑';
      case 'interac':
        return '⚡';
      case 'card':
        return '💳';
      case 'bank':
        return '🏦';
      default:
        return '💰';
    }
  }

  String _labelForMethod(String method) {
    switch (method) {
      case 'prime':
        return 'Bridge Prime';
      case 'interac':
        return 'Interac e-Transfer';
      case 'card':
        return 'Debit / Credit card';
      case 'bank':
        return 'Bank account (EFT)';
      default:
        return method;
    }
  }

  String _deliveryForMethod(String method, bool isPrime) {
    switch (method) {
      case 'prime':
        return 'Delivers instantly';
      case 'interac':
        return isPrime ? 'Delivers instantly' : 'Delivers within 9 hours';
      case 'card':
        return 'Delivers instantly';
      case 'bank':
        return 'Delivers in 3 to 6 days';
      default:
        return '';
    }
  }

  String _currencyFor(String? country) {
    const map = {
      'KE': 'KES',
      'CD': 'CDF',
      'RW': 'RWF',
      'NG': 'NGN',
      'GH': 'GHS',
      'SN': 'XOF',
    };
    return map[country] ?? 'KES';
  }
}

class _OtherMethod extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String rate;
  final VoidCallback onTap;

  const _OtherMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text('$subtitle\n$rate', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
