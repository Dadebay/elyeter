import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../widgets/legal_document_view.dart';

/// Privacy policy — what is collected, why, and for how long.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppPageAppBar(title: l10n.privacyTitle),
      body: LegalDocumentView(
        footer: l10n.legalUpdated('01.09.2025'),
        sections: [
          LegalSection(title: l10n.privacyS1, body: l10n.privacyB1),
          LegalSection(title: l10n.privacyS2, body: l10n.privacyB2),
          LegalSection(title: l10n.privacyS3, body: l10n.privacyB3),
          LegalSection(title: l10n.privacyS4, body: l10n.privacyB4),
          LegalSection(title: l10n.privacyS5, body: l10n.privacyB5),
        ],
      ),
    );
  }
}
