import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../home/presentation/view/home_placeholder_data.dart';
import '../model/product_detail_data.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_actions.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_option_picker.dart';
import '../widgets/product_reviews_section.dart';
import '../widgets/product_outline_button.dart';
import '../widgets/product_section_card.dart';

/// A product's own page: photos, options, price, description, specification
/// and reviews, with a sticky add-to-cart bar.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _color = 0;
  String? _size;
  bool _descriptionExpanded = false;
  bool _characteristicsExpanded = false;

  /// Clearance for the sticky bar at the foot of the page.
  static const _bottomInset = 104.0;

  /// Room for the floating back button's shadow above the first photo.
  static const _galleryTopGap = AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final product = HomePlaceholderData.productById(widget.productId);
    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(),
        body: const AppEmptyView(icon: Icons.search_off_rounded),
      );
    }

    final detail = HomePlaceholderData.detailFor(product);
    final size = _size ?? detail.sizes.first;

    return Scaffold(
      // White page, tinted blocks — the inverse of the app's other screens,
      // which is what the design does here.
      backgroundColor: AppColors.white,
      appBar: _AppBar(product: product, article: detail.article),
      body: Stack(
        children: [
          ListView(
            // No horizontal padding: the gallery runs edge to edge and
            // carries its own card margin, so its peeking photo reaches the
            // screen's rim. Everything after it is padded as a block.
            padding: const EdgeInsets.only(top: _galleryTopGap, bottom: _bottomInset),
            children: [
              ProductGallery(images: product.images),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      product.title,
                      style: context.textTheme.headlineSmall?.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _RatingRow(detail: detail),
                    const SizedBox(height: AppSpacing.lg),
                    ProductColorPicker(
                      images: product.images,
                      selected: _color,
                      onSelected: (index) => setState(() => _color = index),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _Label(context.l10n.productColor(detail.colorName)),
                    const SizedBox(height: AppSpacing.lg),
                    ProductSizePicker(
                      sizes: detail.sizes,
                      selected: size,
                      onSelected: (value) => setState(() => _size = value),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _Label(context.l10n.productSize(size)),
                    const SizedBox(height: AppSpacing.xl),
                    // From here down the page is a stack of white cards on
                    // the grey background, so the gaps are the card spacing.
                    _Price(product: product),
                    const SizedBox(height: AppSpacing.md),
                    _ArticleRow(article: detail.article),
                    const SizedBox(height: AppSpacing.md),
                    _Description(
                      text: detail.description,
                      expanded: _descriptionExpanded,
                      onToggle: () =>
                          setState(() => _descriptionExpanded = !_descriptionExpanded),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Characteristics(
                      values: detail.characteristics,
                      expanded: _characteristicsExpanded,
                      onToggle: () => setState(
                        () => _characteristicsExpanded = !_characteristicsExpanded,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ProductReviewsSection(
                      detail: detail,
                      onReadAll: () => context.pushNamed(
                        AppRoutes.productReviews.name,
                        pathParameters: {'id': product.id},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            bottom: AppSpacing.lg,
            child: _StickyAddToCart(product: product),
          ),
        ],
      ),
    );
  }
}

/// Back, share and the favourite toggle — no title, the photo carries the
/// page. The controls float as white discs, which is how they stay readable
/// once the gallery scrolls up behind them.
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.product, required this.article});

  final ProductCardData product;
  final String article;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: AppBackButton.leadingWidth,
      leading: const AppBackButton.appBarLeading(),
      actions: [
        BlocBuilder<FavoriteCubit, Set<String>>(
          buildWhen: (before, after) =>
              before.contains(product.id) != after.contains(product.id),
          builder: (context, favorites) {
            final liked = favorites.contains(product.id);
            return ProductActionPill(
              children: [
                ProductPillButton(
                  asset: AppAssets.iconShare,
                  tint: AppColors.black,
                  horizontalPadding: 6,
                  onTap: () => _share(context),
                ),
                ProductPillButton(
                  // The filled artwork carries its own red; the outline is
                  // tinted to match the other controls.
                  asset: liked ? AppAssets.iconFavoriteFull : AppAssets.iconHeartLine,
                  tint: liked ? null : AppColors.black,
                  onTap: () => context.read<FavoriteCubit>().toggle(product.id),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: AppSpacing.page),
      ],
    );
  }

  /// No share sheet yet: the link goes to the clipboard so it can be pasted
  /// anywhere. Swap this for `share_plus` when that dependency is welcome.
  /// Opens the system share sheet. Copying to the clipboard stays as the
  /// fallback: on a device with nothing to share to, the sheet closes with
  /// `dismissed` and the customer would otherwise be left with nothing.
  Future<void> _share(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;

    final text = '${AppConstants.appName} · ${product.title} · $article';

    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: product.title,
          // iPad anchors the sheet to the widget that opened it.
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      if (result.status == ShareResultStatus.success) return;
    } on Object catch (error, stackTrace) {
      AppLogger.e('share failed', error, stackTrace);
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.productShared)));
  }
}

/// Green score pill, then the review and order counts.
class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.detail});

  final ProductDetailData detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
            child: Text(
              detail.rating.toStringAsFixed(1),
              style: context.textTheme.titleSmall?.copyWith(color: AppColors.white),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            '${context.l10n.productReviewCount(detail.reviewCount)} | '
            '${context.l10n.productOrderCount(detail.orderCount)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.black),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
  );
}

