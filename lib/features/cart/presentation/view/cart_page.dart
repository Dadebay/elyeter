import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../product/domain/entities/product_detail.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<String, ProductDetail?> _products = {};
  final Set<String> _loading = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMissing());
  }

  void _fetchMissing() {
    if (!mounted) return;
    for (final slug in context.read<CartCubit>().state.quantities.keys) {
      if (_products.containsKey(slug) || !_loading.add(slug)) continue;
      getIt<ProductRepository>().bySlug(slug).then((result) {
        if (mounted) {
          setState(() {
            _products[slug] = result.dataOrNull;
            _loading.remove(slug);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<CartCubit, CartState>(
    listener: (_, _) => _fetchMissing(),
    child: BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        final selected = cart.selectedIds.toList();
        final total = selected.fold<num>(0, (sum, slug) {
          final detail = _products[slug];
          if (detail == null) return sum;
          final variant = detail.variants
              .where((v) => v.id == cart.variants[slug])
              .firstOrNull;
          return sum +
              (variant?.price ?? detail.product.price) * cart.quantityOf(slug);
        });
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.navCart)),
          body: cart.quantities.isEmpty
              ? const Center(
                  child: Icon(Icons.shopping_cart_outlined, size: 72),
                )
              : ListView(
                  children: [
                    for (final slug in cart.quantities.keys)
                      if (_loading.contains(slug))
                        ListTile(
                          title: Text(slug),
                          trailing: const CircularProgressIndicator(),
                        )
                      else if (_products[slug] case final detail?)
                        ListTile(
                          leading: Checkbox(
                            value: cart.isSelected(slug),
                            onChanged: (_) =>
                                context.read<CartCubit>().toggleSelected(slug),
                          ),
                          title: Text(detail.product.name),
                          subtitle: Text(
                            '${detail.product.price} TMT · ${cart.quantityOf(slug)}${cart.variants[slug] == null ? '' : ' · ${detail.variants.where((v) => v.id == cart.variants[slug]).firstOrNull?.label ?? ''}'}',
                          ),
                          onTap: () => context.pushNamed(
                            AppRoutes.productDetail.name,
                            pathParameters: {'id': slug},
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    context.read<CartCubit>().decrease(slug),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${cart.quantityOf(slug)}'),
                              IconButton(
                                onPressed: () =>
                                    context.read<CartCubit>().increase(slug),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              IconButton(
                                onPressed: () =>
                                    context.read<CartCubit>().remove(slug),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        )
                      else
                        ListTile(
                          title: Text(slug),
                          subtitle: const Text('Product unavailable'),
                          trailing: IconButton(
                            onPressed: () =>
                                context.read<CartCubit>().remove(slug),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                  ],
                ),
          bottomNavigationBar: cart.quantities.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      onPressed:
                          selected.isEmpty ||
                              selected.any((s) => _products[s] == null)
                          ? null
                          : () => context.pushNamed(AppRoutes.checkout.name),
                      child: Text(
                        '${context.l10n.commonCheckout} · $total TMT',
                      ),
                    ),
                  ),
                ),
        );
      },
    ),
  );
}
