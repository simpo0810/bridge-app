import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment methods')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Saved methods', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          // Placeholder — Phase 5 wires to Firestore
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('No payment methods saved yet.',
                style: AppTextStyles.bodySecondary),
          ),
          const SizedBox(height: 24),
          const Text('Add a method', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          _AddMethodRow(
            icon: Icons.credit_card_outlined,
            title: 'Add new card',
            subtitle: 'Delivers instantly',
            onTap: () {},
          ),
          const Divider(height: 0),
          _AddMethodRow(
            icon: Icons.account_balance_outlined,
            title: 'Add bank account',
            subtitle: 'Delivers in 3 to 6 days',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _AddMethodRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddMethodRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.surface,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
