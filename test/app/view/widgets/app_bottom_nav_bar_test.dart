import 'package:elyeter/app/view/widgets/app_bottom_nav_bar.dart';
import 'package:elyeter/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const items = [
    AppNavItem(asset: AppAssets.iconHome, label: 'Home'),
    AppNavItem(asset: AppAssets.iconCategory, label: 'Category'),
    AppNavItem(asset: AppAssets.iconCart, label: 'Cart'),
  ];

  Widget wrap({required ValueChanged<int> onTap, int currentIndex = 0}) =>
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
          ),
        ),
      );

  testWidgets('renders every item label', (tester) async {
    await tester.pumpWidget(wrap(onTap: (_) {}));

    for (final item in items) {
      expect(find.text(item.label), findsOneWidget);
    }
  });

  testWidgets('reports the tapped index', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(wrap(onTap: tapped.add));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(tapped, [2]);
  });
}
