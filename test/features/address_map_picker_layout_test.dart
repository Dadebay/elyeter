import 'package:elyeter/core/constants/app_icons.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/widgets/elyeter_map.dart';
import 'package:elyeter/features/address/presentation/view/address_map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  testWidgets('map stays large, uses a location pin, and has no info button', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AddressMapPickerPage()),
    );

    final map = tester.getRect(find.byType(ElyeterMap));
    final sheet = tester.getRect(find.byType(SingleChildScrollView));
    expect(map.height, greaterThan(844 * 0.5));
    expect(map.bottom, greaterThan(sheet.top));
    expect(find.text('© OpenStreetMap'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('© OpenStreetMap'),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    expect(find.textContaining('contributors'), findsNothing);
    expect(find.textContaining('flutter_map'), findsNothing);
    expect(AppIcons.mapPin, HugeIcons.strokeRoundedLocation01);
    expect(
      tester.widget<HugeIcon>(find.byKey(const Key('address-map-pin'))).icon,
      AppIcons.mapPin,
    );

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('© OpenStreetMap'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is HugeIcon && widget.icon == AppIcons.information,
      ),
      findsNothing,
    );
  });
}
