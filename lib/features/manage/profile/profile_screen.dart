import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/providers/auth_providers.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile information'),
      ),
      body: userAsync.when(
        data: (user) => user == null
            ? const Center(child: Text('No user data.'))
            : _ProfileBody(user: user),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final AppUser user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (user.kycStatus == KycStatus.verified) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.statusDeliveredBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your profile is now verified',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              fontSize: 14)),
                      Text('Now you can send more with Bridge.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Personal information
        const Text('Personal information', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        _InfoRow(
          label: user.fullName,
          verified: user.kycStatus == KycStatus.verified,
        ),
        const Divider(height: 0),
        if (user.dateOfBirth != null)
          _InfoRow(
            label: DateFormat('MMM d, yyyy').format(user.dateOfBirth!),
            verified: user.kycStatus == KycStatus.verified,
          ),

        const SizedBox(height: 28),

        // Contact information
        const Text('Contact information', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        if (user.address != null)
          _EditableRow(
            label: user.address.toString(),
            onTap: () {},
          ),
        const Divider(height: 0),
        _EditableRow(label: user.phone, onTap: () {}),
        const Divider(height: 0),
        _EditableRow(label: user.email, onTap: () {}),
        const Divider(height: 0),
        _EditableRow(label: 'Password', onTap: () {}),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final bool verified;

  const _InfoRow({required this.label, required this.verified});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          if (verified)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.check_circle, color: AppColors.success, size: 18),
            ),
          Text(label, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EditableRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.body),
      trailing: TextButton(
        onPressed: onTap,
        child: const Text('Edit', style: AppTextStyles.link),
      ),
    );
  }
}
