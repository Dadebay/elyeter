import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Marks a search navigation that starts from the category app bar button.
/// Home passes a plain [Rect] and keeps its field reveal transition.
class SearchButtonOrigin {
  const SearchButtonOrigin(this.bounds);

  final Rect bounds;
}

/// Widens the button into the search field while the page rises from the
/// bottom. The page surface itself never reveals downward from the button.
class SearchButtonExpandTransition extends StatefulWidget {
  const SearchButtonExpandTransition({
    super.key,
    required this.animation,
    required this.buttonBounds,
    required this.child,
  });

  final Animation<double> animation;
  final Rect buttonBounds;
  final Widget child;

  @override
  State<SearchButtonExpandTransition> createState() =>
      _SearchButtonExpandTransitionState();
}

class _SearchButtonExpandTransitionState
    extends State<SearchButtonExpandTransition> {
  static const _expandCurve = Cubic(0.77, 0, 0.175, 1);
  static const _riseCurve = Cubic(0.23, 1, 0.32, 1);

  late Animation<double> _expansion;
  late Animation<Offset> _rise;
  late Animation<double> _surfaceOpacity;

  @override
  void initState() {
    super.initState();
    _configureAnimations();
  }

  void _configureAnimations() {
    _expansion = widget.animation.drive(
      CurveTween(curve: const Interval(0, 0.45, curve: _expandCurve)),
    );
    _rise = widget.animation.drive(
      Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: const Interval(0.28, 1, curve: _riseCurve))),
    );
    _surfaceOpacity = widget.animation.drive(
      Tween<double>(
        begin: 1,
        end: 0,
      ).chain(CurveTween(curve: const Interval(0.78, 1, curve: _riseCurve))),
    );
  }

  @override
  void didUpdateWidget(SearchButtonExpandTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) _configureAnimations();
  }

  @override
  Widget build(BuildContext context) {
    final content = RepaintBoundary(child: widget.child);
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(
        key: const Key('search-button-reduced-fade'),
        opacity: widget.animation,
        child: content,
      );
    }

    final size = MediaQuery.sizeOf(context);
    final fieldLeft = AppSpacing.sm + 48;
    final fieldBounds = Rect.fromLTWH(
      fieldLeft,
      MediaQuery.paddingOf(context).top +
          AppSpacing.sm +
          (kToolbarHeight - 48) / 2,
      (size.width - fieldLeft - AppSpacing.xl).clamp(0.0, double.infinity),
      48,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? AppColors.grey900 : AppColors.white;
    final fieldColor = isDark ? AppColors.surfaceDark : const Color(0xFFF1F1F3);

    return Stack(
      fit: StackFit.expand,
      children: [
        SlideTransition(
          key: const Key('search-button-content-rise'),
          position: _rise,
          child: content,
        ),
        AnimatedBuilder(
          animation: widget.animation,
          builder: (context, _) {
            final progress = _expansion.value;
            final rect = Rect.lerp(widget.buttonBounds, fieldBounds, progress)!;
            return Positioned.fromRect(
              rect: rect,
              child: IgnorePointer(
                child: Opacity(
                  opacity: _surfaceOpacity.value,
                  child: DecoratedBox(
                    key: const Key('search-button-surface'),
                    decoration: BoxDecoration(
                      color: Color.lerp(buttonColor, fieldColor, progress),
                      borderRadius: BorderRadius.circular(rect.height / 2),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Reveals the search panel downward from the tapped field, without resizing
/// its contents on every frame. Closing follows the same path in reverse.
class SearchRevealTransition extends StatefulWidget {
  const SearchRevealTransition({
    super.key,
    required this.animation,
    required this.fieldBounds,
    required this.child,
  });

  // A full-screen reveal needs enough time for its edge to remain visible.
  static const duration = Duration(milliseconds: 400);
  static const reverseDuration = Duration(milliseconds: 500);
  static const reducedMotionDuration = Duration(milliseconds: 160);

  final Animation<double> animation;
  final Rect fieldBounds;
  final Widget child;

  @override
  State<SearchRevealTransition> createState() => _SearchRevealTransitionState();
}

class _SearchRevealTransitionState extends State<SearchRevealTransition> {
  static const _easeExpand = Cubic(0.77, 0, 0.175, 1);
  late CurvedAnimation _progress;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _createProgress();
  }

  void _createProgress() {
    // CurvedAnimation keeps the current curve when a gesture or back tap
    // reverses an unfinished entrance, so the visible edge never jumps.
    _progress = CurvedAnimation(
      parent: widget.animation,
      curve: _easeExpand,
      reverseCurve: _easeExpand.flipped,
    );
    // Finish the crossfade before the reveal, so the moving panel remains
    // distinct from the white sections underneath it.
    _opacity = _progress.drive(CurveTween(curve: const Interval(0, 0.6)));
  }

  @override
  void didUpdateWidget(SearchRevealTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _progress.dispose();
      _createProgress();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final content = RepaintBoundary(child: widget.child);
    if (reduceMotion) {
      return FadeTransition(
        key: const Key('search-reveal-fade'),
        opacity: _progress,
        child: content,
      );
    }
    final clipper = _SearchRevealClipper(widget.fieldBounds, _progress);
    return FadeTransition(
      key: const Key('search-reveal-fade'),
      opacity: _opacity,
      child: CustomPaint(
        painter: _SearchRevealShadow(clipper),
        child: ClipRRect(
          key: const Key('search-reveal-clip'),
          clipper: clipper,
          child: content,
        ),
      ),
    );
  }
}

class _SearchRevealClipper extends CustomClipper<RRect> {
  _SearchRevealClipper(this.fieldBounds, this.progress)
    : super(reclip: progress);
  final Rect fieldBounds;
  final Animation<double> progress;

  @override
  RRect getClip(Size size) {
    final screen = Offset.zero & size;
    final start = fieldBounds.intersect(screen);
    return RRect.fromRectAndRadius(
      Rect.lerp(start, screen, progress.value)!,
      Radius.circular(start.height / 2 * (1 - progress.value)),
    );
  }

  @override
  bool shouldReclip(_SearchRevealClipper oldClipper) =>
      oldClipper.progress != progress || oldClipper.fieldBounds != fieldBounds;
}

/// Separates the moving edge from the page underneath without relayouts.
class _SearchRevealShadow extends CustomPainter {
  _SearchRevealShadow(this.clipper) : super(repaint: clipper.progress);

  final _SearchRevealClipper clipper;

  @override
  void paint(Canvas canvas, Size size) {
    final remaining = 1 - clipper.progress.value;
    if (remaining == 0) return;
    canvas.drawShadow(
      Path()..addRRect(clipper.getClip(size)),
      Colors.black.withValues(alpha: 0.16),
      8 * remaining,
      true,
    );
  }

  @override
  bool shouldRepaint(_SearchRevealShadow oldDelegate) =>
      clipper.shouldReclip(oldDelegate.clipper);
}
