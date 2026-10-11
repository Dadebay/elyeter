import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../product/presentation/widgets/product_image_view.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/repositories/pre_order_repository.dart';
import '../widgets/order_card.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({
    super.key,
    required this.title,
    this.activeOnly = false,
  });
  final String title;
  final bool activeOnly;

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  Paginated<PreOrder>? _page;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    // Multi-status filtering is not yet deployed. Fetch unfiltered pages and
    // partition locally so active and archived lists stay correct.
    final result = await getIt<PreOrderRepository>().list(
      page: more ? (_page?.page ?? 0) + 1 : 1,
      size: 20,
    );
    if (!mounted) return;
    setState(() {
      if (result.dataOrNull case final page?) {
        _page = more && _page != null ? _page!.merge(page) : page;
      }
      _error = result.failureOrNull?.message;
      _loading = false;
    });
  }

  /// Half a page from the end, the next one is asked for — the list simply
  /// keeps going, with no button to press.
  static const _prefetch = 6;

  void _prefetchWhenVisible(int index, int count) {
    if (index < count - _prefetch || _loading || _error != null) return;
    if (!(_page?.hasMore(20) ?? false)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_loading && _error == null) _load(more: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = (_page?.items ?? const <PreOrder>[])
        .where((o) => !widget.activeOnly || o.status.isActive)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPageAppBar(title: widget.title),
      body: _page == null && _loading
          ? const Center(child: CircularProgressIndicator())
          : _page == null && _error != null
          ? Center(
              child: TextButton(onPressed: _load, child: Text(_error!)),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? LayoutBuilder(
                      builder: (context, constraints) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: constraints.maxHeight,
                            child: _EmptyOrders(activeOnly: widget.activeOnly),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        AppSpacing.xxxl,
                      ),
                      // One extra row for the loader or the retry.
                      itemCount:
                          items.length +
                          ((_page?.hasMore(20) ?? false) ? 1 : 0),
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Center(
                              child: _error == null
                                  ? const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: () => _load(more: true),
                                      child: Text(_error!),
                                    ),
                            ),
                          );
                        }
                        _prefetchWhenVisible(index, items.length);
                        final order = items[index];
                        return _OrderTile(
                          order: order,
                          onTap: () => context.pushNamed(
                            AppRoutes.orderDetail.name,
                            pathParameters: {'id': order.id.toString()},
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

/// One order in the list: its number and where it stands, a strip of what is
/// in it, and what it came to.
class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order, required this.onTap});

  static const _thumb = 44.0;
  static const _maxThumbs = 4;

  final PreOrder order;
  final VoidCallback onTap;

  (String, Color, Color) _status(BuildContext context) {
    final l10n = context.l10n;
    return switch (order.status) {
      PreOrderStatus.newOrder => (
        l10n.orderStatusNew,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      PreOrderStatus.confirmed => (
        l10n.orderStatusConfirmed,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      PreOrderStatus.ordered => (
        l10n.orderStatusOrdered,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      PreOrderStatus.completed => (
        l10n.orderStatusCompleted,
        AppColors.success,
        const Color(0xFFE9F8F0),
      ),
      PreOrderStatus.cancelled => (
        l10n.orderStatusCancelled,
        AppColors.error,
        AppColors.errorSoft,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    final (label, color, soft) = _status(context);
    final locale = Localizations.localeOf(context).toString();
    final date = order.createdAt == null
        ? null
        : DateFormat('MMM d, HH:mm', locale).format(order.createdAt!);
    final shown = order.items.take(_maxThumbs).toList();
    final hidden = order.items.length - shown.length;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: OrderCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleSmall?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    child: Text(
                      label,
                      style: theme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (date != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                date,
                style: theme.labelSmall?.copyWith(color: AppColors.grey500),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (final item in shown) ...[
                  Container(
                    width: _thumb,
                    height: _thumb,
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: item.image == null
                        ? const HugeIcon(
                            icon: AppIcons.image,
                            size: 18,
                            color: AppColors.grey500,
                          )
                        : ProductImageView(
                            source: item.image!,
                            fallbackIconSize: 18,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (hidden > 0)
                  Container(
                    width: _thumb,
                    height: _thumb,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '+$hidden',
                      style: theme.labelLarge?.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${CurrencyFormatter.amount(order.totalPrice)} ${order.currency}',
                      style: theme.titleMedium?.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.l10n.orderItemCount(order.itemsCount),
                      style: theme.labelSmall?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.activeOnly});

  final bool activeOnly;

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.translate(
      offset: const Offset(0, -kToolbarHeight / 2 - AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 160,
              child: Image.asset(
                'assets/images/order_history_empty_3d_cutout.png',
                fit: BoxFit.contain,
                semanticLabel: activeOnly
                    ? context.l10n.activeOrdersEmptyTitle
                    : context.l10n.orderHistoryEmptyTitle,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              activeOnly
                  ? context.l10n.activeOrdersEmptyTitle
                  : context.l10n.orderHistoryEmptyTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              activeOnly
                  ? context.l10n.activeOrdersEmptyMessage
                  : context.l10n.orderHistoryEmptyMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontFamily: AppTypography.fontFamily,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
