import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Offers section
          const Text('Offers', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🪴', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No current offers', style: AppTextStyles.h3),
                          SizedBox(height: 4),
                          Text('Earn rewards when you refer friends to Bridge.',
                              style: AppTextStyles.bodySecondary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Redeem offer code', style: AppTextStyles.link),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Referrals section
          const Text('Referrals', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invite friends, get \$20',
                          style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      const Text(
                          'Your friend gets a discount and welcome offer too.',
                          style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                          ),
                          child: const Text('Invite friends'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🎁', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
