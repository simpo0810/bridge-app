import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/transfer.dart';
import '../../shared/providers/auth_providers.dart';
import '../../shared/providers/firestore_providers.dart';
import '../../shared/widgets/contact_avatar.dart';
import '../../shared/widgets/transfer_status_badge.dart';
import '../send/send_flow_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final corridorId = 'CAD_${user?.preferredCountry ?? 'KE'}';
    final rateAsync = ref.watch(exchangeRateProvider(corridorId));
    final isPrime = user?.isPrime ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(exchangeRateProvider(corridorId));
            ref.invalidate(recentContactsProvider);
            ref.invalidate(recentTransfersProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── Exchange rate banner ──────────────────────────────────────
              SliverToBoxAdapter(
                child: rateAsync.when(
                  data: (rate) => _ExchangeRateBanner(
                    rate: isPrime ? rate.primeRate : rate.standardRate,
                    fallbackRate: rate.rate,
                    fromCurrency: 'CAD',
                    toCurrency: _currencyFor(user?.preferredCountry),
                    rewardBalance: 20,
                  ),
                  loading: () => const _BannerSkeleton(),
                  error: (_, __) => const _BannerSkeleton(),
                ),
              ),

              // ── Quick send ────────────────────────────────────────────────
              const SliverToBoxAdapter(child: _QuickSendSection()),

              // ── Prime upsell ──────────────────────────────────────────────
              if (!isPrime)
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => context.push('/manage/prime'),
                    child: const _PrimeUpsellBanner(),
                  ),
                ),

              // ── Promo cards ───────────────────────────────────────────────
              const SliverToBoxAdapter(child: _PromoCards()),

              // ── Transfers header ──────────────────────────────────────────
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

              // ── Transfers list ────────────────────────────────────────────
              const _RecentTransfersList(),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
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

// ── Exchange Rate Banner ─────────────────────────────────────────────────────

class _ExchangeRateBanner extends StatelessWidget {
  final double rate;
  final double fallbackRate;
  final String fromCurrency;
  final String toCurrency;
  final double rewardBalance;

  const _ExchangeRateBanner({
    required this.rate,
    required this.fallbackRate,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rewardBalance,
  });

  @override
  Widget build(BuildContext context) {
    final displayRate = rate > 0 ? rate : fallbackRate;
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
                const Text(
                  'OUR BEST RATE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayRate > 0
                      ? '1 $fromCurrency = ${displayRate.toStringAsFixed(2)} $toCurrency'
                      : 'Rate unavailable',
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

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ── Quick Send ───────────────────────────────────────────────────────────────

class _QuickSendSection extends ConsumerWidget {
  const _QuickSendSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(recentContactsProvider);

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
                onPressed: () => context.go('/contacts'),
                child: const Text('View all', style: AppTextStyles.link),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 88,
            child: contactsAsync.when(
              data: (contacts) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...contacts.map(
                    (c) => _QuickContactChip(
                      initials: c.initials,
                      name: c.name,
                      subtitle: c.walletProvider,
                      flagEmoji: c.countryEmoji,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const SendFlowSheet(),
                      ),
                    ),
                  ),
                  _NewContactChip(onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const SendFlowSheet(),
                    );
                  }),
                ],
              ),
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => _NewContactChip(onTap: () {}),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickContactChip extends StatelessWidget {
  final String initials;
  final String name;
  final String subtitle;
  final String flagEmoji;
  final VoidCallback onTap;

  const _QuickContactChip({
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
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            ContactAvatar(initials: initials, flagEmoji: flagEmoji),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
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
              radius: 22,
              backgroundColor: AppColors.surface,
              child: const Icon(Icons.person_add_outlined,
                  color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(height: 4),
            const Text(
              'New contact',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Prime Upsell ─────────────────────────────────────────────────────────────

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Try Bridge Prime',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                SizedBox(height: 2),
                Text('Instant transfers + better rates',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
    );
  }
}

// ── Promo Cards ──────────────────────────────────────────────────────────────

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
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Transfers ─────────────────────────────────────────────────────────

class _RecentTransfersList extends ConsumerWidget {
  const _RecentTransfersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(recentTransfersProvider);

    return transfersAsync.when(
      data: (transfers) {
        if (transfers.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No transfers yet. Tap Send to get started.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final t = transfers[i];
              return _TransferRow(transfer: t);
            },
            childCount: transfers.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _TransferRow extends StatelessWidget {
  final Transfer transfer;

  const _TransferRow({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ContactAvatar(
            initials: transfer.recipient.initials,
            flagEmoji: transfer.recipient.countryEmoji,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransferStatusBadge(status: transfer.status),
                const SizedBox(height: 2),
                Text(transfer.recipient.name, style: AppTextStyles.body),
                Text(transfer.recipient.wallet, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transfer.currency} ${fmt.format(transfer.amountLocal)}',
                style: AppTextStyles.amountMedium,
              ),
              Text(
                'CAD ${fmt.format(transfer.amountCAD)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
