import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/features/profile/presentation/widgets/language_flag.dart';
import 'package:elyeter/features/profile/presentation/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected language shows only its circular flag on the right', (
    tester,
  ) async {
    Future<void> showLanguage(String code, String name) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SettingsTile(
                    icon: AppAssets.iconGlobe,
                    label: 'Language',
                    trailing: TileFlag(languageCode: code, label: name),
                  ),
                  const SettingsTile(
                    icon: AppAssets.iconGlobe,
                    label: 'Another setting',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await showLanguage('tk', 'Türkmençe');
    await tester.pumpAndSettle();
    final flagFinder = find.byType(LanguageFlag);
    expect(flagFinder, findsOneWidget);
    expect(
      tester.getRect(flagFinder).center.dx,
      greaterThan(tester.getRect(find.byType(SettingsTile).first).center.dx),
    );
    expect(
      tester.getSize(find.byType(SettingsTile).first).height,
      tester.getSize(find.byType(SettingsTile).last).height,
    );
    expect(find.text('Türkmençe'), findsNothing);
    expect(
      find.descendant(of: flagFinder, matching: find.byType(ClipOval)),
      findsOneWidget,
    );
    final flagImage = find.descendant(
      of: flagFinder,
      matching: find.byType(SvgPicture),
    );
    expect(
      (tester.widget<SvgPicture>(flagImage).bytesLoader as SvgAssetLoader)
          .assetName,
      'assets/images/flags/tm.svg',
    );

    await showLanguage('ru', 'Русский');
    await tester.pumpAndSettle();
    expect(
      (tester.widget<SvgPicture>(flagImage).bytesLoader as SvgAssetLoader)
          .assetName,
      'assets/images/flags/ru.svg',
    );
    expect(tester.takeException(), isNull);
  });
}
