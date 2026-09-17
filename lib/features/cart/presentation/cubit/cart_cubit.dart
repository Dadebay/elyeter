import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../home/presentation/view/home_placeholder_data.dart';
import 'cart_state.dart';

/// The customer's cart: which products, how many, and what is ticked.
///
/// Hydrated, like the favourites, so the cart survives a restart. Ids and
/// counts only — prices come from the catalog, so nothing here goes stale.
class CartCubit extends HydratedCubit<CartState> {
  /// Starts on the placeholder cart so the Cart tab has something to show
  /// on a fresh install; a stored cart replaces it on every later launch.
  CartCubit()
    : super(const CartState(quantities: HomePlaceholderData.demoCart));

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
    emit(CartState(quantities: quantities, deselected: state.deselected));
  }

  void remove(String id) {
    final quantities = Map<String, int>.of(state.quantities)..remove(id);
    final deselected = Set<String>.of(state.deselected)..remove(id);
    emit(CartState(quantities: quantities, deselected: deselected));
  }

  void toggleSelected(String id) {
    if (!contains(id)) return;
    final deselected = Set<String>.of(state.deselected);
    if (!deselected.remove(id)) deselected.add(id);
    emit(CartState(quantities: state.quantities, deselected: deselected));
  }

  /// Ticks everything, or unticks everything when it is already all ticked.
  void toggleSelectAll() => emit(
    CartState(
      quantities: state.quantities,
      deselected: state.allSelected ? state.quantities.keys.toSet() : const {},
    ),
  );

  void removeAll() => emit(const CartState());

  /// Marks storage written by a build that knows about the placeholder cart.
  /// Records written before it carry no marker, which is what tells an empty
  /// legacy cart apart from a cart the customer has deliberately emptied.
  static const _marker = 'seeded';

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    final quantities =
        (json['quantities'] as Map?)?.map(
          (key, value) => MapEntry(key as String, (value as num).toInt()),
        ) ??
        const <String, int>{};

    // An empty unmarked record is a cart that was persisted before the
    // placeholder existed — restoring it would open the Cart tab on its
    // empty state. Returning null keeps the seeded initial state instead,
    // and the next write marks storage so this happens only once.
    if (quantities.isEmpty && json[_marker] != true) return null;

    return CartState(
      quantities: quantities,
      deselected: (json['deselected'] as List?)?.cast<String>().toSet() ?? const {},
    );
  }

  @override
  Map<String, dynamic>? toJson(CartState state) => {
    'quantities': state.quantities,
    'deselected': state.deselected.toList(),
    _marker: true,
  };
}
