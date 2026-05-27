import '../../shared/models/contact.dart';

/// Immutable state for the entire 6-step send flow.
/// Held in a Riverpod StateNotifier — never mutated in place.
class SendFlowState {
  final int step; // 1–6
  final Contact? selectedContact;
  final double? amountCAD;
  final String? deliveryMethod;
  final String? walletProvider;
  final String? paymentMethod; // 'prime' | 'interac' | 'bank' | 'card'
  final String? paymentDetail; // masked email, last4, etc.
  final double? exchangeRate;
  final double? feeCAD;
  final bool isLoading;
  final String? error;

  const SendFlowState({
    this.step = 1,
    this.selectedContact,
    this.amountCAD,
    this.deliveryMethod,
    this.walletProvider,
    this.paymentMethod,
    this.paymentDetail,
    this.exchangeRate,
    this.feeCAD,
    this.isLoading = false,
    this.error,
  });

  double get totalCAD => (amountCAD ?? 0) + (feeCAD ?? 0);
  double get amountLocal => (amountCAD ?? 0) * (exchangeRate ?? 0);

  SendFlowState copyWith({
    int? step,
    Contact? selectedContact,
    double? amountCAD,
    String? deliveryMethod,
    String? walletProvider,
    String? paymentMethod,
    String? paymentDetail,
    double? exchangeRate,
    double? feeCAD,
    bool? isLoading,
    String? error,
  }) =>
      SendFlowState(
        step: step ?? this.step,
        selectedContact: selectedContact ?? this.selectedContact,
        amountCAD: amountCAD ?? this.amountCAD,
        deliveryMethod: deliveryMethod ?? this.deliveryMethod,
        walletProvider: walletProvider ?? this.walletProvider,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentDetail: paymentDetail ?? this.paymentDetail,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        feeCAD: feeCAD ?? this.feeCAD,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}
