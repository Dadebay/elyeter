import '../../../../core/di/injector.dart';
import '../../domain/repositories/product_repository.dart';

/// The extra photos of a catalogue product, for the card's swipeable photo.
///
/// `GET /products` carries only each product's main photo; the rest are on
/// its own page. A card asks for them as it is built, so only the products
/// actually scrolled to cost a request, and each is asked for once.
abstract final class ProductPhotos {
  /// More than this and the card's dots stop being readable, and the page
  /// ends up downloading photos nobody swipes to.
  static const max = 3;

  static final _loaded = <String, List<String>>{};
  static final _loading = <String, Future<List<String>>>{};

  /// What is already known for [slug], or null if it has not been asked for.
  static List<String>? cached(String slug) => _loaded[slug];

  /// Up to [max] photos for [slug], main one first. Empty when they cannot be
  /// had — the card then simply keeps the one photo it already has.
  static Future<List<String>> load(String slug) {
    final known = _loaded[slug];
    if (known != null) return Future.value(known);
    return _loading[slug] ??= _fetch(slug).whenComplete(() {
      // A block, not an expression body: `remove` returns the very future
      // being completed here, and whenComplete would wait on it forever.
      _loading.remove(slug);
    });
  }

  static Future<List<String>> _fetch(String slug) async {
    final result = await getIt<ProductRepository>().bySlug(slug);
    final photos = (result.dataOrNull?.gallery ?? const <String>[])
        .take(max)
        .toList();
    // A failure is remembered too: a card scrolled past and back should not
    // ask again, and a retry storm helps nobody.
    _loaded[slug] = photos;
    return photos;
  }

  /// [main] first, then the others without repeating it, [max] in all.
  static List<String> merge(List<String> main, List<String> extra) {
    final result = <String>[...main];
    for (final url in extra) {
      if (result.length >= max) break;
      if (!result.contains(url)) result.add(url);
    }
    return result.take(max).toList();
  }
}
