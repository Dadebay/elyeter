import 'package:elyeter/core/theme/app_colors.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/widgets/app_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loader uses the spoke indicator with theme contrast', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AppLoader()),
      ),
    );
    expect(
      tester
          .widget<CupertinoActivityIndicator>(
            find.byType(CupertinoActivityIndicator),
          )
          .color,
      AppColors.primary,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: AppLoader()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<CupertinoActivityIndicator>(
            find.byType(CupertinoActivityIndicator),
          )
          .color,
      AppColors.white,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: AppLoader(color: AppColors.white)),
      ),
    );
    expect(
      tester
          .widget<CupertinoActivityIndicator>(
            find.byType(CupertinoActivityIndicator),
          )
          .color,
      AppColors.white,
    );
  });
}
