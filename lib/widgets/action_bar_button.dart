import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ActionBarButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool active;

  static const Color _text = Color(0xFFFAFAFA);

  const ActionBarButton({
    super.key,
    required this.label,
    this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.textPrimary : AppColors.accent,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: _text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 24 / 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
