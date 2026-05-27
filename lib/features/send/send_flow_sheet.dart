import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'send_flow_notifier.dart';
import 'steps/step1_recipient.dart';
import 'steps/step2_amount.dart';
import 'steps/step3_delivery.dart';
import 'steps/step4_payment_method.dart';
import 'steps/step5_confirm_payment.dart';
import 'steps/step6_review.dart';

class SendFlowSheet extends ConsumerWidget {
  const SendFlowSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendFlowProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.93,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Header row: back | logo | close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (state.step > 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => ref.read(sendFlowProvider.notifier).prevStep(),
                  )
                else
                  const SizedBox(width: 48),
                const Spacer(),
                // Bridge logo mark
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Progress bar
          _StepProgressBar(currentStep: state.step, totalSteps: 6),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(state.step),
                child: _stepWidget(state.step, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepWidget(int step, BuildContext context) {
    switch (step) {
      case 1:
        return const Step1Recipient();
      case 2:
        return const Step2Amount();
      case 3:
        return const Step3Delivery();
      case 4:
        return const Step4PaymentMethod();
      case 5:
        return const Step5ConfirmPayment();
      case 6:
        return const Step6Review();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final active = i < currentStep;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
