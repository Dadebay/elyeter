import '../../../product/presentation/widgets/product_card.dart';
import '../../domain/entities/pre_order.dart';

/// The stages an order passes through, in the order they happen.
///
/// The labels are localized where they are drawn, so a stage is a value here
/// rather than a string — the API will send one of these, not English.
enum OrderStage { placed, chinaWarehouse, shipped, arrived, delivered }

/// How an order ended up, which is what the page's header and timeline are
/// drawn from: still on its way, delivered, or called off.
enum OrderOutcome { active, completed, cancelled }

/// One stage of an order, and when it happened.
class OrderStageEntry {
  const OrderStageEntry({
    required this.stage,
    this.at,
    this.done = false,
    this.cancelled = false,
  });

  final OrderStage stage;

  /// When it happened. Null when the API does not say — it records only when
  /// the order was placed and when its status last changed.
  final DateTime? at;

  /// The stage the order was cancelled at: drawn in red rather than greyed.
  final bool cancelled;

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
    this.outcome = OrderOutcome.active,
    this.canCancel = false,
    this.comment,
  });

  /// Reads a placed pre-order into what the page draws.
  ///
  /// The API has four statuses where the design has five stages, and one
  /// timestamp besides the day the order was placed, so the stages are worked
  /// out from the status and only the ones with a known time carry a date.
  /// Delivery, cargo and discount are not separate figures in the API: what
  /// the total comes to beyond the goods is shown as cargo, and a total below
  /// the goods as a discount.
  factory OrderDetailData.fromPreOrder(
    PreOrder order, {
    Map<int, String> photos = const {},
  }) {
    // With no lines to add up, the order's own total stands in for the goods
    // rather than reading as all cargo.
    final productsTotal = order.items.isEmpty
        ? order.totalPrice
        : order.items.fold<num>(0, (sum, item) => sum + item.lineTotal);
    final extra = order.totalPrice - productsTotal;

    final outcome = switch (order.status) {
      PreOrderStatus.completed => OrderOutcome.completed,
      PreOrderStatus.cancelled => OrderOutcome.cancelled,
      _ => OrderOutcome.active,
    };

    return OrderDetailData(
      number: order.number,
      stages: _stagesFor(order),
      products: [
        for (final item in order.items)
          ProductCardData(
            id: item.productId.toString(),
            slug: item.productSlug,
            apiId: item.productId,
            title: item.name,
            price: item.price,
            images: switch (photos[item.productId] ?? item.image) {
              final String url => [url],
              _ => const [],
            },
            specs: [
              if (item.variant != null && item.variant!.isNotEmpty)
                item.variant!,
            ],
          ),
      ],
      // The API's own count of units where it gave one, else the lines added up.
      itemCount: order.itemsCount > 0
          ? order.itemsCount
          : order.items.fold(0, (sum, item) => sum + item.quantity),
      productsTotal: productsTotal,
      pickupPoint: order.address ?? '',
      recipientName: order.customerName ?? '',
      recipientPhone: order.phone ?? '',
      placedAt: order.createdAt ?? DateTime.now(),
      deliveryFee: 0,
      cargoFee: extra > 0 ? extra : 0,
      discount: extra < 0 ? -extra : 0,
      outcome: outcome,
      canCancel: order.canCancel,
      comment: order.comment,
    );
  }

  static List<OrderStageEntry> _stagesFor(PreOrder order) {
    const stages = OrderStage.values;
    final placed = order.createdAt;
    final changed = order.statusChangedAt;

    // How many stages from the start have been reached.
    final reached = switch (order.status) {
      PreOrderStatus.newOrder ||
      PreOrderStatus.confirmed ||
      PreOrderStatus.cancelled => 1,
      PreOrderStatus.ordered => 2,
      PreOrderStatus.completed => stages.length,
    };

    return [
      for (var i = 0; i < stages.length; i++)
        OrderStageEntry(
          stage: stages[i],
          done: i < reached,
          // The day it was placed, and the last change on whatever it last
          // reached; the stages in between happened at times the API does
          // not record.
          at: i == 0
              ? placed
              : (i == reached - 1 ||
                    (order.status == PreOrderStatus.cancelled && i == 1))
              ? changed
              : null,
          cancelled: order.status == PreOrderStatus.cancelled && i == 1,
        ),
    ];
  }

  final OrderOutcome outcome;

  /// Whether the order can still be cancelled from the app.
  final bool canCancel;

  /// What the customer wrote at checkout, if anything.
  final String? comment;

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
