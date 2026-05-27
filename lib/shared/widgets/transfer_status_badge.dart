import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/transfer.dart';

class TransferStatusBadge extends StatelessWidget {
  final TransferStatus status;

  const TransferStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text) = switch (status) {
      TransferStatus.delivered => (
          AppColors.statusDeliveredBg,
          AppColors.statusDeliveredText
        ),
      TransferStatus.processing => (
          AppColors.statusProcessingBg,
          AppColors.statusProcessingText
        ),
      TransferStatus.failed => (
          AppColors.statusFailedBg,
          AppColors.statusFailedText
        ),
      TransferStatus.pending => (
          AppColors.statusPendingBg,
          AppColors.statusPendingText
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
