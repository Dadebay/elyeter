import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_card.dart';
import 'product_card_actions.dart';

/// Server-backed catalogue list shared by category, brand and search.
class CatalogProductGrid extends StatefulWidget {
  const CatalogProductGrid({
    super.key,
    required this.query,
    this.emptyState,
    this.pageSize = 20,
  });

  final ProductQuery query;
  final Widget? emptyState;
  final int pageSize;

  @override
  State<CatalogProductGrid> createState() => _CatalogProductGridState();
}

class _CatalogProductGridState extends State<CatalogProductGrid> {
  Paginated<Product>? _page;
  bool _loading = false;
  String? _error;
  int _requestId = 0;
  bool _prefetchScheduled = false;
  final Set<int> _revealedProductIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CatalogProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.pageSize != widget.pageSize) {
      _page = null;
      _revealedProductIds.clear();
      _load(force: true);
    }
  }

  /// On a ten-item page, start the next request as the fifth card appears.
  int get _prefetchDistance => widget.pageSize ~/ 2 + 1;

  void _prefetchWhenVisible(int index, int itemCount) {
    if (index < itemCount - _prefetchDistance ||
        _prefetchScheduled ||
        _loading ||
        _error != null ||
        !(_page?.hasMore(widget.pageSize) ?? false)) {
      return;
    }
    _prefetchScheduled = true;
    final page = _page!.page;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchScheduled = false;
      if (mounted &&
          _page?.page == page &&
          !_loading &&
          _error == null &&
          (_page?.hasMore(widget.pageSize) ?? false)) {
        _load(more: true);
      }
    });
  }

  Future<void> _load({bool more = false, bool force = false}) async {
    if (_loading && !force) return;
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await getIt<ProductRepository>().list(
      query: widget.query,
      page: more ? (_page?.page ?? 0) + 1 : 1,
      size: widget.pageSize,
    );
    if (!mounted || requestId != _requestId) return;
    setState(() {
      if (result.dataOrNull case final data?) {
        _page = more && _page != null ? _page!.merge(data) : data;
      }
      _error = result.failureOrNull?.message;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_page == null && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_page == null && _error != null) {
      return Center(
        child: TextButton(onPressed: _load, child: Text(_error!)),
      );
    }
    final items = _page?.items ?? const <Product>[];
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: widget.emptyState ?? const AppEmptyView(),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(force: true),
      child: CustomScrollView(
        key: ValueKey((widget.query, widget.pageSize)),
        cacheExtent: 0,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              0,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.57,
              ),
              delegate: SliverChildBuilderDelegate(childCount: items.length, (
                context,
                index,
              ) {
                _prefetchWhenVisible(index, items.length);
                final data = ProductCardData.fromProduct(items[index]);
                return _ProductEntrance(
                  key: ValueKey(items[index].id),
                  productId: items[index].id,
                  column: index % 2,
                  revealedIds: _revealedProductIds,
                  child: BlocBuilder<FavoriteCubit, Set<String>>(
                    builder: (context, favorites) =>
                        BlocBuilder<CartCubit, CartState>(
                          builder: (context, cart) => ProductCard(
                            data: data,
                            isFavorite: favorites.contains(data.favoriteKey),
                            isInCart: cart.contains(data.id),
                            onTap: () => context.pushNamed(
                              AppRoutes.productDetail.name,
                              pathParameters: {'id': data.id},
                            ),
                            onFavoriteTap: () async {
                              if (!context
                                  .read<AuthCubit>()
                                  .state
                                  .isAuthenticated) {
                                await promptSignIn(context);
                                return;
                              }
                              if (context.mounted) {
                                await context.read<FavoriteCubit>().toggle(
                                  data.favoriteKey,
                                );
                              }
                            },
                            onAddToCart: () =>
                                toggleCartFromCard(context, data),
                          ),
                        ),
                  ),
                );
              }),
            ),
          ),
          SliverToBoxAdapter(
            child: _Footer(state: this, itemCount: items.length),
          ),
        ],
      ),
    );
  }
}

/// Under the last card: a spinner while the next page is on its way, or the
/// way to try again if it failed. Nothing once everything is loaded — and
/// room for the floating navigation bar either way.
class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.itemCount});

  /// Bottom clearance for the floating navigation bar.
  static const _clearance = 120.0;

  final _CatalogProductGridState state;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final hasMore = state._page?.hasMore(state.widget.pageSize) ?? false;

    Widget content = const SizedBox.shrink();
    if (hasMore && state._error != null) {
      content = TextButton(
        onPressed: () => state._load(more: true),
        child: Text(state._error!),
      );
    } else if (hasMore) {
      // Not the place to ask for the next page: a sliver outside the lazy
      // grid is built at once, not when it scrolls into view. The cards
      // near the end ask for it (see `_prefetchWhenVisible`).
      content = const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: _clearance),
      child: Center(child: content),
    );
  }
}

/// How a card arrives as it scrolls into the lazily built grid: it rises
/// into place, grows from slightly smaller and fades in, the right-hand card
/// a beat after the left, so a row unfolds rather than appears.
///
/// Only the first time a card is built: scrolling back up over cards already
/// seen shows them as they are, and a reduced-motion setting skips it all.
class _ProductEntrance extends StatefulWidget {
  const _ProductEntrance({
    super.key,
    required this.productId,
    required this.column,
    required this.revealedIds,
    required this.child,
  });

  final int productId;

  /// 0 or 1: the right-hand card's animation starts [_stagger] later.
  final int column;
  final Set<int> revealedIds;
  final Widget child;

  @override
  State<_ProductEntrance> createState() => _ProductEntranceState();
}

class _ProductEntranceState extends State<_ProductEntrance>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 520);
  static const _stagger = Duration(milliseconds: 90);
  static const _rise = 40.0;
  static const _startScale = 0.92;

  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final bool _firstAppearance;

  @override
  void initState() {
    super.initState();
    _firstAppearance = widget.revealedIds.add(widget.productId);
    final delay = _stagger * widget.column;
    final total = _duration + delay;
    _controller = AnimationController(
      vsync: this,
      duration: total,
      value: _firstAppearance ? 0 : 1,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstAppearance &&
        _controller.value == 0 &&
        !_controller.isAnimating) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _progress,
    child: widget.child,
    builder: (context, child) {
      final t = _progress.value;
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, _rise * (1 - t)),
          child: Transform.scale(
            scale: _startScale + (1 - _startScale) * t,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
      );
    },
  );
}
