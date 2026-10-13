import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The product's name on the detail page: two lines, and a "Read more" under
/// it only when the name is longer than that.
///
/// Supplier titles can run to a paragraph, and left whole they push the
/// price and the options off the first screen.
class ExpandableProductName extends StatefulWidget {
  const ExpandableProductName({
    super.key,
    required this.name,
    this.style,
    this.collapsedLines = 2,
  });

  final String name;
  final TextStyle? style;
  final int collapsedLines;

  @override
  State<ExpandableProductName> createState() => _ExpandableProductNameState();
}

class _ExpandableProductNameState extends State<ExpandableProductName> {
  bool _expanded = false;

  @override
  void didUpdateWidget(ExpandableProductName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = widget.style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Measured, not guessed: the name is cut at two lines only if laying
        // it out really does run past them at this width.
        final painter = TextPainter(
          text: TextSpan(text: widget.name, style: style),
          maxLines: widget.collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Text(
                widget.name,
                style: style,
                maxLines: _expanded ? null : widget.collapsedLines,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    _expanded ? l10n.productReadLess : l10n.productReadMore,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
