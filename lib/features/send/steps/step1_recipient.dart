import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          onTap: () {
            // TODO: open new contact form
          },
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
