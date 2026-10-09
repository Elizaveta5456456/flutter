import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? aboveBar;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.aboveBar,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?aboveBar,
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 20, bottom > 0 ? bottom : 16),
          child: Row(
            children: [
              Expanded(
                child: _TabIcon(
                  asset: currentIndex == 0
                      ? AppIcons.tabSearch
                      : AppIcons.tabSearchInactive,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _TabIcon(
                  asset: currentIndex == 1
                      ? AppIcons.tabCatalogActive
                      : AppIcons.tabCatalog,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _TabIcon(
                  asset: currentIndex == 2
                      ? AppIcons.tabProfileActive
                      : AppIcons.tabProfile,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _TabIcon({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        height: 24,
        child: SvgPicture.asset(
          asset,
          fit: BoxFit.fitHeight,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
