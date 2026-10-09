import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';
import '../theme/app_colors.dart';

class CartButton extends StatelessWidget {
  final bool active;
  final VoidCallback? onTap;
  final double size;

  const CartButton({
    super.key,
    this.active = false,
    this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: active
              ? DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.basketShopping,
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : const _DefaultPlusButton(),
        ),
      ),
    );
  }
}

class _DefaultPlusButton extends StatelessWidget {
  const _DefaultPlusButton();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _PlusButtonPainter(),
    );
  }
}

class _PlusButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    paint.color = AppColors.zinc800;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    final sx = size.width / 36;
    final sy = size.height / 36;
    final path = Path()
      ..moveTo(18.0066 * sx, 24 * sy)
      ..cubicTo(
        17.4713 * sx,
        24 * sy,
        17.0374 * sx,
        23.5661 * sy,
        17.0374 * sx,
        23.0308 * sy,
      )
      ..lineTo(17.0374 * sx, 18.9626 * sy)
      ..lineTo(12.9692 * sx, 18.9626 * sy)
      ..cubicTo(
        12.4339 * sx,
        18.9626 * sy,
        12 * sx,
        18.5287 * sy,
        12 * sx,
        17.9934 * sy,
      )
      ..cubicTo(
        12 * sx,
        17.4581 * sy,
        12.4339 * sx,
        17.0242 * sy,
        12.9692 * sx,
        17.0242 * sy,
      )
      ..lineTo(17.0374 * sx, 17.0242 * sy)
      ..lineTo(17.0374 * sx, 12.9692 * sy)
      ..cubicTo(
        17.0374 * sx,
        12.4339 * sy,
        17.4713 * sx,
        12 * sy,
        18.0066 * sx,
        12 * sy,
      )
      ..cubicTo(
        18.5419 * sx,
        12 * sy,
        18.9758 * sx,
        12.4339 * sy,
        18.9758 * sx,
        12.9692 * sy,
      )
      ..lineTo(18.9758 * sx, 17.0242 * sy)
      ..lineTo(23.0308 * sx, 17.0242 * sy)
      ..cubicTo(
        23.5661 * sx,
        17.0242 * sy,
        24 * sx,
        17.4581 * sy,
        24 * sx,
        17.9934 * sy,
      )
      ..cubicTo(
        24 * sx,
        18.5287 * sy,
        23.5661 * sx,
        18.9626 * sy,
        23.0308 * sx,
        18.9626 * sy,
      )
      ..lineTo(18.9758 * sx, 18.9626 * sy)
      ..lineTo(18.9758 * sx, 23.0308 * sy)
      ..cubicTo(
        18.9758 * sx,
        23.5661 * sy,
        18.5419 * sx,
        24 * sy,
        18.0066 * sx,
        24 * sy,
      )
      ..close();

    paint.color = AppColors.bgPrimary;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
