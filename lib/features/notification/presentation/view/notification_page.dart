import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../services/notification_navigation.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    required this.title,
    this.isAnnouncement = false,
  });
  final String title;
  final bool isAnnouncement;
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Paginated<ShopNotification>? _page;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final next = await getIt<ShopApi>().notifications(
        page: more ? (_page?.page ?? 0) + 1 : 1,
      );
      if (!mounted) return;
      setState(() => _page = more && _page != null ? _page!.merge(next) : next);
      if (next.items.isNotEmpty) {
        final storage = getIt<LocalStorage>();
        final previous =
            int.tryParse(storage.getString('notifications_last_seen') ?? '') ??
            0;
        final newest = next.items
            .map((n) => n.id)
            .reduce((a, b) => a > b ? a : b);
        if (newest > previous) {
          await storage.setString('notifications_last_seen', newest.toString());
        }
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _page?.items ?? const <ShopNotification>[];
    return Scaffold(
      appBar: AppPageAppBar(title: widget.title),
      body: _page == null && _loading
          ? const Center(child: CircularProgressIndicator())
          : _page == null && _error != null
          ? Center(
              child: TextButton(onPressed: _load, child: Text(_error!)),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyNotifications(
                            isAnnouncement: widget.isAnnouncement,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      children: [
                        for (final item in items)
                          ListTile(
                            title: Text(item.title),
                            subtitle: Text(item.body),
                            trailing: item.targetType == 'none'
                                ? null
                                : const Icon(Icons.chevron_right),
                            onTap: () => NotificationNavigation.open(
                              item.targetType,
                              item.target,
                            ),
                          ),
                        if (_page?.hasMore(20) ?? false)
                          Center(
                            child: TextButton(
                              onPressed: _loading
                                  ? null
                                  : () => _load(more: true),
                              child: Text(_loading ? '…' : 'More'),
                            ),
                          ),
                      ],
                    ),
            ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.isAnnouncement});

  final bool isAnnouncement;

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.translate(
      offset: const Offset(0, -kToolbarHeight / 2 - AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          key: const Key('notification-empty-content'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: const Key('notification-empty-image'),
              width: 200,
              height: 160,
              child: OverflowBox(
                minWidth: 200,
                maxWidth: 200,
                minHeight: 200,
                maxHeight: 200,
                child: Image.asset(
                  'assets/images/notification_empty_3d.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  semanticLabel: isAnnouncement
                      ? context.l10n.announcementsEmptyTitle
                      : context.l10n.notificationsEmptyTitle,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isAnnouncement
                  ? context.l10n.announcementsEmptyTitle
                  : context.l10n.notificationsEmptyTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isAnnouncement
                  ? context.l10n.announcementsEmptyMessage
                  : context.l10n.notificationsEmptyMessage,
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
