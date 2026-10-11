import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'app_logger.dart';

/// Shrinks a picked photo before the app keeps it.
///
/// A phone camera hands back several megabytes at 4000px across; an avatar
/// is drawn at around 100pt. Left alone that photo is carried in memory, in
/// the app's storage and eventually over the wire for nothing.
///
/// The work is pure Dart and runs off the UI isolate, so a large photo does
/// not drop frames on the page that picked it.
abstract final class ImageCompressor {
  /// The ceiling a stored avatar has to come in under.
  static const maxBytes = 1_000_000;

  /// Longest side after resizing. Four times the size the avatar is drawn
  /// at, so it still looks right on a 3x screen and in the photo viewer.
  /// The picker is asked for the same cap, so most photos never reach the
  /// re-encode below at all.
  static const maxDimension = 1024;

  /// Where re-encoding starts. Steps down only if 70% is still too large.
  static const _qualitySteps = [70, 60, 50, 40, 30, 20];

  /// Re-encodes the photo at [path] as JPEG and writes it next to the
  /// original, returning the new file's path.
  ///
  /// Returns [path] unchanged when it already fits. Returns null if a large
  /// image cannot be reduced below the limit; callers must not keep it.
  static Future<String?> shrink(String path) async {
    try {
      final source = File(path);
      final bytes = await source.readAsBytes();
      if (bytes.length <= maxBytes) return path;

      final shrunk = await compute(compressBytes, bytes);
      if (shrunk == null || shrunk.length > maxBytes) return null;

      final directory = await getTemporaryDirectory();
      final target = File(
        '${directory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await target.writeAsBytes(shrunk);
      if (await target.length() > maxBytes) {
        await target.delete();
        return null;
      }

      AppLogger.d(
        'Avatar shrunk: ${_kb(bytes.length)} -> ${_kb(shrunk.length)}',
      );
      return target.path;
    } on Object catch (e) {
      AppLogger.w('Avatar compression failed: $e');
      return null;
    }
  }

  static String _kb(int bytes) => '${(bytes / 1024).round()} KB';

  /// Pure-Dart work run by [compute], separate from file and plugin access.
  static Uint8List? compressBytes(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      var image = decoded;

      if (image.width > maxDimension || image.height > maxDimension) {
        final landscape = image.width >= image.height;
        image = img.copyResize(
          image,
          width: landscape ? maxDimension : null,
          height: landscape ? null : maxDimension,
        );
      }

      while (true) {
        for (final quality in _qualitySteps) {
          final encoded = Uint8List.fromList(
            img.encodeJpg(image, quality: quality),
          );
          if (encoded.length <= maxBytes) return encoded;
        }

        if (image.width == 1 && image.height == 1) return null;
        image = img.copyResize(
          image,
          width: math.max(1, image.width ~/ 2),
          height: math.max(1, image.height ~/ 2),
        );
      }
    } on Object {
      return null;
    }
  }
}
