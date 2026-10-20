import 'package:flutter/material.dart';

/// Counts from whatever [value] was to what it is now, rather than jumping:
/// change a quantity and the price runs up (or down) to its new figure. The
/// first time it is built it simply shows [value] — nothing to count from.
///
/// [builder] gets the whole number to show on each frame, so the caller keeps
/// control of formatting and style.
class CountingNumber extends StatelessWidget {
  const CountingNumber({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 700),
  });

  final num value;
  final Widget Function(num shown) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // With reduced motion the figure just changes.
    final effective = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: effective,
      curve: Curves.easeOutCubic,
      builder: (context, shown, _) => builder(shown.round()),
    );
  }
}
