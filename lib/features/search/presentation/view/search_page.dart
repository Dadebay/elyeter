import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/repositories/search_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  SearchSuggestions _suggestions = SearchSuggestions.empty;
  String? _submitted;
  int _request = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _debounce?.cancel();
    final query = value.trim();
    final request = ++_request;
    setState(() {
      _submitted = null;
      _suggestions = SearchSuggestions.empty;
    });
    if (query.length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await getIt<SearchRepository>().suggest(query);
      if (mounted && request == _request) {
        setState(
          () => _suggestions = result.dataOrNull ?? SearchSuggestions.empty,
        );
      }
    });
  }

  void _search(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    _debounce?.cancel();
    ++_request;
    getIt<SearchRepository>().remember(query);
    FocusScope.of(context).unfocus();
    setState(() => _submitted = query);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppPageAppBar(title: context.l10n.searchTitle),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: context.l10n.searchTitle,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onChanged: _changed,
            onSubmitted: _search,
          ),
        ),
        Expanded(
          child: _submitted != null
              ? CatalogProductGrid(query: ProductQuery(search: _submitted))
              : ListView(
                  children: [
                    if (_controller.text.trim().isEmpty)
                      for (final recent
                          in getIt<SearchRepository>().recentSearches())
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(recent),
                          onTap: () {
                            _controller.text = recent;
                            _search(recent);
                          },
                        ),
                    for (final category in _suggestions.categories)
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: Text(category.name),
                        onTap: () => context.pushNamed(
                          AppRoutes.categoryDetail.name,
                          pathParameters: {'id': category.slug},
                          extra: category.name,
                        ),
                      ),
                    for (final product in _suggestions.products)
                      ListTile(
                        leading: product.mainImage == null
                            ? const Icon(Icons.shopping_bag_outlined)
                            : Image.network(
                                product.mainImage!,
                                width: 48,
                                height: 48,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.shopping_bag_outlined),
                              ),
                        title: Text(product.name),
                        subtitle: Text('${product.price} TMT'),
                        onTap: () => context.pushNamed(
                          AppRoutes.productDetail.name,
                          pathParameters: {'id': product.slug},
                        ),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );
}
