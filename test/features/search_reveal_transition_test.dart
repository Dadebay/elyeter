import 'package:elyeter/features/search/presentation/widgets/search_reveal_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('category search field widens as the page rises from below', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = AnimationController(
      vsync: tester,
      duration: SearchRevealTransition.duration,
      reverseDuration: SearchRevealTransition.reverseDuration,
    );
    addTearDown(controller.dispose);
    const button = Rect.fromLTWH(324, 56, 50, 36);
    await tester.pumpWidget(
      MaterialApp(
        home: SearchButtonExpandTransition(
          animation: controller,
          buttonBounds: button,
          child: const ColoredBox(
            key: Key('search-page-content'),
            color: Colors.white,
          ),
        ),
      ),
    );

    Rect surfaceBounds() =>
        tester.getRect(find.byKey(const Key('search-button-surface')));

    double pageTop() =>
        tester.getTopLeft(find.byKey(const Key('search-page-content'))).dy;

    double contentOffset() => tester
        .widget<SlideTransition>(
          find.byKey(const Key('search-button-content-rise')),
        )
        .position
        .value
        .dy;

    expect(surfaceBounds(), button);
    expect(contentOffset(), 1);
    expect(pageTop(), closeTo(844, 1));
    controller.forward();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(surfaceBounds().width, greaterThan(button.width));
    expect(surfaceBounds().bottom, lessThanOrEqualTo(button.bottom));
    expect(contentOffset(), 1);

    await tester.pump(const Duration(milliseconds: 120));
    expect(surfaceBounds(), const Rect.fromLTWH(56, 12, 314, 48));
    expect(contentOffset(), inExclusiveRange(0, 1));
    expect(pageTop(), inExclusiveRange(0, 844));
    await tester.pumpAndSettle();
    expect(contentOffset(), 0);
    expect(pageTop(), closeTo(0, 1));

    controller.reverse();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(surfaceBounds().width, lessThan(314));
    expect(contentOffset(), greaterThan(0));
    await tester.pumpAndSettle();
    expect(surfaceBounds(), button);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category search uses a fade when animations are disabled', (
    tester,
  ) async {
    final controller = AnimationController(vsync: tester);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: SearchButtonExpandTransition(
          animation: controller,
          buttonBounds: const Rect.fromLTWH(324, 56, 50, 36),
          child: const ColoredBox(color: Colors.white),
        ),
      ),
    );
    expect(find.byKey(const Key('search-button-surface')), findsNothing);
    expect(find.byKey(const Key('search-button-reduced-fade')), findsOneWidget);
  });

  testWidgets('reversing mid-reveal preserves the panel bounds and crossfade', (
    tester,
  ) async {
    final controller = AnimationController(
      vsync: tester,
      duration: SearchRevealTransition.duration,
      reverseDuration: SearchRevealTransition.reverseDuration,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: SearchRevealTransition(
          animation: controller,
          fieldBounds: const Rect.fromLTWH(16, 52, 368, 48),
          child: const ColoredBox(color: Colors.white),
        ),
      ),
    );

    RRect visibleBounds() {
      final clip = find.byKey(const Key('search-reveal-clip'));
      return tester
          .widget<ClipRRect>(clip)
          .clipper!
          .getClip(tester.getSize(clip));
    }

    double opacity() => tester
        .widget<FadeTransition>(find.byKey(const Key('search-reveal-fade')))
        .opacity
        .value;

    final start = visibleBounds();
    expect(opacity(), 0);
    expect(start.outerRect, const Rect.fromLTWH(16, 52, 368, 48));
    expect(start.tlRadiusX, 24);
    controller.forward();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    final beforeReverse = visibleBounds();
    final beforeOpacity = opacity();
    expect(beforeOpacity, inExclusiveRange(0, 1));
    expect(beforeReverse.bottom, greaterThan(100));
    expect(beforeReverse.left, lessThan(start.left));

    controller.reverse();
    await tester.pump();
    expect(visibleBounds(), beforeReverse);
    expect(opacity(), closeTo(beforeOpacity, 0.001));
    await tester.pump(const Duration(milliseconds: 30));
    expect(visibleBounds().bottom, lessThan(beforeReverse.bottom));
    expect(opacity(), lessThan(beforeOpacity));
    await tester.pumpAndSettle();
    expect(visibleBounds(), start);
    expect(opacity(), 0);
    expect(tester.takeException(), isNull);
  });
}
