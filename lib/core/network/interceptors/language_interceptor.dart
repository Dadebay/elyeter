import 'package:dio/dio.dart';

import '../../storage/local_storage.dart';
import '../../storage/storage_keys.dart';

/// Sends `Content-Language` on every request.
///
/// The header picks the language of product names, categories, attributes and
/// the availability messages inside a pre-order check. The backend defaults
/// to Turkmen when it is absent and falls back to Turkmen for any value other
/// than `tk` or `ru`, so anything else the app supports (English) is sent as
/// `tk` rather than as an unknown tag.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._storage);

  static const supported = {'tk', 'ru'};
  static const fallback = 'tk';

  final LocalStorage _storage;

  /// Maps an app locale to a language the API understands.
  static String resolve(String? languageCode) =>
      supported.contains(languageCode) ? languageCode! : fallback;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final stored = _storage.getString(StorageKeys.contentLanguage);
    options.headers['Content-Language'] = resolve(stored);
    handler.next(options);
  }
}
