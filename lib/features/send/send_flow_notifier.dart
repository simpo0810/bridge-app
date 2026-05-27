import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/contact.dart';
import '../../shared/providers/auth_providers.dart';
import '../../shared/providers/firestore_providers.dart';
import 'send_flow_state.dart';

final sendFlowProvider =
    StateNotifierProvider.autoDispose<SendFlowNotifier, SendFlowState>(
  (ref) => SendFlowNotifier(ref),
);

class SendFlowNotifier extends StateNotifier<SendFlowState> {
  final Ref _ref;

  SendFlowNotifier(this._ref) : super(const SendFlowState());

  // ── Navigation ───────────────────────────────────────────────────────────────

  void nextStep() {
    if (state.step < 6) state = state.copyWith(step: state.step + 1);
  }

  void prevStep() {
    if (state.step > 1) state = state.copyWith(step: state.step - 1);
  }

  void goToStep(int s) => state = state.copyWith(step: s);

  // ── Step 1: Recipient ────────────────────────────────────────────────────────

  void selectContact(Contact contact) {
    state = state.copyWith(selectedContact: contact);
    nextStep();
  }

  // ── Step 2: Amount ───────────────────────────────────────────────────────────

  Future<void> setAmount(double amountCAD) async {
    final isPrime = _ref.read(currentUserProvider).valueOrNull?.isPrime ?? false;
    final corridorId = 'CAD_${state.selectedContact?.country ?? 'KES'}';

    state = state.copyWith(isLoading: true);

    final rate = await _ref.read(firestoreServiceProvider).getRate(corridorId);
    final effectiveRate = isPrime ? rate.primeRate : rate.standardRate;

    state = state.copyWith(
      amountCAD: amountCAD,
      exchangeRate: effectiveRate > 0 ? effectiveRate : rate.rate,
      isLoading: false,
    );
    nextStep();
  }

  // ── Step 3: Delivery method ──────────────────────────────────────────────────

  void setDeliveryMethod(String method, String walletProvider) {
    state = state.copyWith(
      deliveryMethod: method,
      walletProvider: walletProvider,
    );
    nextStep();
  }

  // ── Step 4: Payment method ───────────────────────────────────────────────────

  void selectPaymentMethod(String method, {String? detail}) {
    final isPrime = _ref.read(currentUserProvider).valueOrNull?.isPrime ?? false;

    double fee = 0;
    if (method == 'card') {
      fee = (state.amountCAD ?? 0) * 0.025; // 2.5% for card
    } else if (method == 'interac' && !isPrime) {
      fee = 0;
    } else if (method == 'prime') {
      fee = 0;
    }

    state = state.copyWith(
      paymentMethod: method,
      paymentDetail: detail,
      feeCAD: fee,
    );
    nextStep();
  }

  // ── Step 6: Submit ───────────────────────────────────────────────────────────

  /// Calls the `initiateTransfer` Cloud Function — the client never writes to
  /// Firestore directly. The function validates KYC, fetches the live exchange
  /// rate server-side, and creates the transfer document atomically.
  Future<bool> submitTransfer() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contact = state.selectedContact;
      if (contact == null) throw Exception('No recipient selected');

      final callable =
          FirebaseFunctions.instance.httpsCallable('initiateTransfer');

      await callable.call({
        'amountCAD': state.amountCAD,
        'feeCAD': state.feeCAD ?? 0,
        'deliveryMethod': state.deliveryMethod,
        'paymentMethod': state.paymentMethod,
        'contact': {
          'name': contact.name,
          'phone': contact.phone,
          'country': contact.country,
          'walletProvider': contact.walletProvider,
        },
        'corridorId': 'CAD_${contact.country}',
      });

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseFunctionsException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Transfer could not be submitted. Please try again.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Transfer could not be submitted. Please try again.',
      );
      return false;
    }
  }
}
