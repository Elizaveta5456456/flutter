import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class StickySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String hintText;
  final FocusNode? focusNode;

  static const Color white = Color(0xFFFFFFFF);

  const StickySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'поиск',
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Material(
      color: white,
      elevation: 8,
      shadowColor: Colors.transparent,
      surfaceTintColor: white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: white,
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, top + 12, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmitted?.call(),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 24 / 20,
                  ),
                  cursorColor: AppColors.accent,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: hintText,
                    filled: true,
                    fillColor: white,
                    hoverColor: white,
                    focusColor: white,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintStyle: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppColors.textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 24 / 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onSubmitted,
                child: SvgPicture.asset(
                  AppIcons.search,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StickySearchPage extends StatelessWidget {
  final TextEditingController controller;
  final Widget body;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;

  const StickySearchPage({
    super.key,
    required this.controller,
    required this.body,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    
    final searchHeight = top + 12 + 24 + 10;

    return ColoredBox(
      color: StickySearchBar.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: searchHeight),
              child: ClipRect(child: body),
            ),
          ),
          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: StickySearchBar(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              focusNode: focusNode,
            ),
          ),
        ],
      ),
    );
  }
}
