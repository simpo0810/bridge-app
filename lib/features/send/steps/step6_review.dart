import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/contact_avatar.dart';
import '../send_flow_notifier.dart';

class Step6Review extends ConsumerWidget {
  const Step6Review({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendFlowProvider);
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final contact = state.selectedContact;
    final currency = _currencyFor(contact?.country);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Text('Review and send', style: AppTextStyles.h1),
        const SizedBox(height: 20),

        // Recipient + payment summary
        if (contact != null)
          _SummaryHeader(
            recipientName: contact.name,
            recipientWallet: contact.walletProvider,
            recipientPhone: contact.phone,
            recipientFlag: contact.countryEmoji,
            recipientInitials: contact.initials,
            paymentMethod: state.paymentMethod ?? '',
            paymentDetail: state.paymentDetail ?? '',
          ),

        const SizedBox(height: 16),

        // Delivery info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.infoCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _deliveryNote(state.paymentMethod ?? '', contact?.country),
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Summary breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Summary', style: AppTextStyles.h3),
            TextButton(
              onPressed: () => ref.read(sendFlowProvider.notifier).goToStep(2),
              child: const Text('Edit amount', style: AppTextStyles.link),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ReviewRow(
            label: 'Amount to send',
            value: 'CAD ${fmt.format(state.amountCAD ?? 0)}'),
        _ReviewRow(
            label: 'Transfer fee',
            value: 'CAD ${fmt.format(state.feeCAD ?? 0)}'),
        const Divider(),
        _ReviewRow(
            label: 'Total cost',
            value: 'CAD ${fmt.format(state.totalCAD)}',
            bold: true),
        _ReviewRow(
            label: 'Total to recipient',
            value: '$currency ${fmt.format(state.amountLocal)}',
            bold: true),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Exchange rate', style: AppTextStyles.caption),
            Text(
              '1 CAD = ${(state.exchangeRate ?? 0).toStringAsFixed(2)} $currency',
              style: AppTextStyles.caption,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Amount & delivery edit section
        _EditSection(
          title: 'Amount & delivery',
          rows: [
            _EditRow(
                label: 'Amount',
                value: 'CAD ${fmt.format(state.amountCAD ?? 0)}',
                onEdit: () =>
                    ref.read(sendFlowProvider.notifier).goToStep(2)),
            _EditRow(
                label: 'They receive',
                value: '$currency ${fmt.format(state.amountLocal)}',
                onEdit: () =>
                    ref.read(sendFlowProvider.notifier).goToStep(2)),
            _EditRow(
                label: 'Delivery method',
                value: state.deliveryMethod ?? '',
                onEdit: () =>
                    ref.read(sendFlowProvider.notifier).goToStep(3)),
          ],
        ),

        const SizedBox(height: 16),
        _EditSection(
          title: 'Payment details',
          rows: [
            _EditRow(
                label: 'Payment method',
                value: _labelForMethod(state.paymentMethod ?? ''),
                onEdit: () =>
                    ref.read(sendFlowProvider.notifier).goToStep(4)),
            if ((state.paymentDetail ?? '').isNotEmpty)
              _EditRow(
                  label: 'Account',
                  value: state.paymentDetail ?? '',
                  onEdit: () =>
                      ref.read(sendFlowProvider.notifier).goToStep(4)),
          ],
        ),

        if (contact != null) ...[
          const SizedBox(height: 16),
          _EditSection(
            title: 'Recipient details',
            rows: [
              _EditRow(
                  label: 'Name',
                  value: contact.name,
                  onEdit: () =>
                      ref.read(sendFlowProvider.notifier).goToStep(1)),
              _EditRow(
                  label: 'Phone',
                  value: contact.phone,
                  onEdit: () =>
                      ref.read(sendFlowProvider.notifier).goToStep(1)),
            ],
          ),
        ],

        const SizedBox(height: 32),

        // Error
        if (ref.watch(sendFlowProvider).error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              state.error!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

        // Submit
        ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  final ok = await ref
                      .read(sendFlowProvider.notifier)
                      .submitTransfer();
                  if (ok && context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transfer submitted successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
          child: state.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Submit transfer'),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'By tapping Submit transfer, you agree to our User Agreement and Privacy Policy.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _deliveryNote(String method, String? country) {
    switch (method) {
      case 'prime':
        return 'Delivers instantly via Bridge Prime';
      case 'interac':
        return 'Delivers within 3 to 4 hours via Interac e-Transfer';
      case 'card':
        return 'Delivers instantly via card';
      case 'bank':
        return 'Delivers in 3 to 6 business days';
      default:
        return 'Delivery time varies';
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
        return 'Bank account';
      default:
        return method;
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

class _SummaryHeader extends StatelessWidget {
  final String recipientName;
  final String recipientWallet;
  final String recipientPhone;
  final String recipientFlag;
  final String recipientInitials;
  final String paymentMethod;
  final String paymentDetail;

  const _SummaryHeader({
    required this.recipientName,
    required this.recipientWallet,
    required this.recipientPhone,
    required this.recipientFlag,
    required this.recipientInitials,
    required this.paymentMethod,
    required this.paymentDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderRow(
          avatar: ContactAvatar(
              initials: recipientInitials, flagEmoji: recipientFlag),
          title: '$recipientName receives with',
          subtitle: '$recipientWallet $recipientPhone',
        ),
        const SizedBox(height: 8),
        _HeaderRow(
          avatar: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.infoCard,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                paymentMethod == 'interac' ? '⚡' : '💳',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: "You're paying with",
          subtitle: _labelFor(paymentMethod),
          extra: paymentDetail,
        ),
      ],
    );
  }

  String _labelFor(String m) {
    switch (m) {
      case 'prime':
        return 'Bridge Prime';
      case 'interac':
        return 'Interac e-Transfer';
      case 'card':
        return 'Debit / Credit card';
      case 'bank':
        return 'Bank account';
      default:
        return m;
    }
  }
}

class _HeaderRow extends StatelessWidget {
  final Widget avatar;
  final String title;
  final String subtitle;
  final String? extra;

  const _HeaderRow({
    required this.avatar,
    required this.title,
    required this.subtitle,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        avatar,
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption),
            Text(subtitle, style: AppTextStyles.body),
            if (extra != null) Text(extra!, style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _ReviewRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold ? AppTextStyles.h3 : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTextStyles.h3 : AppTextStyles.body),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _EditSection extends StatelessWidget {
  final String title;
  final List<_EditRow> rows;

  const _EditSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _EditRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _EditRow(
      {required this.label, required this.value, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(minimumSize: const Size(0, 32)),
            child: const Text('Edit', style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }
}
