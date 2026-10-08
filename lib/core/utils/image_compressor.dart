import 'dart:io';

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
  static const maxBytes = 1024 * 1024;

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
  /// Returns [path] unchanged when the photo already fits, and when it
  /// cannot be decoded at all — a picture the app cannot shrink is still a
  /// picture the customer chose, and failing here must not lose it.
  static Future<String> shrink(String path) async {
    try {
      final source = File(path);
      final bytes = await source.readAsBytes();
      if (bytes.length <= maxBytes) return path;

      final shrunk = await compute(_encode, bytes);
      if (shrunk == null) return path;

      final directory = await getTemporaryDirectory();
      final target = File(
        '${directory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await target.writeAsBytes(shrunk);

      AppLogger.d(
        'Avatar shrunk: ${_kb(bytes.length)} -> ${_kb(shrunk.length)}',
      );
      return target.path;
    } on Object catch (e) {
      AppLogger.w('Avatar compression failed: $e');
      return path;
    }
  }

  static String _kb(int bytes) => '${(bytes / 1024).round()} KB';
}

/// Runs on a background isolate — top-level so [compute] can reach it, and
/// free of anything but its argument for the same reason.
Uint8List? _encode(Uint8List bytes) {
  var image = img.decodeImage(bytes);
  if (image == null) return null;

  if (image.width > ImageCompressor.maxDimension ||
      image.height > ImageCompressor.maxDimension) {
    final landscape = image.width >= image.height;
    image = img.copyResize(
      image,
      width: landscape ? ImageCompressor.maxDimension : null,
      height: landscape ? null : ImageCompressor.maxDimension,
    );
  }

  for (final quality in ImageCompressor._qualitySteps) {
    final encoded = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    if (encoded.length <= ImageCompressor.maxBytes) return encoded;
  }

  // Still over the limit at the lowest step — an extreme source, a panorama
  // or a scan. Halve it once more and settle: this is drawn at ~100pt.
  final halved = img.copyResize(image, width: (image.width / 2).round());
  return Uint8List.fromList(img.encodeJpg(halved, quality: 40));
}