/// Big orange price, with what it was and what that saves beside it. The
/// chevron is the design's affordance for the price breakdown.
class _Price extends StatelessWidget {
  const _Price({required this.product});

  final ProductCardData product;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return ProductSectionCard(
      onTap: () {},
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    CurrencyFormatter.amount(product.price),
                    maxLines: 1,
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppConstants.currencySymbol,
                  style: context.textTheme.labelMedium?.copyWith(color: AppColors.primary),
                ),
                if (discount != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    CurrencyFormatter.amount(product.oldPrice!),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '-$discount%',
                    style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey500, size: 22),
        ],
      ),
    );
  }
}

/// The article number, with a copy button beside it.
class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article});

  final String article;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.productArticle,
                  style: context.textTheme.titleSmall?.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  article,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _CopyButton(article: article),
        ],
      ),
    );
  }
}

/// Puts the article on the clipboard and says so.
class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.article});

  final String article;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _copy(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.productCopy,
                style: context.textTheme.labelLarge?.copyWith(color: AppColors.black),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.copy_rounded, size: 16, color: AppColors.black),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final copied = context.l10n.productCopied;
    await Clipboard.setData(ClipboardData(text: article));
    if (context.mounted) AppSnackBar.show(context, copied);
  }
}

/// Collapsed to a few lines until the customer asks for the rest.
///
/// The link runs on from the last line, as the design draws it. It is a
/// [StatefulWidget] only so the tap recogniser has an owner to dispose it —
/// building one per frame leaks.
class _Description extends StatefulWidget {
  const _Description({required this.text, required this.expanded, required this.onToggle});

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  static const _collapsedLines = 5;

  late final TapGestureRecognizer _tap;

  @override
  void initState() {
    super.initState();
    _tap = TapGestureRecognizer()..onTap = widget.onToggle;
  }

  @override
  void didUpdateWidget(_Description oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tap.onTap = widget.onToggle;
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = context.textTheme.bodyMedium!.copyWith(color: AppColors.grey700);
    final link = body.copyWith(color: AppColors.info);

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productDescription,
            style: context.textTheme.titleMedium?.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) => Text.rich(
                _span(context, constraints.maxWidth, body, link),
                style: body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The paragraph with the link on the end of it.
  ///
  /// Flutter drops any span that falls past `maxLines`, so appending the link
  /// to the full text simply hides it — which is why nothing showed. The text
  /// is measured and cut short here instead, leaving exactly enough room for
  /// the link on the last line.
  TextSpan _span(BuildContext context, double maxWidth, TextStyle body, TextStyle link) {
    final direction = Directionality.of(context);
    final linkSpan = TextSpan(
      text: widget.expanded
          ? '  ${context.l10n.productReadLess}'
          : ' ${context.l10n.productReadMore}...',
      style: link,
      recognizer: _tap,
    );

    if (widget.expanded) {
      return TextSpan(text: widget.text, style: body, children: [linkSpan]);
    }

    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: body),
      maxLines: _collapsedLines,
      textDirection: direction,
    )..layout(maxWidth: maxWidth);

