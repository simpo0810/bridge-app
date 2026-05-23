import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My contacts', style: AppTextStyles.h1),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text('Select favorites'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Add new contact row
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.infoCard,
                child: const Icon(Icons.person_add_outlined, color: AppColors.primary),
              ),
              title: const Text('Add new contact', style: AppTextStyles.body),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () {},
            ),
            const Divider(height: 0),
            // Contacts list — Phase 5 wires to Firestore
            const Expanded(
              child: Center(
                child: Text(
                  'Your contacts will appear here.',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
