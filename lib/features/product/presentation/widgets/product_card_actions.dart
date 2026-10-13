import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/repositories/product_repository.dart';
import '../model/variant_options.dart';
import 'product_card.dart';

/// What the card's cart button does: add the product, or take it out again —
/// without leaving the list.
///
/// Every product here has variants, and checkout needs one, so the first
/// variant in stock is chosen for the customer; they can change it from the
/// cart or the product's page. Only when that cannot be settled — the
/// variants will not load, or every one is sold out — is the product's page
/// opened instead, so the reason is in front of them rather than a button
/// that silently does nothing.
Future<void> toggleCartFromCard(
  BuildContext context,
  ProductCardData data,
) async {
  final cart = context.read<CartCubit>();
  final router = GoRouter.of(context);

  void openProduct() => router.pushNamed(
    AppRoutes.productDetail.name,
    pathParameters: {'id': data.id},
  );

  if (cart.contains(data.id) || !data.hasVariants || data.apiId == null) {
    cart.toggle(data.id);
    return;
  }

  final result = await getIt<ProductRepository>().variants(data.apiId!);
  final variant = VariantOptions(result.dataOrNull ?? const []).initial();
  if (variant == null || !variant.inStock) {
    openProduct();
    return;
  }
  cart.setVariant(data.id, variant.id);
  cart.toggle(data.id);
}
