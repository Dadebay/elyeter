import '../../../home/presentation/view/home_placeholder_data.dart';
import '../model/order_detail_data.dart';

/// Stand-in order content until the orders API exists. Drop it once
/// `OrderBloc` supplies the real thing — the page takes plain values, so
/// nothing else moves.
abstract final class OrderPlaceholderData {
  /// The order the page opens on when it is reached without an id.
  static OrderDetailData get active => OrderDetailData(
    number: '0248248518-0003',
    // Only the first stage has happened: the rest are what the customer is
    // waiting for, and are drawn greyed out.
    stages: [
      OrderStageEntry(
        stage: OrderStage.placed,
        at: DateTime(2026, 8, 20, 7, 56),
        done: true,
      ),
      OrderStageEntry(
        stage: OrderStage.chinaWarehouse,
        at: DateTime(2026, 8, 20, 10, 28),
      ),
      OrderStageEntry(
        stage: OrderStage.shipped,
        at: DateTime(2026, 8, 20, 15, 32),
      ),
      OrderStageEntry(
        stage: OrderStage.arrived,
        at: DateTime(2026, 8, 20, 16, 56),
      ),
      OrderStageEntry(
        stage: OrderStage.delivered,
        at: DateTime(2026, 8, 20, 9, 10),
      ),
    ],
    products: HomePlaceholderData.products.take(5).toList(),
    itemCount: 10,
    productsTotal: 250,
    pickupPoint: 'Aşgabat şäheri, Köpetdag etraby\nAndalyp köçesi 541 - jaýy',
    recipientName: 'Maksat Myradow',
    recipientPhone: '+993 65 00 00 00',
    placedAt: DateTime(2026, 8, 20, 0, 40),
    deliveryFee: 0,
    cargoFee: 40,
    discount: 10,
  );
}
