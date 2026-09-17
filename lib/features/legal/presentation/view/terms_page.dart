import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../widgets/legal_document_view.dart';

/// Terms of use. The copy lives in the ARB files, so it is translated like
/// everything else rather than hard-coded in one language.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppPageAppBar(title: l10n.termsTitle),
      body: LegalDocumentView(
        footer: l10n.legalUpdated('01.09.2025'),
        sections: [
          LegalSection(title: l10n.termsS1, body: l10n.termsB1),
          LegalSection(title: l10n.termsS2, body: l10n.termsB2),
          LegalSection(title: l10n.termsS3, body: l10n.termsB3),
          LegalSection(title: l10n.termsS4, body: l10n.termsB4),
          LegalSection(title: l10n.termsS5, body: l10n.termsB5),
        ],
      ),
    );
  }
}
