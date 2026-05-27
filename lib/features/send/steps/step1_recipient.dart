import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/corridors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/providers/firestore_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/contact_avatar.dart';
import '../send_flow_notifier.dart';

class Step1Recipient extends ConsumerWidget {
  const Step1Recipient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentContacts = ref.watch(recentContactsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Text('Who are you sending to?', style: AppTextStyles.h1),
        const SizedBox(height: 24),

        // New contact
        _OptionRow(
          leading: const CircleAvatar(
            backgroundColor: AppColors.surface,
            child: Icon(Icons.person_add_outlined, color: AppColors.textSecondary),
          ),
          title: 'New contact',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ProviderScope(
              parent: ProviderScope.containerOf(context),
              child: const _NewContactSheet(),
            ),
          ),
        ),
        const Divider(height: 0),

        // Yourself
        _OptionRow(
          leading: const CircleAvatar(
            backgroundColor: AppColors.surface,
            child: Icon(Icons.person_outline, color: AppColors.textSecondary),
          ),
          title: 'Yourself',
          subtitle: 'Send to a new account',
          onTap: () {
            final user = ref.read(currentUserProvider).valueOrNull;
            if (user == null) return;
            final self = Contact(
              id: 'self_${user.uid}',
              name: user.fullName,
              phone: user.phone,
              country: user.preferredCountry,
              countryEmoji: _emojiForCountry(user.preferredCountry),
              deliveryMethod: 'Bank transfer',
              walletProvider: 'Bank',
            );
            ref.read(sendFlowProvider.notifier).selectContact(self);
          },
        ),

        // Recent contacts
        recentContacts.when(
          data: (contacts) {
            if (contacts.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text('Recent contacts', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                ...contacts.map((c) => _ContactRow(
                      contact: c,
                      onTap: () =>
                          ref.read(sendFlowProvider.notifier).selectContact(c),
                    )),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _emojiForCountry(String code) {
    const map = {
      'KE': '🇰🇪',
      'CD': '🇨🇩',
      'RW': '🇷🇼',
      'NG': '🇳🇬',
      'GH': '🇬🇭',
      'SN': '🇸🇳',
    };
    return map[code] ?? '🌍';
  }
}

class _OptionRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _OptionRow({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading,
      title: Text(title, style: AppTextStyles.body),
      subtitle:
          subtitle != null ? Text(subtitle!, style: AppTextStyles.caption) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _ContactRow extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const _ContactRow({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ContactAvatar(
        initials: contact.initials,
        flagEmoji: contact.countryEmoji,
      ),
      title: Text(contact.name, style: AppTextStyles.body),
      subtitle: Text(contact.walletProvider, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

// ── New Contact Sheet ────────────────────────────────────────────────────────

class _NewContactSheet extends ConsumerStatefulWidget {
  const _NewContactSheet();

  @override
  ConsumerState<_NewContactSheet> createState() => _NewContactSheetState();
}

class _NewContactSheetState extends ConsumerState<_NewContactSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedCountryCode = 'KE';
  String _selectedDeliveryMethod = 'M-Pesa';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  List<String> get _deliveryMethods => kSupportedCorridors
      .firstWhere((c) => c.countryCode == _selectedCountryCode)
      .deliveryMethods;

  String get _flagEmoji => kSupportedCorridors
      .firstWhere((c) => c.countryCode == _selectedCountryCode)
      .flagEmoji;

  void _onCountryChanged(String code) {
    setState(() {
      _selectedCountryCode = code;
      _selectedDeliveryMethod = kSupportedCorridors
          .firstWhere((c) => c.countryCode == code)
          .deliveryMethods
          .first;
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    final uid = ref.read(firebaseAuthStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _saving = true);

    final contact = Contact(
      id: '',
      name: name,
      phone: phone,
      country: _selectedCountryCode,
      countryEmoji: _flagEmoji,
      deliveryMethod: _selectedDeliveryMethod,
      walletProvider: _selectedDeliveryMethod,
      lastUsedAt: DateTime.now(),
    );

    await ref.read(firestoreServiceProvider).saveContact(uid, contact);
    ref.read(sendFlowProvider.notifier).selectContact(contact);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('New contact', style: AppTextStyles.h1),
          const SizedBox(height: 20),

          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone number'),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _selectedCountryCode,
            decoration: const InputDecoration(labelText: 'Country'),
            items: kSupportedCorridors
                .map((c) => DropdownMenuItem(
                      value: c.countryCode,
                      child: Text('${c.flagEmoji}  ${c.countryName}'),
                    ))
                .toList(),
            onChanged: (v) { if (v != null) _onCountryChanged(v); },
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _selectedDeliveryMethod,
            decoration: const InputDecoration(labelText: 'Delivery method'),
            items: _deliveryMethods
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _selectedDeliveryMethod = v); },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save & continue'),
            ),
          ),
        ],
      ),
    );
  }
}
