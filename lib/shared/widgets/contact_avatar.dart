import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ContactAvatar extends StatelessWidget {
  final String initials;
  final String flagEmoji;
  final double radius;

  const ContactAvatar({
    super.key,
    required this.initials,
    required this.flagEmoji,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.avatarBg,
          child: Text(
            initials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.7,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -4,
          child: Text(flagEmoji, style: TextStyle(fontSize: radius * 0.65)),
        ),
      ],
    );
  }
}
