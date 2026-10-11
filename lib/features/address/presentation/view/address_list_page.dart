import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../widgets/delete_address_dialog.dart';
import 'address_map_picker_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key, required this.title});
  final String title;

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<SavedLocation> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await getIt<ShopApi>().locations();
      if (mounted) setState(() => _items = items);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([SavedLocation? current]) async {
    final values = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => AddressMapPickerPage(current: current)),
    );
    if (values == null || !mounted) return;
    try {
      if (current == null) {
        await getIt<ShopApi>().createLocation(values);
      } else {
        await getIt<ShopApi>().updateLocation(current.id, values);
      }
      await _load();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _confirmRemove(SavedLocation item) async {
    final confirmed = await showDeleteAddressDialog(context, name: item.name);
    if (confirmed && mounted) await _remove(item);
  }

  Future<void> _remove(SavedLocation item) async {
    try {
      await getIt<ShopApi>().deleteLocation(item.id);
      await _load();
      if (mounted) AppSnackBar.show(context, context.l10n.addressDeleteDone);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _makeDefault(SavedLocation item) async {
    try {
      await getIt<ShopApi>().setDefaultLocation(item.id);
      await _load();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppPageAppBar(title: widget.title),
    body: _loading && _items.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _error != null && _items.isEmpty
        ? Center(
            child: TextButton(onPressed: _load, child: Text(_error!)),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: _items.isEmpty
                ? const CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyAddresses(),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.sm,
                      AppSpacing.page,
                      // Clearance for the extended button.
                      96,
                    ),
                    children: [
                      for (final item in _items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _AddressCard(
                            item: item,
                            onTap: () => _edit(item),
                            onEdit: () => _edit(item),
                            onDelete: () => _confirmRemove(item),
                            onMakeDefault: () => _makeDefault(item),
                          ),
                        ),
                    ],
                  ),
          ),
    floatingActionButton: _items.length >= 10
        ? null
        : FloatingActionButton.extended(
            onPressed: _edit,
            elevation: 2,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: const StadiumBorder(),
            icon: const HugeIcon(icon: AppIcons.add),
            label: const Text(
              'Add address',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
  );
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.translate(
      offset: const Offset(0, -kToolbarHeight / 2 - AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 128,
              child: ClipRect(
                child: OverflowBox(
                  minWidth: 220,
                  maxWidth: 220,
                  minHeight: 220,
                  maxHeight: 220,
                  child: Image.asset(
                    'assets/images/address_empty_3d.png',
                    width: 220,
                    height: 220,
                    semanticLabel: context.l10n.addressEmptyTitle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.addressEmptyTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.addressEmptyMessage,
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

/// One saved address: where it is, which one is the default, and the three
/// things that can be done to it — make default (`POST /locations/{id}/default`),
/// edit, delete.
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
  });

  final SavedLocation item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  AppIconData get _icon => switch (item.type) {
    'home' => AppIcons.home,
    'work' => AppIcons.work,
    _ => AppIcons.location,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detail = [
      item.address,
      item.details,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: HugeIcon(
                      icon: _icon,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (item.isDefault) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const _DefaultBadge(),
                            ],
                          ],
                        ),
                        if (detail.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            detail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Quiet corner actions: small and grey so the address
                  // stays the loudest thing on the card.
                  _ActionButton(
                    icon: AppIcons.edit,
                    tooltip: 'Edit',
                    onPressed: onEdit,
                  ),
                  _ActionButton(
                    icon: AppIcons.delete,
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (!item.isDefault) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: onMakeDefault,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const HugeIcon(
                    icon: AppIcons.checkCircle,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text('Make default'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        'Default',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final AppIconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      icon: HugeIcon(icon: icon, size: 18, color: AppColors.grey500),
    );
  }
}
