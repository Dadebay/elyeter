import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// One tile across the top of a category.
class SubcategoryItem {
  const SubcategoryItem({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String? imageAsset;
}

/// The subcategories, four across and two down, paged sideways.
///
/// A page at a time rather than a free scroll: the rows stay aligned, so the
/// eye reads a block of eight instead of chasing a half-cut tile.
class SubcategoryGrid extends StatefulWidget {
  const SubcategoryGrid({super.key, required this.items, this.onTap});

  static const _columns = 4;
  static const _rows = 2;

  /// The artwork carries its own inset, so the plates want to sit close
  /// together — a wide gutter reads as four loose cards, not a block.
  static const _columnGap = AppSpacing.xs;
  static const _rowGap = AppSpacing.sm;

  /// Tiles on one page.
  static const _perPage = _columns * _rows;

  final List<SubcategoryItem> items;
  final ValueChanged<SubcategoryItem>? onTap;

  @override
  State<SubcategoryGrid> createState() => _SubcategoryGridState();
}

class _SubcategoryGridState extends State<SubcategoryGrid> {
  final _controller = PageController();
  int _page = 0;

  int get _pageCount =>
      (widget.items.length + SubcategoryGrid._perPage - 1) ~/
      SubcategoryGrid._perPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    // The cell is as wide as the row allows, and the plate is square, so the
    // page's height falls out of its width rather than being guessed at.
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell =
            (constraints.maxWidth -
                (SubcategoryGrid._columns - 1) * SubcategoryGrid._columnGap) /
            SubcategoryGrid._columns;
        final labelHeight =
            (context.textTheme.labelSmall?.fontSize ?? 11) * 1.2 * 2 +
            AppSpacing.xs;
        final rows = widget.items.length <= SubcategoryGrid._columns
            ? 1
            : SubcategoryGrid._rows;

        return Column(
          children: [
            // The page has to be told its height: a PageView cannot take it
            // from children the way a Column would.
            SizedBox(
              height:
                  rows * (cell + labelHeight) +
                  (rows - 1) * SubcategoryGrid._rowGap,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, page) => _Page(
                  items: widget.items
                      .skip(page * SubcategoryGrid._perPage)
                      .take(SubcategoryGrid._perPage)
                      .toList(),
                  aspectRatio: cell / (cell + labelHeight),
                  onTap: widget.onTap,
                ),
              ),
            ),
            // Nothing to page through, nothing to say about it.
            if (_pageCount > 1) ...[
              const SizedBox(height: AppSpacing.md),
              _PageDots(count: _pageCount, index: _page),
            ],
          ],
        );
      },
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.items,
    required this.aspectRatio,
    required this.onTap,
  });

  final List<SubcategoryItem> items;

  /// Cell width over cell height — the square plate plus its two label lines.
  final double aspectRatio;

  final ValueChanged<SubcategoryItem>? onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // The PageView above already scrolls; this only lays out.
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: SubcategoryGrid._columns,
        crossAxisSpacing: SubcategoryGrid._columnGap,
        mainAxisSpacing: SubcategoryGrid._rowGap,
        childAspectRatio: aspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _SubcategoryTile(
        item: items[index],
        onTap: onTap == null ? null : () => onTap!(items[index]),
      ),
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({required this.item, this.onTap});

  final SubcategoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = item.imageAsset;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // No plate behind the artwork: each file already carries its own
          // rounded grey one, and a second surface under it only shows as a
          // halo around the first. Square and full width, so the plates sit
          // gutter to gutter instead of floating in their cells.
          AspectRatio(
            aspectRatio: 1,
            child: image == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.grey500,
                    ),
                  )
                : Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Which page of tiles is showing.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            // The current page reads as a bar, the rest as dots.
            width: i == index ? 20 : 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.black : AppColors.grey300,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
