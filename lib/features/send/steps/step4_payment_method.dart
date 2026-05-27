import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';
import '../send_flow_notifier.dart';

class Step4PaymentMethod extends ConsumerWidget {
  const Step4PaymentMethod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrime = ref.watch(currentUserProvider).valueOrNull?.isPrime ?? false;
    final state = ref.watch(sendFlowProvider);
    final rate = state.exchangeRate ?? 0;
    final rateStr = '1 CAD = ${rate.toStringAsFixed(2)} KES';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Text('How do you want to pay?', style: AppTextStyles.h1),
        const SizedBox(height: 24),

        // INSTANT group
        _SectionLabel(label: 'INSTANT'),
        const SizedBox(height: 8),

        // Prime option
        _PaymentCard(
          icon: '👑',
          title: 'Bridge Prime',
          subtitle: 'Delivers instantly · Best rate',
          rate: '${(rate * 1.005).toStringAsFixed(2)} KES per CAD',
          feeLabel: 'CAD 0.00 fee',
          badgeLabel: 'BEST',
          badgeColor: AppColors.prime,
          isLocked: !isPrime,
          lockLabel: 'Subscribe to Prime',
          onTap: () {
            if (!isPrime) {
              // Show Prime upsell
              showModalBottomSheet(
                context: context,
                builder: (_) => _PrimeUpsellSheet(),
              );
              return;
            }
            ref.read(sendFlowProvider.notifier).selectPaymentMethod(
                  'prime',
                  detail: 'Bridge Prime',
                );
          },
        ),
        const SizedBox(height: 10),

        _PaymentCard(
          icon: '💳',
          title: 'Debit / Credit card',
          subtitle: 'Delivers instantly',
          rate: rateStr,
          feeLabel: '2.5% fee',
          onTap: () => ref.read(sendFlowProvider.notifier).selectPaymentMethod(
                'card',
                detail: 'Card ending in ••••',
              ),
        ),

        const SizedBox(height: 20),

        // BEST VALUE group
        _SectionLabel(label: 'BEST VALUE'),
        const SizedBox(height: 8),

        _PaymentCard(
          icon: '⚡',
          title: 'Interac e-Transfer',
          subtitle: isPrime ? 'Delivers instantly (Prime)' : 'Delivers within 9 hours',
          rate: rateStr,
          feeLabel: 'CAD 0.00 fee',
          badgeLabel: isPrime ? 'PRIME' : null,
          badgeColor: AppColors.prime,
          onTap: () => ref.read(sendFlowProvider.notifier).selectPaymentMethod(
                'interac',
                detail: 's•••••••@gmail.com',
              ),
        ),
        const SizedBox(height: 10),

        _PaymentCard(
          icon: '🏦',
          title: 'Bank account (EFT)',
          subtitle: 'Delivers in 3 to 6 days',
          rate: rateStr,
          feeLabel: 'CAD 0.00 fee',
          onTap: () => ref.read(sendFlowProvider.notifier).selectPaymentMethod(
                'bank',
                detail: 'Checking ••7021',
              ),
        ),

        const SizedBox(height: 20),
        const _FeeDisclaimer(),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String rate;
  final String feeLabel;
  final String? badgeLabel;
  final Color? badgeColor;
  final bool isLocked;
  final String? lockLabel;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rate,
    required this.feeLabel,
    this.badgeLabel,
    this.badgeColor,
    this.isLocked = false,
    this.lockLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.h3),
                      if (badgeLabel != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor ?? AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeLabel!,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                  Text(rate, style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                isLocked
                    ? const Icon(Icons.lock_outline,
                        color: AppColors.textSecondary, size: 18)
                    : const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 20),
                if (isLocked && lockLabel != null)
                  Text(
                    lockLabel!,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.prime,
                        fontWeight: FontWeight.w600),
                  )
                else
                  Text(feeLabel,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeDisclaimer extends StatelessWidget {
  const _FeeDisclaimer();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Delivery speed is an estimate. Interac e-Transfer timing depends on your bank.',
      style: AppTextStyles.caption,
      textAlign: TextAlign.center,
    );
  }
}

class _PrimeUpsellSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👑', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Unlock Bridge Prime', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
            'Get instant transfers, better rates, and zero fees — for \$9.99/month.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.prime),
            onPressed: () => Navigator.pop(context),
            child: const Text('Learn about Prime'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue without Prime'),
          ),
        ],
      ),
    );
  }
}
