import 'package:equatable/equatable.dart';

/// Where an order stands. Statuses only move forward along
/// `NEW -> CONFIRMED -> ORDERED -> COMPLETED`; a manager can cancel from any
/// of the first three, and the last two are terminal.
enum PreOrderStatus {
  /// Submitted, waiting for a manager to call.
  newOrder('NEW'),
  confirmed('CONFIRMED'),
  ordered('ORDERED'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const PreOrderStatus(this.value);

  final String value;

  static PreOrderStatus parse(String? value) => PreOrderStatus.values
      .firstWhere((s) => s.value == value, orElse: () => PreOrderStatus.newOrder);

  bool get isTerminal =>
      this == PreOrderStatus.completed || this == PreOrderStatus.cancelled;

  /// Whether the order is still on its way — what the "active orders" screen
  /// lists.
  bool get isActive => !isTerminal;
}

/// One line of a placed order. A snapshot taken at checkout: name and price
/// stay frozen even if the product is repriced later, so never re-fetch them
/// from the catalog to display an order.
class PreOrderItem extends Equatable {
  const PreOrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    this.productSlug,
    this.variantId,
    this.sku,
    this.variant,
    this.image,
  });

  final int id;
  final int productId;

  /// Deep-links to the product page; null when the product has since been
  /// removed from the catalog — hide the link in that case.
  final String? productSlug;

  final int? variantId;
  final String? sku;
  final String name;
  final String? variant;
  final String? image;
  final int quantity;
  final num price;
  final num lineTotal;

  @override
  List<Object?> get props => [
    id,
    productId,
    productSlug,
    variantId,
    sku,
    name,
    variant,
    image,
    quantity,
    price,
    lineTotal,
  ];
}

/// A placed pre-order. There is no payment in the app: a manager calls the
/// customer back and places the order with the supplier.
class PreOrder extends Equatable {
  const PreOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.totalPrice,
    this.currency = 'TMT',
    this.itemsCount = 0,
    this.customerName,
    this.phone,
    this.address,
    this.comment,
    this.createdAt,
    this.statusChangedAt,
    this.canCancel = false,
    this.items = const [],
    this.priceChanged = false,
  });

  final int id;

  /// `PO-000001` — the reference to show and to quote on a support call.
  final String number;

  final PreOrderStatus status;
  final num totalPrice;
  final String currency;

  /// Total **units** (sum of quantity), not the number of lines.
  final int itemsCount;

  final String? customerName;
  final String? phone;
  final String? address;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? statusChangedAt;

  /// Whether `POST /pre-orders/:id/cancel` will currently succeed.
  final bool canCancel;

  final List<PreOrderItem> items;

  /// Only set on the checkout response.
  final bool priceChanged;

  @override
  List<Object?> get props => [
    id,
    number,
    status,
    totalPrice,
    currency,
    itemsCount,
    customerName,
    phone,
    address,
    comment,
    createdAt,
    statusChangedAt,
    canCancel,
    items,
    priceChanged,
  ];
}
