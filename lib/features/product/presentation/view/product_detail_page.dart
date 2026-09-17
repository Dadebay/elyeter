import 'package:flutter/material.dart';

/// Placeholder — the product detail UI is built on top of this scaffold.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(child: Text('Product $productId')),
    );
  }
}
