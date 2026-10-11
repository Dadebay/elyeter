import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/repositories/pre_order_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    final items = (_page?.items ?? const <PreOrder>[])
        .where((o) => !widget.activeOnly || o.status.isActive)
        .toList();
    return Scaffold(
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
                            height:
                                constraints.maxHeight -
                                ((_page?.hasMore(20) ?? false) ? 48 : 0),
                            child: _EmptyOrders(activeOnly: widget.activeOnly),
                          ),
                          if (_page?.hasMore(20) ?? false)
                            Center(
                              child: TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => _load(more: true),
                                child: Text(_loading ? '…' : 'More'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        for (final order in items)
                          ListTile(
                            title: Text(order.number),
                            subtitle: Text(
                              '${order.status.value} · ${order.itemsCount} items',
                            ),
                            trailing: Text(
                              '${order.totalPrice.toStringAsFixed(2)} ${order.currency}',
                            ),
                            onTap: () => context.pushNamed(
                              AppRoutes.orderDetail.name,
                              pathParameters: {'id': order.id.toString()},
                            ),
                          ),
                        if (_page?.hasMore(20) ?? false)
                          Center(
                            child: TextButton(
                              onPressed: _loading
                                  ? null
                                  : () => _load(more: true),
                              child: Text(_loading ? '…' : 'More'),
                            ),
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
