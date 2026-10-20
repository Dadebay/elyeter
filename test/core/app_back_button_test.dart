import 'package:elyeter/core/theme/app_colors.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/widgets/app_asset_image.dart';
import 'package:elyeter/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('back button has a visible outline and icon in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Center(child: AppBackButton())),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppBackButton),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.grey900);
    expect(decoration.border!.top.color, AppColors.grey700);
    expect(
      tester.widget<AppAssetImage>(find.byType(AppAssetImage)).color,
      AppColors.white,
    );
  });

  testWidgets('AppBar leading uses its wide pill size by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leadingWidth: AppBackButton.leadingWidth,
            leading: const AppBackButton.appBarLeading(),
          ),
        ),
      ),
    );

    final backInkWell = find.descendant(
      of: find.byType(AppBar),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(backInkWell), const Size(50, 36));
  });
}
