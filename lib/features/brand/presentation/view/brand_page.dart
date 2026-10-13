import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';
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
  @override
  void initState() {
    super.initState();
    getIt<BrandRepository>().bySlug(widget.id).then((result) {
      if (mounted && result.dataOrNull != null) {
        setState(() => _name = result.dataOrNull!.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leadingWidth: AppBackButton.leadingWidth,
      leading: const AppBackButton.appBarLeading(),
      title: Text(_name ?? widget.title ?? widget.id),
    ),
    body: CatalogProductGrid(query: ProductQuery(brandSlug: widget.id)),
  );
}
