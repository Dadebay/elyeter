import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The soft grey block the detail page groups each section into. The page
/// behind it is white, so the blocks are what carry the tint.
class ProductSectionCard extends StatelessWidget {
  const ProductSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color = AppColors.background,
    this.bordered = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// The block's fill. Defaults to the page's soft grey; pass white for a
  /// control that has to read as raised against it.
  final Color color;

  /// Outlines the block. A white block on the white page needs it to read as
  /// a control rather than as empty space.
  final bool bordered;

  /// Makes the whole card tappable, as the price block is.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      // Shape only: [Material] rejects `shape` and `borderRadius` together.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: bordered ? const BorderSide(color: AppColors.grey300) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The leader between a label and its value, as a spec sheet draws it.
class ProductDottedLine extends StatelessWidget {
  const ProductDottedLine({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 1,
    child: CustomPaint(painter: _DotsPainter()),
  );
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter();

  static const _radius = 0.7;
  static const _step = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.grey300;
    for (var x = 0.0; x < size.width; x += _step) {
      canvas.drawCircle(Offset(x, size.height / 2), _radius, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => false;
}
