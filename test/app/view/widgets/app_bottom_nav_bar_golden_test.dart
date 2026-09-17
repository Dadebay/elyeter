@Tags(['golden'])
library;

import 'package:elyeter/app/view/widgets/app_bottom_nav_bar.dart';
import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFonts() async {
  const families = {
    'InterDisplay': [
      'assets/fonts/InterDisplay-Regular.ttf',
      'assets/fonts/InterDisplay-Medium.ttf',
      'assets/fonts/InterDisplay-SemiBold.ttf',
      'assets/fonts/InterDisplay-Bold.ttf',
    ],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }
}

void main() {
  testWidgets('bottom nav bar golden', (tester) async {
    await _loadFonts();
    tester.view
      ..physicalSize = const Size(1170, 420)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
          // Simulate a gesture-bar phone to check the bar clears the indicator.
          data: MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
          child: Scaffold(
            backgroundColor: Color(0xFFE9E9E9),
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: _noop,
              items: [
                AppNavItem(asset: AppAssets.iconHome, label: 'Home'),
                AppNavItem(asset: AppAssets.iconCategory, label: 'Category'),
                AppNavItem(asset: AppAssets.iconCart, label: 'Cart'),
                AppNavItem(asset: AppAssets.iconFavorite, label: 'Favorite'),
                AppNavItem(asset: AppAssets.iconProfile, label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/bottom_nav_bar.png'),
    );
  });
}

void _noop(int _) {}
