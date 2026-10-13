import '../../domain/entities/product_variant.dart';

/// What a product's variants offer, grouped the way the page lets the
/// customer choose: one row per attribute (colour, size…), each with its
/// values.
///
/// The API gives a flat list of variants, each carrying its own attribute
/// values, so this works out the rows and which variant a set of picks lands
/// on — nothing here assumes the attributes are colour and size.
class VariantOptions {
  VariantOptions(this.variants);

  final List<ProductVariant> variants;

  /// Attribute names in the order the variants first mention them.
  late final List<String> names = {
    for (final variant in variants)
      for (final attribute in variant.attributes) attribute.name,
  }.toList();

  /// The values [name] takes, in order, without repeats.
  List<String> valuesOf(String name) =>
      {for (final variant in variants) ?_valueOf(variant, name)}.toList();

  /// The photo that stands for [value] — the first variant carrying it that
  /// has one. Null when none does.
  String? imageOf(String name, String value) {
    for (final variant in variants) {
      if (_valueOf(variant, name) == value &&
          variant.image != null &&
          variant.image!.isNotEmpty) {
        return variant.image;
      }
    }
    return null;
  }

  /// Every value of [name] has a photo, so the row can be drawn as swatches.
  bool isVisual(String name) {
    final values = valuesOf(name);
    return values.isNotEmpty && values.every((v) => imageOf(name, v) != null);
  }

  /// Whether picking [value] can land on a variant that is in stock.
  bool isAvailable(String name, String value) => variants.any(
    (variant) => variant.inStock && _valueOf(variant, name) == value,
  );

  /// What the customer starts on: the variant already chosen elsewhere
  /// ([preferredId], e.g. the one in the cart) if it exists, otherwise the
  /// first in stock, otherwise the first.
  ProductVariant? initial({int? preferredId}) {
    if (variants.isEmpty) return null;
    for (final variant in variants) {
      if (variant.id == preferredId) return variant;
    }
    return variants.firstWhere((v) => v.inStock, orElse: () => variants.first);
  }

  /// The variant to land on when the customer picks [value] under [name]
  /// while [current] is selected: one that is in stock and keeps their other
  /// choices; failing that any in stock, since a sold-out combination cannot
  /// be bought; failing that one that keeps their choices.
  ProductVariant? pick(String name, String value, ProductVariant? current) {
    final matching = variants
        .where((variant) => _valueOf(variant, name) == value)
        .toList();
    if (matching.isEmpty) return current;

    bool keepsOthers(ProductVariant variant) =>
        current == null ||
        current.attributes
            .where((a) => a.name != name)
            .every((a) => _valueOf(variant, a.name) == a.value);

    for (final test in <bool Function(ProductVariant)>[
      (v) => v.inStock && keepsOthers(v),
      (v) => v.inStock,
      keepsOthers,
    ]) {
      for (final variant in matching) {
        if (test(variant)) return variant;
      }
    }
    return matching.first;
  }

  /// The value [variant] has under [name], or null if it has none.
  String? valueOf(ProductVariant? variant, String name) =>
      variant == null ? null : _valueOf(variant, name);

  static String? _valueOf(ProductVariant variant, String name) {
    for (final attribute in variant.attributes) {
      if (attribute.name == name) return attribute.value;
    }
    return null;
  }
}
