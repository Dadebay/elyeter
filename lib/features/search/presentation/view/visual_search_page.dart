import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../widgets/visual_search_controls.dart';
import '../widgets/visual_search_frame.dart';

/// Full-screen in-app camera for searching by photo.
///
/// Pops the captured (or picked) file, or null when the customer backs out.
/// It owns nothing but the shot: matching the photo to products is the search
/// API's job once that exists.
class VisualSearchPage extends StatefulWidget {
  const VisualSearchPage({super.key});

  static Future<XFile?> open(BuildContext context) {
    // The root navigator, so the camera covers the shell's bottom nav bar
    // instead of opening inside the Home tab underneath it.
    return Navigator.of(context, rootNavigator: true).push<XFile>(
      MaterialPageRoute(builder: (_) => const VisualSearchPage(), fullscreenDialog: true),
    );
  }

  @override
  State<VisualSearchPage> createState() => _VisualSearchPageState();
}

class _VisualSearchPageState extends State<VisualSearchPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  FlashMode _flash = FlashMode.off;

  /// Set once the preview is live; until then the page shows a spinner.
  bool _ready = false;

  /// Non-null when there is nothing to show: no camera, or access refused.
  String? _blocked;

  /// The shot waiting to be accepted or retaken.
  XFile? _shot;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// The platform tears the camera down when the app leaves the foreground,
  /// so the controller has to be rebuilt on the way back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
      setState(() => _ready = false);
    } else if (state == AppLifecycleState.resumed) {
      _open(_cameraIndex);
    }
  }

  Future<void> _start() async {
    try {
      _cameras = await availableCameras();
    } on Object catch (error, stack) {
      // Not just CameraException: if the native plugin is missing — an app
      // that was hot-restarted instead of rebuilt after the dependency was
      // added — the platform channel throws instead. Either way there is no
      // camera to show, and the page says so rather than crashing.
      AppLogger.e('Could not list cameras', error, stack);
      _cameras = const [];
    }
    if (!mounted) return;
    if (_cameras.isEmpty) {
      setState(() => _blocked = context.l10n.visualSearchNoCamera);
      return;
    }
    await _open(0);
  }

  Future<void> _open(int index) async {
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      await controller.setFlashMode(_flash);
    } on Object catch (error, stack) {
      AppLogger.e('Could not open the camera', error, stack);
      final denied = error is CameraException && error.code.contains('AccessDenied');
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _blocked = denied ? context.l10n.visualSearchDenied : context.l10n.visualSearchNoCamera;
      });
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _cameraIndex = index;
      _ready = true;
      _blocked = null;
    });
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_busy || controller == null || !controller.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      if (mounted) setState(() => _shot = file);
    } on Object catch (error, stack) {
      AppLogger.e('Could not take the picture', error, stack);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final next = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await controller.setFlashMode(next);
      if (mounted) setState(() => _flash = next);
    } on Object catch (error, stack) {
      AppLogger.e('Could not switch the flash', error, stack);
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    setState(() => _ready = false);
    _open((_cameraIndex + 1) % _cameras.length);
  }

  @override
  Widget build(BuildContext context) {
    final shot = _shot;
    final scanning = shot == null && _blocked == null;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (shot != null)
            Image.file(File(shot.path), fit: BoxFit.cover)
          else if (_blocked != null)
            _Blocked(message: _blocked!)
          else if (_ready && _controller != null)
            _Preview(controller: _controller!)
          else
            const Center(child: CircularProgressIndicator(color: AppColors.white)),

          // The scan window dims everything around the product.
          if (scanning) ...[
            const VisualSearchFrame(),
            _FrameHint(text: context.l10n.visualSearchHint),
          ],

          SafeArea(
            child: Column(
              children: [
                VisualSearchTopBar(
                  title: context.l10n.visualSearchTitle,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                if (shot != null)
                  VisualSearchConfirmBar(
                    onRetake: () => setState(() => _shot = null),
                    onUse: () => Navigator.of(context).pop(shot),
                  )
                else if (_blocked == null)
                  VisualSearchShutterBar(
                    busy: _busy,
                    enabled: _ready,
                    flashOn: _flash != FlashMode.off,
                    onCapture: _capture,
                    onFlash: _ready ? _toggleFlash : null,
                    onSwitch: _cameras.length > 1 ? _switchCamera : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The line of guidance, pinned just under the scan window.
class _FrameHint extends StatelessWidget {
  const _FrameHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final frame = VisualSearchFrame.frameOf(context.screenSize);
    return Positioned(
      top: frame.bottom + AppSpacing.xl,
      left: AppSpacing.xxl,
      right: AppSpacing.xxl,
      child: IgnorePointer(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}

/// The live preview, cropped to fill the screen instead of letterboxed.
class _Preview extends StatelessWidget {
  const _Preview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.width,
        // `aspectRatio` is reported for landscape, so it is inverted here.
        height: size.width * controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}

/// Shown when there is no camera, or access was refused.
class _Blocked extends StatelessWidget {
  const _Blocked({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedCameraOff01, color: AppColors.grey500, size: 40),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
