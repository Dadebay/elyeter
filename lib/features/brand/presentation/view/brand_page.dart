import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../category/presentation/widgets/category_search_button.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';
import '../../../search/presentation/widgets/search_reveal_transition.dart';
import '../../domain/repositories/brand_repository.dart';

class BrandPage extends StatefulWidget {
  const BrandPage({super.key, required this.id, this.title});
  final String id;
  final String? title;

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  String? _name;
  int? get _brandId => int.tryParse(widget.id);

  @override
  void initState() {
    super.initState();
    final id = _brandId;
    if (id != null) {
      getIt<BrandRepository>().byId(id).then((result) {
        if (mounted && widget.id == id.toString() && result.dataOrNull != null) {
          setState(() => _name = result.dataOrNull!.name);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leadingWidth: AppBackButton.leadingWidth,
      leading: const AppBackButton.appBarLeading(),
      titleSpacing: 0,
      centerTitle: true,
      title: Text(
        _name ?? widget.title ?? widget.id,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        CategorySearchButton(
          tooltip: context.l10n.categorySearch,
          onPressed: (bounds) => context.pushNamed(
            AppRoutes.search.name,
            extra: SearchButtonOrigin(bounds),
          ),
        ),
      ],
    ),
    body: _brandId != null
        ? CatalogProductGrid(query: ProductQuery(brandId: _brandId!))
        : const AppErrorView(failure: NotFoundFailure()),
  );
}
