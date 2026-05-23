import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/app_user.dart';
import '../../shared/providers/auth_providers.dart';

class ManageScreen extends ConsumerWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Manage', style: AppTextStyles.h1),
            const SizedBox(height: 20),

            // Top action cards
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Refer friends',
                    subtitle: 'Invite friends to earn rewards',
                    onTap: () => context.go('/rewards'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Find answers and contact us',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Account details
            userAsync.when(
              data: (user) => _CountrySelector(preferredCountry: user?.preferredCountry ?? 'KE'),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // Menu
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: userAsync.when(
                data: (user) => Column(
                  children: [
                    _MenuRow(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      badge: user?.kycStatus == KycStatus.verified
                          ? const _VerifiedBadge()
                          : null,
                      onTap: () => context.go('/manage/profile'),
                    ),
                    const Divider(height: 0),
                    _MenuRow(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => context.go('/manage/settings'),
                    ),
                    const Divider(height: 0),
                    _MenuRow(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment methods',
                      onTap: () => context.go('/manage/payment-methods'),
                    ),
                    const Divider(height: 0),
                    _MenuRow(
                      icon: Icons.local_offer_outlined,
                      title: 'Redeem offer',
                      onTap: () {},
                    ),
                    const Divider(height: 0),
                    _MenuRow(
                      icon: Icons.add_outlined,
                      title: 'Get Bridge Business',
                      badge: const _NewBadge(),
                      onTap: () {},
                    ),
                  ],
                ),
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                )),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 28),

            // Footer links
            const _FooterLinks(),

            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
                child: const Text(
                  'Sign out',
                  style: TextStyle(color: AppColors.error, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text('Version 1.0.0',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.infoCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CountrySelector extends StatelessWidget {
  final String preferredCountry;

  const _CountrySelector({required this.preferredCountry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account details', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🇰🇪', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Sending to Kenya', style: AppTextStyles.body),
              ),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? badge;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(title, style: AppTextStyles.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[badge!, const SizedBox(width: 8)],
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusDeliveredBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: AppColors.success),
          SizedBox(width: 4),
          Text('VERIFIED',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success)),
        ],
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('NEW',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _footerLink('Privacy choices'),
        const Divider(height: 0),
        _footerLink('Legal resources'),
        const Divider(height: 0),
        _footerLink('About us'),
      ],
    );
  }

  Widget _footerLink(String title) {
    return ListTile(
      title: Text(title, style: AppTextStyles.body),
      onTap: () {},
    );
  }
}