    // Short enough to show whole: no link needed.
    if (!painter.didExceedMaxLines) {
      return TextSpan(text: widget.text, style: body);
    }

    final linkWidth = (TextPainter(text: linkSpan, textDirection: direction)..layout()).width;
    final cut = painter.getPositionForOffset(
      Offset(maxWidth - linkWidth, painter.size.height - painter.preferredLineHeight / 2),
    );
    final end = painter.getOffsetBefore(cut.offset) ?? cut.offset;

    return TextSpan(
      text: '${widget.text.substring(0, end).trimRight()}…',
      style: body,
      children: [linkSpan],
    );
  }
}

/// Label/value rows joined by a dotted leader.
///
/// A preview of the rows with the rest one tap away. The block grows in
/// place rather than opening a dialog: the list belongs to the page, and a
/// dialog only adds a layer to get out of.
class _Characteristics extends StatelessWidget {
  const _Characteristics({
    required this.values,
    required this.expanded,
    required this.onToggle,
  });

  /// Rows shown before the button takes over.
  static const _preview = 8;

  final Map<String, String> values;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final rows = expanded ? values.entries : values.entries.take(_preview);
    final hasMore = values.length > _preview;

    return ProductSectionCard(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.productCharacteristics,
              style: context.textTheme.titleMedium?.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final row in rows)
              ProductCharacteristicRow(label: row.key, value: row.value),
            // Nothing to reveal when the preview already shows everything.
            if (hasMore || expanded) ...[
              const SizedBox(height: AppSpacing.sm),
              ProductOutlineButton(
                label: expanded
                    ? context.l10n.commonClose
                    : context.l10n.productAllCharacteristics,
                onTap: onToggle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One spec line: label, dotted leader, value — all on a single line.
///
/// The two texts are capped at a share of the row rather than made flexible:
/// a flexible value wraps onto a second line the moment it is long, which
/// leaves the leader dangling and the rows uneven.
class ProductCharacteristicRow extends StatelessWidget {
  const ProductCharacteristicRow({super.key, required this.label, required this.value});

  /// Most of the row is the value's, since that is what is being read.
  static const _labelShare = 0.42;
  static const _valueShare = 0.50;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * _labelShare),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                child: ProductDottedLine(),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * _valueShare),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: context.textTheme.bodyMedium?.copyWith(color: AppColors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stays over the page: the one action the page exists for.
///
/// Adding is a gradient pill — the only gradient on the page, which is what
/// makes it read as the primary action. Once the product is in the cart the
/// button steps back to a soft brand tint: still clearly tappable, since
/// tapping takes the product out again, but no longer shouting.
class _StickyAddToCart extends StatelessWidget {
  const _StickyAddToCart({required this.product});

  static const _height = 56.0;

  /// A fixed slot for the tick, so the label does not shift when it appears.
  static const _iconSlot = 24.0;

  final ProductCardData product;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (before, after) =>
          before.contains(product.id) != after.contains(product.id),
      builder: (context, cart) {
        final added = cart.contains(product.id);
        final foreground = added ? AppColors.primary : AppColors.white;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: _height,
          decoration: BoxDecoration(
            gradient: added ? null : AppColors.primaryGradient,
            color: added ? AppColors.primarySoft : null,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: added ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: added
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.read<CartCubit>().toggle(product.id),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (added) ...[
                      SizedBox(
                        width: _iconSlot,
                        height: _iconSlot,
                        child: Icon(Icons.check_rounded, size: 20, color: foreground),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      added ? context.l10n.commonAdded : context.l10n.commonAddToCart,
                      style: context.textTheme.titleSmall?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
