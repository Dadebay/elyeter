import '../constants/app_environment.dart';

/// `main_image`, `images[].url` and a variant's `image` already come back as
/// absolute URLs. Category images and brand logos may be either absolute or
/// a storage path — anything that is not `http…` is resolved against the
/// file server.
abstract final class MediaUrl {
  static String? resolve(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '${AppEnvironment.fileBaseUrl}$path';
  }
}
