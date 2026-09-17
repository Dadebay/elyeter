import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';

/// Placeholder — the Search UI is built on top of this scaffold.
///
/// The header is the shared one already, so the page arrives with the app's
/// own back control rather than Material's default arrow.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppPageAppBar(title: context.l10n.searchTitle),
      body: const SizedBox.shrink(),
    );
  }
}
