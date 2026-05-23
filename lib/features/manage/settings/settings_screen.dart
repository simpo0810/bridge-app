import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _smsNotifications = true;
  bool _appNotifications = false;
  bool _emailMarketing = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSetting();
  }

  Future<void> _loadBiometricSetting() async {
    final enabled = await ref.read(authServiceProvider).isBiometricEnabled();
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  Future<void> _toggleBiometric(bool val) async {
    await ref.read(authServiceProvider).setBiometricEnabled(val);
    setState(() => _biometricEnabled = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SettingsRow(
            title: 'Language',
            trailing: const Text('English',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
            onTap: () {},
          ),
          const Divider(height: 0),
          const _SettingsRow(
            title: 'Sending to Kenya',
            trailing: Text('🇰🇪', style: TextStyle(fontSize: 22)),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Profile activity', style: AppTextStyles.h3),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            value: _smsNotifications,
            onChanged: (val) => setState(() => _smsNotifications = val),
            title: const Text('SMS notifications', style: AppTextStyles.body),
            subtitle: const Text(
                'Receive SMS notifications if we detect unusual activity in your profile.',
                style: AppTextStyles.caption),
            activeThumbColor: AppColors.primary,
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Marketing', style: AppTextStyles.h3),
          ),
          SwitchListTile(
            value: _appNotifications,
            onChanged: (val) => setState(() => _appNotifications = val),
            title: const Text('App notifications', style: AppTextStyles.body),
            activeThumbColor: AppColors.primary,
          ),
          const Divider(height: 0),
          SwitchListTile(
            value: _emailMarketing,
            onChanged: (val) => setState(() => _emailMarketing = val),
            title: const Text('Emails', style: AppTextStyles.body),
            activeThumbColor: AppColors.primary,
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Security', style: AppTextStyles.h3),
          ),
          SwitchListTile(
            value: _biometricEnabled,
            onChanged: _toggleBiometric,
            title: const Text('Sign in with Face ID / Biometrics',
                style: AppTextStyles.body),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: AppTextStyles.body),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
