import 'package:dio/dio.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/address/presentation/view/address_list_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _AddressApi extends ShopApi {
  _AddressApi(List<SavedLocation> items)
    : items = List.of(items),
      super(ApiClient(Dio()));

  final List<SavedLocation> items;
  int requests = 0;

  @override
  Future<List<SavedLocation>> locations() async {
    requests++;
    return items;
  }

  @override
  Future<void> deleteLocation(int id) async {
    items.removeWhere((item) => item.id == id);
  }
}

void main() {
  tearDown(() async => getIt.reset());

  Future<void> pumpPage(WidgetTester tester, _AddressApi api) async {
    getIt.registerSingleton<ShopApi>(api);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AddressListPage(title: 'My saved locations'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty address list shows illustration and can refresh', (
    tester,
  ) async {
    final api = _AddressApi(const []);
    await pumpPage(tester, api);

    expect(api.requests, 1);
    expect(find.text('No saved addresses yet'), findsOneWidget);
    expect(
      find.text('Tap + to save your first delivery address.'),
      findsOneWidget,
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/address_empty_3d.png',
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(api.requests, 2);
  });

  testWidgets('saved addresses show the list instead of the empty state', (
    tester,
  ) async {
    final api = _AddressApi(const [
      SavedLocation(
        id: 3,
        name: 'Home',
        latitude: 37.96,
        longitude: 58.32,
        isDefault: true,
      ),
    ]);
    await pumpPage(tester, api);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('No saved addresses yet'), findsNothing);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('deleting an address shows the styled success snackbar', (
    tester,
  ) async {
    final api = _AddressApi(const [
      SavedLocation(
        id: 3,
        name: 'Home',
        latitude: 37.96,
        longitude: 58.32,
        isDefault: true,
      ),
    ]);
    await pumpPage(tester, api);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(api.items, isEmpty);
    expect(find.text('Address deleted.'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
