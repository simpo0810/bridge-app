import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../send_flow_notifier.dart';

class Step2Amount extends ConsumerStatefulWidget {
  const Step2Amount({super.key});

  @override
  ConsumerState<Step2Amount> createState() => _Step2AmountState();
}

class _Step2AmountState extends ConsumerState<Step2Amount> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _parsed => double.tryParse(_ctrl.text.replaceAll(',', '')) ?? 0;

  Future<void> _continue() async {
    final amount = _parsed;
    if (amount <= 0) return;
    setState(() => _loading = true);
    await ref.read(sendFlowProvider.notifier).setAmount(amount);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendFlowProvider);
    final contact = state.selectedContact;
    final rate = state.exchangeRate ?? 0;
    final recipientAmount = _parsed * rate;
    final currency = contact?.country == 'KE'
        ? 'KES'
        : contact?.country == 'CD'
            ? 'CDF'
            : contact?.country == 'RW'
                ? 'RWF'
                : contact?.country == 'NG'
                    ? 'NGN'
                    : contact?.country == 'GH'
                        ? 'GHS'
                        : 'XOF';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact != null) ...[
            Text('Sending to ${contact.name}', style: AppTextStyles.h1),
            const SizedBox(height: 4),
            Text('${contact.countryEmoji} ${contact.walletProvider}',
                style: AppTextStyles.bodySecondary),
          ] else
            const Text('Enter amount', style: AppTextStyles.h1),

          const SizedBox(height: 32),

          // CAD input
          _CurrencyField(
            label: 'You send',
            currency: 'CAD',
            flag: '🇨🇦',
            controller: _ctrl,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 12),

          // Recipient preview
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
                      const Text('They receive', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        recipientAmount > 0
                            ? NumberFormat('#,##0.00', 'en_US')
                                .format(recipientAmount)
                            : '0.00',
                        style: AppTextStyles.amountMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${contact?.countryEmoji ?? ''} $currency',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),

          if (rate > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '1 CAD = ${rate.toStringAsFixed(2)} $currency',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],

          const Spacer(),

          ElevatedButton(
            onPressed: _parsed > 0 && !_loading ? _continue : null,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _CurrencyField extends StatelessWidget {
  final String label;
  final String currency;
  final String flag;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CurrencyField({
    required this.label,
    required this.currency,
    required this.flag,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(currency, style: AppTextStyles.body),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                autofocus: true,
                style: AppTextStyles.amountMedium,
                decoration: const InputDecoration(hintText: '0.00'),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
