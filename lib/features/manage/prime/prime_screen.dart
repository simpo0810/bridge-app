import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/prime_provider.dart';

class PrimeScreen extends ConsumerWidget {
  const PrimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Firestore is the source of truth — isPrime is set by the revenueCatWebhook
    // Cloud Function. rcCustomerInfoProvider provides real-time RC updates as backup.
    final isPrime = ref.watch(currentUserProvider).valueOrNull?.isPrime ?? false;
    final purchaseState = ref.watch(purchaseNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bridge Prime')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Hero ────────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B2B4B), Color(0xFF2D4A7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('👑', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text(
                  'Bridge Prime',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Instant transfers · Better rates · Zero fees',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text('What you get', style: AppTextStyles.h3),
          const SizedBox(height: 12),

          ..._features.map(
              (f) => _FeatureRow(icon: f.$1, title: f.$2, subtitle: f.$3)),

          const SizedBox(height: 28),
          const Text('Standard vs Prime', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          const _ComparisonTable(),
          const SizedBox(height: 32),

          if (isPrime) ...[
            // ── Active member ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusDeliveredBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 12),
                  Text(
                    "You're a Prime member!",
                    style: TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Customer Center — manage / cancel subscription
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(purchasesServiceProvider)
                  .presentCustomerCenter(context),
              icon: const Icon(Icons.manage_accounts_outlined),
              label: const Text('Manage subscription'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ] else ...[
            // ── Error banner ─────────────────────────────────────────────────
            if (purchaseState.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  purchaseState.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            // ── Primary CTA — opens RevenueCat Paywall ───────────────────────
            ElevatedButton(
              onPressed: purchaseState.isLoading
                  ? null
                  : () => _openPaywall(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.prime,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: purchaseState.isLoading
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Upgrade to Prime 👑'),
            ),

            const SizedBox(height: 12),

            // ── Restore purchases ─────────────────────────────────────────────
            Center(
              child: TextButton(
                onPressed: purchaseState.isLoading
                    ? null
                    : () => _restorePurchases(context, ref),
                child: const Text('Restore purchases',
                    style: AppTextStyles.bodySecondary),
              ),
            ),

            const SizedBox(height: 8),
            const Center(
              child: Text(
                'By subscribing you agree to our Terms of Service.\n'
                'Cancel anytime from your App Store settings.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _openPaywall(BuildContext context, WidgetRef ref) async {
    final purchased = await ref
        .read(purchasesServiceProvider)
        .presentPaywallIfNeeded(context);

    if (purchased && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Bridge Prime! 👑'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(purchaseNotifierProvider.notifier)
        .restorePurchases();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Prime restored! 👑' : 'No active subscription found.'),
        backgroundColor: ok ? AppColors.success : AppColors.textSecondary,
      ));
    }
  }

  static const _features = [
    (Icons.bolt, 'Instant transfers', 'Interac delivers instantly, not 9 hours'),
    (Icons.trending_up, 'Better exchange rate',
        '+0.5% above standard rate on all corridors'),
    (Icons.money_off, 'Zero transfer fees', '\$0.00 fee on every transfer'),
    (Icons.upload_rounded, 'Higher limits', 'Send up to \$10,000 CAD/month'),
    (Icons.support_agent, 'Priority support', 'Jump the queue for help'),
    (Icons.flag_outlined, 'Early corridor access',
        'Be first to send to new countries'),
  ];
}

// ── Feature row ───────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.infoCard,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Comparison table ──────────────────────────────────────────────────────────

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
          color: AppColors.divider, borderRadius: BorderRadius.circular(8)),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        _headerRow(),
        _row('Exchange rate', 'Standard', '+0.5%'),
        _row('Interac delivery', '~9 hours', 'Instant'),
        _row('Transfer fee', 'Varies', '\$0.00'),
        _row('Monthly limit', '\$3,000', '\$10,000'),
        _row('Priority support', '✗', '✓'),
      ],
    );
  }

  TableRow _headerRow() => TableRow(
        decoration: const BoxDecoration(color: AppColors.surface),
        children: ['Feature', 'Standard', 'Prime']
            .map((t) => Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(t,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ))
            .toList(),
      );

  TableRow _row(String feature, String standard, String prime) => TableRow(
        children: [feature, standard, prime]
            .map((t) => Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(t, style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
      );
}
