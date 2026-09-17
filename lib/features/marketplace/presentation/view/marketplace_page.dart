import 'package:flutter/material.dart';

import '../../../../core/widgets/app_back_button.dart';

/// Placeholder — a partner marketplace's storefront is built on top of this
/// scaffold. For now it is the app bar and the back button only.
class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key, required this.id, this.title});

  /// Slug from the route, e.g. `aliexpress`.
  final String id;

  /// Display name passed by the caller; falls back to [id].
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: AppBackButton.leadingWidth,
        leading: const AppBackButton.appBarLeading(),
        title: Text(title ?? id),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
