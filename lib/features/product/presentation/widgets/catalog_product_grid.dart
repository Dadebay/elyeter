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

/// Server-backed catalogue list shared by category, brand and search.
class CatalogProductGrid extends StatefulWidget {
  const CatalogProductGrid({super.key, required this.query, this.emptyState});

  final ProductQuery query;
  final Widget? emptyState;

  @override
  State<CatalogProductGrid> createState() => _CatalogProductGridState();
}

class _CatalogProductGridState extends State<CatalogProductGrid> {
  Paginated<Product>? _page;
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CatalogProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _page = null;
      _load(force: true);
    }
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
      size: 20,
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
        onRefresh: _load,
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
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          120,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.xl,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.58,
        ),
        itemCount: items.length + ((_page?.hasMore(20) ?? false) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Center(
              child: TextButton(
                onPressed: _loading ? null : () => _load(more: true),
                child: Text(_loading ? '…' : 'More'),
              ),
            );
          }
          final data = ProductCardData.fromProduct(items[index]);
          return BlocBuilder<FavoriteCubit, Set<String>>(
            builder: (context, favorites) => BlocBuilder<CartCubit, CartState>(
              builder: (context, cart) => ProductCard(
                data: data,
                isFavorite: favorites.contains(data.favoriteKey),
                isInCart: cart.contains(data.id),
                onTap: () => context.pushNamed(
                  AppRoutes.productDetail.name,
                  pathParameters: {'id': data.id},
                ),
                onFavoriteTap: () async {
                  if (!context.read<AuthCubit>().state.isAuthenticated) {
                    await promptSignIn(context);
                    return;
                  }
                  if (context.mounted) {
                    await context.read<FavoriteCubit>().toggle(
                      data.favoriteKey,
                    );
                  }
                },
                onAddToCart: () => data.hasVariants
                    ? context.pushNamed(
                        AppRoutes.productDetail.name,
                        pathParameters: {'id': data.id},
                      )
                    : context.read<CartCubit>().toggle(data.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
