import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class PageTitleBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const PageTitleBar({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SvgPicture.asset(
                AppIcons.chevronBack,
                width: 10,
                height: 15,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppColors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w700,
                height: 48 / 40,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
