import 'package:flutter/material.dart';

/// The layer that rises over the category page while it is being searched.
///
/// Its top edge climbs from the bottom of the page to the app bar as [open]
/// turns true, and falls back when it turns false. [child] is laid out at the
/// full height the whole time and only revealed, so the list does not squash
/// while the panel is growing.
class CategorySearchResults extends StatelessWidget {
  const CategorySearchResults({
    super.key,
    required this.open,
    required this.child,
  });

  static const duration = Duration(milliseconds: 420);

  final bool open;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: open ? 1 : 0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        // Fully down: nothing to draw, and nothing to take taps or load data.
        if (value == 0) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;

            return ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: height * value,
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: height,
                    maxHeight: height,
                    child: DecoratedBox(
                      // Square-cornered: the panel is a page, not a card.
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SizedBox(height: height, child: child),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
