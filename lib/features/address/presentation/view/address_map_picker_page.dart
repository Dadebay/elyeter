import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/services/device_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elyeter_map.dart';

class AddressMapPickerPage extends StatefulWidget {
  const AddressMapPickerPage({super.key, this.current});
  final SavedLocation? current;

  @override
  State<AddressMapPickerPage> createState() => _AddressMapPickerPageState();
}

class _AddressMapPickerPageState extends State<AddressMapPickerPage> {
  final _mapController = MapController();
  final _location = DeviceLocationService();
  late final _name = TextEditingController(text: widget.current?.name);
  late final _address = TextEditingController(text: widget.current?.address);
  late final _details = TextEditingController(text: widget.current?.details);
  late LatLng _point = widget.current == null
      ? ElyeterMap.defaultCenter
      : LatLng(widget.current!.latitude, widget.current!.longitude);
  late String _type = widget.current?.type ?? 'home';
  late bool _pointConfirmed = widget.current != null;
  bool _locating = false;
  String? _message;

  @override
  void dispose() {
    _mapController.dispose();
    _name.dispose();
    _address.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _message = null;
    });
    try {
      final point = await _location.locate();
      if (!mounted) return;
      _mapController.move(point, 16);
      setState(() {
        _point = point;
        _pointConfirmed = true;
        if (_location.lastFixWasApproximate) {
          _message = 'Konum yaklaşık. Pini doğru noktaya sürükleyin.';
        }
      });
    } on LocationLookupException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } on Object {
      if (mounted) {
        setState(() => _message = 'Konum alınamadı. Haritadan seçin.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _save() {
    if (!_pointConfirmed) {
      setState(() => _message = 'Önce haritadan bir nokta seçin.');
      return;
    }
    if (_name.text.trim().isEmpty) {
      setState(() => _message = 'Adres adı gerekli.');
      return;
    }
    Navigator.of(context).pop(<String, dynamic>{
      'name': _name.text.trim(),
      'type': _type,
      'address': _address.text.trim(),
      'details': _details.text.trim(),
      'latitude': _point.latitude,
      'longitude': _point.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final panel = isDark ? AppColors.surfaceDark : AppColors.white;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sheetHeight = constraints.maxHeight * 0.48;
          const overlap = 24.0;
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: sheetHeight - overlap,
                child: Stack(
                  children: [
                    ElyeterMap(
                      center: _point,
                      showAttributionButton: false,
                      controller: _mapController,
                      onPositionChanged: (camera, hasGesture) {
                        _point = camera.center;
                        if (hasGesture && mounted) {
                          setState(() => _pointConfirmed = true);
                        }
                      },
                    ),
                    const IgnorePointer(child: Center(child: _MapPin())),
                    Positioned(
                      right: AppSpacing.lg,
                      bottom: AppSpacing.xl + overlap,
                      child: _MapButton(
                        onPressed: _locating ? null : _locate,
                        child: _locating
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const HugeIcon(
                                icon: AppIcons.currentLocation,
                                size: 22,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: sheetHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 24,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.grey300,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            widget.current == null
                                ? 'Adres seç'
                                : 'Adresi düzenle',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Haritayı kaydırıp pini teslimat noktasına getirin.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: AppTypography.fontFamily,
                              color: AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              for (final (value, label, icon) in const [
                                ('home', 'Ev', AppIcons.home),
                                ('work', 'İş', AppIcons.work),
                                ('other', 'Diğer', AppIcons.location),
                              ]) ...[
                                Expanded(
                                  child: _TypeChip(
                                    label: label,
                                    icon: icon,
                                    selected: _type == value,
                                    onTap: () => setState(() => _type = value),
                                  ),
                                ),
                                if (value != 'other')
                                  const SizedBox(width: AppSpacing.sm),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextField(
                            controller: _name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppTypography.fontFamily,
                            ),
                            maxLength: 60,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Adres adı',
                              hintText: 'Örn. Ev',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _address,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppTypography.fontFamily,
                            ),
                            maxLength: 500,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Sokak ve bina',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _details,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppTypography.fontFamily,
                            ),
                            maxLength: 200,
                            decoration: const InputDecoration(
                              labelText: 'Giriş, kat, daire (isteğe bağlı)',
                              counterText: '',
                            ),
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            _Notice(_message!),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: _save,
                            child: const Text(
                              'Adresi kaydet',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + AppSpacing.md,
                left: AppSpacing.lg,
                child: _MapButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: HugeIcon(
                    icon: AppIcons.back,
                    size: 22,
                    color: isDark ? AppColors.white : AppColors.ink,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The pin fixed at the middle of the map, with a small shadow where its
/// tip meets the ground so it reads as sitting on the map.
class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 8,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const Positioned(
            bottom: 3,
            child: HugeIcon(
              key: Key('address-map-pin'),
              icon: AppIcons.mapPin,
              size: 34,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Round white button floating over the map.
class _MapButton extends StatelessWidget {
  const _MapButton({required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(dimension: 44, child: Center(child: child)),
      ),
    );
  }
}

/// One of the Home / Work / Other choices.
class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AppIconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final idle = isDark ? AppColors.white : AppColors.ink;

    return Material(
      color: selected
          ? AppColors.primary
          : (isDark ? AppColors.backgroundDark : AppColors.grey100),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: icon,
                size: 18,
                color: selected ? AppColors.white : idle,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: AppTypography.fontFamily,
                  color: selected ? AppColors.white : idle,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline validation / location message.
class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const HugeIcon(
            icon: AppIcons.information,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
