import 'package:elyeter/core/theme/theme_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dark reveals from left and light reveals from right', (
    tester,
  ) async {
    final key = GlobalKey<ThemeRevealState>();
    late StateSetter update;
    var dark = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return MaterialApp(
            theme: dark ? ThemeData.dark() : ThemeData.light(),
            themeAnimationDuration: Duration.zero,
            home: ThemeReveal(
              key: key,
              child: Center(child: Text(dark ? 'Dark screen' : 'Light screen')),
            ),
          );
        },
      ),
    );
    await tester.pump();

    final transition = key.currentState!.run(
      () => update(() => dark = true),
      direction: ThemeRevealDirection.leftToRight,
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(find.text('Dark screen'), findsOneWidget);
    final wipe = find.byKey(const ValueKey('theme-reveal-wipe'));
    expect(wipe, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 325));
    final clip = tester.widget<ClipRect>(wipe);
    final visibleOldScreen = clip.clipper!.getClip(const Size(800, 600));
    expect(visibleOldScreen.left, greaterThan(0));
    expect(visibleOldScreen.left, lessThan(800));
    expect(visibleOldScreen.right, 800);

    await tester.pumpAndSettle();
    await transition;
    expect(wipe, findsNothing);

    final reverseTransition = key.currentState!.run(
      () => update(() => dark = false),
      direction: ThemeRevealDirection.rightToLeft,
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(find.text('Light screen'), findsOneWidget);
    expect(wipe, findsOneWidget);
    final startingClip = tester
        .widget<ClipRect>(wipe)
        .clipper!
        .getClip(const Size(800, 600));
    expect(startingClip, const Rect.fromLTWH(0, 0, 800, 600));

    await tester.pump(const Duration(milliseconds: 325));
    final reverseClip = tester
        .widget<ClipRect>(wipe)
        .clipper!
        .getClip(const Size(800, 600));
    expect(reverseClip.left, 0);
    expect(reverseClip.right, greaterThan(0));
    expect(reverseClip.right, lessThan(800));

    await tester.pumpAndSettle();
    await reverseTransition;
    expect(wipe, findsNothing);
  });
}
