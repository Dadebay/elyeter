import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';

/// Full-screen photo viewer: pinch or double-tap to zoom, swipe between
/// photos, swipe down to dismiss.
///
/// Pushed imperatively rather than routed: it is a lightbox over the page
/// that opened it, not a place to deep-link into.
class ProductPhotoViewerPage extends StatefulWidget {
  const ProductPhotoViewerPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroPrefix = 'product-photo',
  });

  final List<String> images;
  final int initialIndex;
  final String heroPrefix;

  static Future<void> open(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    String heroPrefix = 'product-photo',
  }) => Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => ProductPhotoViewerPage(
        images: images,
        initialIndex: initialIndex,
        heroPrefix: heroPrefix,
      ),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );

  @override
  State<ProductPhotoViewerPage> createState() => _ProductPhotoViewerPageState();
}

class _ProductPhotoViewerPageState extends State<ProductPhotoViewerPage> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  /// Vertical drag distance that dismisses the viewer.
  static const _dismissAt = 120.0;
  double _drag = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = (1 - (_drag.abs() / (_dismissAt * 2))).clamp(0.35, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: fade),
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, _drag),
              child: PageView.builder(
                controller: _pages,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, index) => _ZoomablePhoto(
                  image: widget.images[index],
                  heroTag: '${widget.heroPrefix}-$index',
                  onDragUpdate: (delta) => setState(() => _drag += delta),
                  onDragEnd: () {
                    if (_drag.abs() > _dismissAt) {
                      Navigator.of(context).pop();
                    } else {
                      setState(() => _drag = 0);
                    }
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top + AppSpacing.sm,
            left: 0,
            child: const AppBackButton.appBarLeading(),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.viewPaddingOf(context).bottom + AppSpacing.xxl,
              left: 0,
              right: 0,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      '${_index + 1} of ${widget.images.length}',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomablePhoto extends StatefulWidget {
  const _ZoomablePhoto({
    required this.image,
    required this.heroTag,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final String image;
  final String heroTag;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  final _viewer = TransformationController();
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _zoomTo;

  static const _doubleTapScale = 2.5;

  bool get _zoomedIn => _viewer.value.getMaxScaleOnAxis() > 1.05;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      if (_zoomTo != null) _viewer.value = _zoomTo!.value;
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    _viewer.dispose();
    super.dispose();
  }

  /// Zooms towards the tapped point, or back out when already zoomed.
  void _handleDoubleTap(TapDownDetails details) {
    final end = _zoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -details.localPosition.dx * (_doubleTapScale - 1),
              -details.localPosition.dy * (_doubleTapScale - 1),
              0,
              1,
            )
            ..scaleByDouble(
              _doubleTapScale,
              _doubleTapScale,
              _doubleTapScale,
              1,
            ));

    _zoomTo = Matrix4Tween(begin: _viewer.value, end: end).animate(
      CurvedAnimation(parent: _zoom, curve: Curves.easeOutCubic),
    );
    _zoom.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
      onDoubleTap: () {},
      // Dragging the photo down closes the viewer, but only while it is not
      // zoomed in — otherwise the drag belongs to panning the photo.
      onVerticalDragUpdate: _zoomedIn
          ? null
          : (details) => widget.onDragUpdate(details.delta.dy),
      onVerticalDragEnd: _zoomedIn ? null : (_) => widget.onDragEnd(),
      child: InteractiveViewer(
        transformationController: _viewer,
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            child: Image.asset(widget.image, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
