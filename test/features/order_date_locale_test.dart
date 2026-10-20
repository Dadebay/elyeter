import 'dart:async';

import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/order/domain/entities/pre_order.dart';
import 'package:elyeter/features/order/domain/repositories/pre_order_repository.dart';
import 'package:elyeter/features/order/presentation/model/order_detail_data.dart';
import 'package:elyeter/features/order/presentation/receipt/order_receipt_pdf.dart';
import 'package:elyeter/features/order/presentation/view/order_detail_page.dart';
import 'package:elyeter/features/order/presentation/view/order_list_page.dart';
import 'package:elyeter/features/order/presentation/widgets/order_progress_timeline.dart';
import 'package:elyeter/features/order/presentation/widgets/order_total_card.dart';
import 'package:elyeter/features/product/presentation/widgets/product_price_details_sheet.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

final _date = DateTime(2026, 10, 20, 0, 33);
final _order = PreOrder(
  id: 1,
  number: 'PO-000001',
  status: PreOrderStatus.newOrder,
  totalPrice: 100,
  createdAt: _date,
);

class _Orders extends Fake implements PreOrderRepository {
  @override
  Future<Result<PreOrder>> byId(int id) async => Success(_order);

  @override
  Future<Result<Paginated<PreOrder>>> list({
    int page = 1,
    int size = 20,
    PreOrderStatus? status,
  }) async => Success(Paginated(items: [_order], totalCount: 1, page: 1));
}

Widget _app(Widget child, {String locale = 'tk'}) => MaterialApp(
  theme: AppTheme.light,
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: [
    ...AppLocalizations.localizationsDelegates,
    ...FallbackLocalizations.delegates,
  ],
  home: child,
);

void main() {
  setUp(() {
    final previousLocale = Intl.defaultLocale;
    Intl.defaultLocale = 'tk';
    addTearDown(() => Intl.defaultLocale = previousLocale);
  });
  tearDown(() => getIt.reset());

  for (final locale in ['en', 'ru']) {
    testWidgets('$locale prices follow the app language after switching', (
      tester,
    ) async {
      // The device/default locale deliberately differs from the app language.
      Intl.defaultLocale = locale == 'en' ? 'ru' : 'en';
      final order = OrderDetailData.fromPreOrder(
        PreOrder(
          id: 2,
          number: 'PO-2',
          status: PreOrderStatus.newOrder,
          totalPrice: 1234.5,
          createdAt: _date,
        ),
      );
      final total = locale == 'ru' ? '1\u2009234,50 TMT' : '1\u2009234.50 TMT';
      for (final language in ['tk', locale]) {
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SingleChildScrollView(child: OrderTotalCard(order: order)),
            ),
            locale: language,
          ),
        );
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      expect(find.text(total, findRichText: true), findsOneWidget);

      final context = tester.element(find.byType(OrderTotalCard));
      unawaited(
        showProductPriceDetailsSheet(
          context,
          name: 'Test product',
          price: 1234,
          oldPrice: 2468,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.text(locale == 'ru' ? '2\u00a0468 TMT' : '2,468 TMT'),
        findsOneWidget,
      );
    });
  }

  test(
    'Turkmen receipt formats dates and amounts without an invalid locale',
    () async {
      final bytes = await OrderReceiptPdf.build(
        _order,
        ReceiptLabels(
          title: 'Çek',
          number: (value) => 'Number $value',
          status: 'Status',
          customer: 'Customer',
          address: 'Address',
          date: 'Date',
          products: 'Products',
          quantity: 'Quantity',
          price: 'Price',
          amount: 'Amount',
          productsTotal: 'Products total',
          delivery: 'Delivery',
          free: 'Free',
          cargo: 'Cargo',
          discount: 'Discount',
          total: 'Total',
          thanks: 'Sag boluň',
        ),
        locale: 'tk',
      );
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    },
  );

  testWidgets('timeline renders dated stages in Turkmen', (tester) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: OrderProgressTimeline(
            stages: [
              OrderStageEntry(stage: OrderStage.placed, at: _date, done: true),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Okt 20, 00:33'), findsOneWidget);
  });

  testWidgets('order history renders a dated order in Turkmen', (tester) async {
    getIt.registerSingleton<PreOrderRepository>(_Orders());
    await tester.pumpWidget(_app(const OrderListPage(title: 'Sargytlar')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Okt 20, 00:33'), findsOneWidget);
  });

  testWidgets('order detail renders its date and timeline in Turkmen', (
    tester,
  ) async {
    getIt.registerSingleton<PreOrderRepository>(_Orders());
    await tester.pumpWidget(_app(const OrderDetailPage(orderId: 1)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Okt 20, 2026 00:33'), 300);
    expect(find.text('Okt 20, 2026 00:33'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
