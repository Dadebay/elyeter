import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/product_repository.dart';
import '../widgets/expandable_product_name.dart';
import '../widgets/product_app_bar_actions.dart';
import '../widgets/product_gallery.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  /// The API uses a slug, despite the historical route parameter name.
  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Result<ProductDetail>> _future;
  int? _variantId;

  @override
  void initState() {
    super.initState();
    _future = getIt<ProductRepository>().bySlug(widget.productId);
  }

  void _retry() => setState(
    () => _future = getIt<ProductRepository>().bySlug(widget.productId),
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<Result<ProductDetail>>(
    future: _future,
    builder: (context, snapshot) {
      final detail = snapshot.data?.dataOrNull;
      if (detail == null) {
        return Scaffold(
          appBar: AppBar(
            leadingWidth: AppBackButton.leadingWidth,
            leading: const AppBackButton.appBarLeading(icon: AppIcons.back),
          ),
          body: Center(
            child: snapshot.connectionState != ConnectionState.done
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _retry,
                    child: Text(
                      snapshot.data?.failureOrNull?.message ?? 'Retry',
                    ),
                  ),
          ),
        );
      }
      final product = detail.product;
      final selected = detail.variants
          .where((v) => v.id == _variantId)
          .firstOrNull;
      final price = selected?.price ?? product.price;
      final id = product.slug;
      return Scaffold(
        appBar: AppBar(
          leadingWidth: AppBackButton.leadingWidth,
          leading: const AppBackButton.appBarLeading(icon: AppIcons.back),
          title: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            BlocBuilder<FavoriteCubit, Set<String>>(
              builder: (context, favorites) => ProductAppBarActions(
                favorite: favorites.contains(product.id.toString()),
                onShare: () =>
                    SharePlus.instance.share(ShareParams(text: product.name)),
                onFavorite: () async {
                  if (!context.read<AuthCubit>().state.isAuthenticated) {
                    await promptSignIn(context);
                    return;
                  }
                  if (context.mounted) {
                    await context.read<FavoriteCubit>().toggle(
                      product.id.toString(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            // Room under the app bar, so the photo does not sit tight
            // against it.
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProductGallery(images: detail.gallery),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpandableProductName(
                    name: product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$price TMT',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (detail.variants.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Variant',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final variant in detail.variants)
                          ChoiceChip(
                            label: Text(
                              variant.label.isEmpty
                                  ? variant.sku
                                  : variant.label,
                            ),
                            selected: _variantId == variant.id,
                            onSelected: variant.inStock
                                ? (_) {
                                    setState(() => _variantId = variant.id);
                                    context.read<CartCubit>().setVariant(
                                      id,
                                      variant.id,
                                    );
                                  }
                                : null,
                          ),
                      ],
                    ),
                  ],
                  if (detail.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    Text(
                      context.l10n.productDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Html(
                      data: detail.description!,
                      onLinkTap: (url, _, _) {
                        final uri = Uri.tryParse(url ?? '');
                        if (uri != null &&
                            (uri.scheme == 'https' || uri.scheme == 'http')) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ],
                  if (detail.attributes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    for (final attribute in detail.attributes)
                      ListTile(
                        dense: true,
                        title: Text(attribute.name),
                        trailing: Text(attribute.value),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: product.hasVariants && _variantId == null
                  ? null
                  : () {
                      if (selected != null) {
                        context.read<CartCubit>().setVariant(id, selected.id);
                      }
                      context.read<CartCubit>().toggle(id);
                    },
              child: Text(
                context.watch<CartCubit>().contains(id)
                    ? context.l10n.commonAdded
                    : context.l10n.commonAddToCart,
              ),
            ),
          ),
        ),
      );
    },
  );
}
