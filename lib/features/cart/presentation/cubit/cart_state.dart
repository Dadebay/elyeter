import 'package:equatable/equatable.dart';

/// What the cart holds: how many of each product, and which lines the
/// customer has ticked for checkout.
///
/// Deselection is stored rather than selection, so a product added to the
/// cart starts out ticked without anything having to remember to tick it.
class CartState extends Equatable {
  const CartState({this.quantities = const {}, this.deselected = const {}});

  /// Product id -> quantity. A product not in the map is not in the cart.
  final Map<String, int> quantities;

  /// Ids the customer has unticked; they stay in the cart but are left out
  /// of the totals.
  final Set<String> deselected;

  /// Distinct products in the cart — what the nav bar badge counts.
  int get lineCount => quantities.length;

  bool contains(String id) => quantities.containsKey(id);

  int quantityOf(String id) => quantities[id] ?? 0;

  bool isSelected(String id) => contains(id) && !deselected.contains(id);

  /// Whether every line is ticked; drives the "Select All" box.
  bool get allSelected => quantities.isNotEmpty && deselected.isEmpty;

  Iterable<String> get selectedIds => quantities.keys.where(isSelected);

  @override
  List<Object?> get props => [quantities, deselected];
}
