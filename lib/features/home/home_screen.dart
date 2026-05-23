import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Exchange rate banner
            SliverToBoxAdapter(
              child: _ExchangeRateBanner(
                rewardBalance: 20,
                fromCurrency: 'CAD',
                toCurrency: 'KES',
                rate: 92.44,
              ),
            ),

            // Quick send
            const SliverToBoxAdapter(child: _QuickSendSection()),

            // Prime upsell (for non-prime users)
            userAsync.when(
              data: (user) => user != null && !user.isPrime
                  ? const SliverToBoxAdapter(child: _PrimeUpsellBanner())
                  : const SliverToBoxAdapter(child: SizedBox.shrink()),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Promo cards
            const SliverToBoxAdapter(child: _PromoCards()),

            // Transfers header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transfers', style: AppTextStyles.h3),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View all', style: AppTextStyles.link),
                    ),
                  ],
                ),
              ),
            ),

            // Transfers list placeholder
            const SliverToBoxAdapter(child: _TransfersList()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _ExchangeRateBanner extends StatelessWidget {
  final double rewardBalance;
  final String fromCurrency;
  final String toCurrency;
  final double rate;

  const _ExchangeRateBanner({
    required this.rewardBalance,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const Text('OUR BEST RATE',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(
                  '1 $fromCurrency = ${rate.toStringAsFixed(2)} $toCurrency',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.infoCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  '\$${rewardBalance.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('🎁', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSendSection extends StatelessWidget {
  const _QuickSendSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quick send', style: AppTextStyles.h3),
              TextButton(
                onPressed: () {},
                child: const Text('View all', style: AppTextStyles.link),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickSendContactChip(
                  initials: 'TF',
                  name: 'Tuyisheme...',
                  subtitle: 'M-Pesa',
                  flagEmoji: '🇰🇪',
                  onTap: () {},
                ),
                _NewContactChip(onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSendContactChip extends StatelessWidget {
  final String initials;
  final String name;
  final String subtitle;
  final String flagEmoji;
  final VoidCallback onTap;

  const _QuickSendContactChip({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.flagEmoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.avatarBg,
                  child: Text(initials,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Text(flagEmoji, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(name,
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NewContactChip extends StatelessWidget {
  final VoidCallback onTap;

  const _NewContactChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.surface,
              child: const Icon(Icons.person_add_outlined,
                  color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(height: 4),
            const Text('New contact',
                style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PrimeUpsellBanner extends StatelessWidget {
  const _PrimeUpsellBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2B4B), Color(0xFF2D4A7A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('👑', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Try Bridge Prime',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Instant transfers + better rates',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
    );
  }
}

class _PromoCards extends StatelessWidget {
  const _PromoCards();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Text('📨', style: TextStyle(fontSize: 36)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Better exchange rate',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 4),
                Text('when you send \$100 CAD or more.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransfersList extends StatelessWidget {
  const _TransfersList();

  @override
  Widget build(BuildContext context) {
    // Placeholder — Phase 3 wires this to Firestore with pagination
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No transfers yet. Tap Send to get started.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
