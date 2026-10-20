import 'package:flutter/material.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../widgets/static_page_content.dart';

class StaticPageView extends StatefulWidget {
  const StaticPageView({super.key, required this.slug});
  final String slug;
  @override
  State<StaticPageView> createState() => _StaticPageViewState();
}

class _StaticPageViewState extends State<StaticPageView> {
  late Future<StaticPage> _future;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = getIt<ShopApi>().page(widget.slug);

  @override
  Widget build(BuildContext context) => FutureBuilder<StaticPage>(
    future: _future,
    builder: (context, snapshot) {
      final l10n = context.l10n;
      final fallbackTitle = switch (widget.slug) {
        'about' => l10n.profileAboutApp,
        'faq' => l10n.profileFaq,
        'terms' => l10n.profileTerms,
        'privacy' => l10n.profilePrivacy,
        _ => widget.slug,
      };
      final page = snapshot.data;
      final body = page?.body?.trim();
      final error = snapshot.error;

      return Scaffold(
        appBar: AppPageAppBar(
          title: page?.title.isNotEmpty == true ? page!.title : fallbackTitle,
        ),
        body: snapshot.connectionState != ConnectionState.done
            ? const Center(child: AppLoader())
            : error != null && error is! NotFoundException
            ? AppErrorView(
                failure: error is AppException
                    ? error.toFailure()
                    : const UnknownFailure(),
                onRetry: () => setState(_load),
              )
            : body == null || body.isEmpty
            ? switch (widget.slug) {
                'about' => _IllustratedEmptyView(
                  title: l10n.profileAboutApp,
                  assetPath: 'assets/images/about_empty_3d.png',
                ),
                'faq' => _IllustratedEmptyView(
                  title: l10n.profileFaq,
                  assetPath: 'assets/images/faq_empty_3d.png',
                ),
                'terms' => _IllustratedEmptyView(
                  title: l10n.profileTerms,
                  assetPath: 'assets/images/terms_empty_3d.png',
                ),
                'privacy' => _IllustratedEmptyView(
                  title: l10n.profilePrivacy,
                  assetPath: 'assets/images/privacy_empty_3d.png',
                ),
                _ => AppEmptyView(message: l10n.staticPageEmpty),
              }
            : StaticPageContent(
                slug: widget.slug,
                title: page!.title.isNotEmpty ? page.title : fallbackTitle,
                body: body,
              ),
      );
    },
  );
}

class _IllustratedEmptyView extends StatelessWidget {
  const _IllustratedEmptyView({required this.title, required this.assetPath});

  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) => Center(
    // Place the illustration and copy slightly above the page centre.
    child: Transform.translate(
      offset: const Offset(0, -kToolbarHeight / 2 - AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          key: const Key('illustrated-empty-content'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              key: const Key('illustrated-empty-image'),
              dimension: 128,
              child: ClipRect(
                child: OverflowBox(
                  minWidth: 220,
                  maxWidth: 220,
                  minHeight: 220,
                  maxHeight: 220,
                  child: Image.asset(
                    assetPath,
                    width: 220,
                    height: 220,
                    semanticLabel: title,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.staticPageEmpty,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontFamily: AppTypography.fontFamily,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
