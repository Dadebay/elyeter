import 'package:equatable/equatable.dart';

/// Why a line cannot be ordered — `items[].status` of a pre-order check.
enum PreOrderLineStatus {
  /// In stock in the requested quantity.
  available,

  /// In stock, but fewer than requested — offer to reduce the quantity.
  insufficientStock,

  /// Sold out — offer to remove the line.
  outOfStock,

  /// Withdrawn from sale — remove the line.
  unavailable,

  /// Not in our catalog at all — remove the line silently.
  notFound;

  static PreOrderLineStatus parse(String? value) => switch (value) {
    'available' => available,
    'insufficient_stock' => insufficientStock,
    'out_of_stock' => outOfStock,
    'unavailable' => unavailable,
    'not_found' => notFound,
    _ => unavailable,
  };

  bool get isAvailable => this == available;
}

/// One line of a `/check` result — also what the two checkout 409s carry in
/// `details`, so one renderer handles both.
class PreOrderCheckItem extends Equatable {
  const PreOrderCheckItem({
    required this.productId,
    required this.quantity,
    required this.status,
    this.variantId,
    this.sku,
    this.name,
    this.variant,
    this.image,
    this.price,
    this.previousPrice,
    this.priceChanged = false,
    this.lineTotal,
    this.availableStock,
    this.message,
  });

  final int productId;
  final int? variantId;
  final String? sku;
  final String? name;

  /// Pre-formatted variant label, e.g. `Reňk: Gara` — display as-is.
  final String? variant;

  final String? image;
  final int quantity;

  /// Current unit price; null when the line is unavailable.
  final num? price;

  /// Price before this check — renders the "was / now" pair.
  final num? previousPrice;

  final bool priceChanged;
  final num? lineTotal;

  /// How many the supplier actually has.
  final int? availableStock;

  final PreOrderLineStatus status;

  /// Ready-to-display text in the requested language; null when the line is
  /// fine. Not cached: the wording is still being revised.
  final String? message;

  bool get isAvailable => status.isAvailable;

  @override
  List<Object?> get props => [
    productId,
    variantId,
    sku,
    name,
    variant,
    image,
    quantity,
    price,
    previousPrice,
    priceChanged,
    lineTotal,
    availableStock,
    status,
    message,
  ];
}

/// `POST /pre-orders/check` — validation only, nothing is created. It answers
/// 200 even when items are unavailable; that is a normal result, not an error.
class PreOrderCheck extends Equatable {
  const PreOrderCheck({
    required this.available,
    required this.totalPrice,
    this.priceChanged = false,
    this.checkedAt,
    this.items = const [],
  });

  /// Every line is in stock in the requested quantity — safe to enable the
  /// "Place order" button.
  final bool available;

  /// At least one price differs from what was stored before this check.
  final bool priceChanged;

  /// Sum of the **available** lines only, at current prices.
  final num totalPrice;

  final DateTime? checkedAt;
  final List<PreOrderCheckItem> items;

  /// The lines to highlight in the cart.
  List<PreOrderCheckItem> get problems =>
      items.where((item) => !item.isAvailable).toList();

  @override
  List<Object?> get props => [
    available,
    priceChanged,
    totalPrice,
    checkedAt,
    items,
  ];
}
