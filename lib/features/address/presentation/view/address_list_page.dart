import 'package:flutter/material.dart';

import '../../../../core/widgets/app_page_app_bar.dart';

/// Placeholder — the Addresses UI is built on top of this scaffold.
///
/// The title comes from the route so the same page can serve more than one
/// entry point (active orders and order history, for instance).
class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppPageAppBar(title: title),
      body: const SizedBox.shrink(),
    );
  }
}
