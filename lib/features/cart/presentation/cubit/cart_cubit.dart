import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../product/domain/entities/product_query.dart';
import '../../../product/domain/repositories/product_repository.dart';
import 'cart_state.dart';

/// The customer's cart: which products, how many, and what is ticked.
///
/// Hydrated, like the favourites, so the cart survives a restart. Ids and
/// counts only — prices come from the catalog, so nothing here goes stale.
class CartCubit extends HydratedCubit<CartState> {
  CartCubit() : super(const CartState());

  static const _legacyPrefix = 'legacy-slug:';

  /// Even numeric-looking slugs from old storage must be resolved by slug.
  static String? legacySlug(String key) => key.startsWith(_legacyPrefix)
      ? key.substring(_legacyPrefix.length)
      : null;

  Future<void>? _migration;

  /// Resolve old cart keys using the list API, never the removed slug route.
  /// Unmatched records and network failures stay in storage for a later retry.
  Future<void> migrateLegacyProducts(ProductRepository repository) =>
      _migration ??= _resolveLegacyProducts(repository).whenComplete(() {
        _migration = null;
      });

  Future<void> _resolveLegacyProducts(ProductRepository repository) async {
    const size = 100;
    for (var page = 1; !isClosed; page++) {
      if (!state.quantities.keys.any((key) => legacySlug(key) != null)) return;
      final result = await repository.list(
        query: const ProductQuery(),
        page: page,
        size: size,
      );
      if (isClosed) return;
      final products = result.dataOrNull;
      if (products == null) return;
      for (final product in products.items) {
        _resolveLegacyKey('$_legacyPrefix${product.slug}', product.id);
      }
      if (products.items.isEmpty || !products.hasMore(size)) return;
    }
  }

  void _resolveLegacyKey(String oldKey, int productId) {
    // It may have been removed while loading.
    if (!state.contains(oldKey)) return;
    final id = productId.toString();
    final alreadyAdded = state.contains(id);
    final quantities = Map<String, int>.of(state.quantities);
    final oldQuantity = quantities.remove(oldKey)!;
    quantities[id] = ((quantities[id] ?? 0) + oldQuantity).clamp(
      1,
      maxQuantity,
    );
    final deselected = Set<String>.of(state.deselected);
    final wasDeselected = deselected.remove(oldKey);
    if (!alreadyAdded && wasDeselected) deselected.add(id);
    final variants = Map<String, int>.of(state.variants);
    final variant = variants.remove(oldKey);
    if (variant != null) variants.putIfAbsent(id, () => variant);
    emit(
      CartState(
        quantities: quantities,
        deselected: deselected,
        variants: variants,
      ),
    );
  }

  /// Beyond this a line stops being a cart line and becomes a bulk order.
  static const maxQuantity = 99;

  bool contains(String id) => state.contains(id);

  /// Adds one of the product, or empties the line when it is already there.
  void toggle(String id) => contains(id) ? remove(id) : setQuantity(id, 1);

  void increase(String id) => setQuantity(id, state.quantityOf(id) + 1);

  /// Stepping below one removes the line, as the design's `-` does.
  void decrease(String id) => setQuantity(id, state.quantityOf(id) - 1);

  void setQuantity(String id, int quantity) {
    if (quantity < 1) return remove(id);
    final quantities = Map<String, int>.of(state.quantities);
    quantities[id] = quantity > maxQuantity ? maxQuantity : quantity;
    emit(
      CartState(
        quantities: quantities,
        deselected: state.deselected,
        variants: state.variants,
      ),
    );
  }

  void remove(String id) {
    final quantities = Map<String, int>.of(state.quantities)..remove(id);
    final deselected = Set<String>.of(state.deselected)..remove(id);
    final variants = Map<String, int>.of(state.variants)..remove(id);
    emit(
      CartState(
        quantities: quantities,
        deselected: deselected,
        variants: variants,
      ),
    );
  }

  void setVariant(String id, int variantId) {
    final variants = Map<String, int>.of(state.variants)..[id] = variantId;
    emit(
      CartState(
        quantities: state.quantities,
        deselected: state.deselected,
        variants: variants,
      ),
    );
  }

  void toggleSelected(String id) {
    if (!contains(id)) return;
    final deselected = Set<String>.of(state.deselected);
    if (!deselected.remove(id)) deselected.add(id);
    emit(
      CartState(
        quantities: state.quantities,
        deselected: deselected,
        variants: state.variants,
      ),
    );
  }

  /// Ticks everything, or unticks everything when it is already all ticked.
  void toggleSelectAll() => emit(
    CartState(
      quantities: state.quantities,
      deselected: state.allSelected ? state.quantities.keys.toSet() : const {},
      variants: state.variants,
    ),
  );

  void removeAll() => emit(const CartState());

  /// Marks storage written by a build that knows about the placeholder cart.
  /// Records written before it carry no marker, which is what tells an empty
  /// legacy cart apart from a cart the customer has deliberately emptied.
  static const _marker = 'seeded';

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    String keyFor(String key) =>
        json['version'] == 2 ? key : '$_legacyPrefix$key';
    final quantities =
        (json['quantities'] as Map?)?.map(
          (key, value) =>
              MapEntry(keyFor(key as String), (value as num).toInt()),
        ) ??
        const <String, int>{};

    // An empty unmarked record is a cart that was persisted before the
    // placeholder existed — restoring it would open the Cart tab on its
    // empty state. Returning null keeps the seeded initial state instead,
    // and the next write marks storage so this happens only once.
    if (quantities.isEmpty && json[_marker] != true) return null;

    return CartState(
      quantities: quantities,
      deselected:
          (json['deselected'] as List?)?.cast<String>().map(keyFor).toSet() ??
          const {},
      variants:
          (json['variants'] as Map?)?.map(
            (key, value) =>
                MapEntry(keyFor(key as String), (value as num).toInt()),
          ) ??
          const {},
    );
  }

  @override
  Map<String, dynamic>? toJson(CartState state) => {
    'version': 2,
    'quantities': state.quantities,
    'deselected': state.deselected.toList(),
    'variants': state.variants,
    _marker: true,
  };
}
