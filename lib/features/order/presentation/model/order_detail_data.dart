import '../../../product/presentation/widgets/product_card.dart';

/// The stages an order passes through, in the order they happen.
///
/// The labels are localized where they are drawn, so a stage is a value here
/// rather than a string — the API will send one of these, not English.
enum OrderStage { placed, chinaWarehouse, shipped, arrived, delivered }

/// One stage of an order, and when it happened.
class OrderStageEntry {
  const OrderStageEntry({
    required this.stage,
    required this.at,
    this.done = false,
  });

  final OrderStage stage;
  final DateTime at;

  /// Whether the order has reached this stage yet. The last [done] entry is
  /// where the order currently stands.
  final bool done;
}

/// Everything the order page shows about one order.
class OrderDetailData {
  const OrderDetailData({
    required this.number,
    required this.stages,
    required this.products,
    required this.itemCount,
    required this.productsTotal,
    required this.pickupPoint,
    required this.recipientName,
    required this.recipientPhone,
    required this.placedAt,
    required this.deliveryFee,
    required this.cargoFee,
    required this.discount,
  });

  final String number;
  final List<OrderStageEntry> stages;

  /// Catalog entries for the thumbnail strip. May be shorter than
  /// [itemCount] — the strip shows a few and counts the rest.
  final List<ProductCardData> products;

  final int itemCount;
  final num productsTotal;

  final String pickupPoint;
  final String recipientName;
  final String recipientPhone;
  final DateTime placedAt;

  /// Zero reads as "Free" rather than as `0 TMT`.
  final num deliveryFee;

  final num cargoFee;

  /// Taken off the total; stored positive and shown with its minus sign.
  final num discount;

  num get total => productsTotal + deliveryFee + cargoFee - discount;

  /// How far along the order is — the last stage it has reached.
  OrderStageEntry? get currentStage {
    OrderStageEntry? current;
    for (final entry in stages) {
      if (entry.done) current = entry;
    }
    return current;
  }
}
