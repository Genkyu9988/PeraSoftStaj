import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/explore/view/widget/explore_option_grid.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets(
      'Independent expansion, retained scroll and navigation $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MyApp(home: ExploreView()));
        final scrollable = find
            .descendant(
              of: find.byKey(const Key('exploreScroll')),
              matching: find.byType(Scrollable),
            )
            .first;
        Future<void> reveal(Finder target, double delta) async {
          await tester.scrollUntilVisible(
            target,
            delta,
            scrollable: scrollable,
          );
          await tester.pumpAndSettle();
        }

        final carButton = find.byKey(const Key('expandCarMods'));
        final aiButton = find.byKey(const Key('expandAiEdits'));
        expect(find.text('Chrome Delete'), findsNothing);
        expect(find.text('Transformers'), findsNothing);
        await reveal(carButton, 200);
        final position = tester.state<ScrollableState>(scrollable).position;
        final before = position.pixels;
        await tester.tap(carButton);
        await tester.pumpAndSettle();
        expect(position.pixels, closeTo(before, 1));
        expect(carButton, findsNothing);
        expect(find.text('Chrome Delete'), findsOneWidget);
        await reveal(find.text('Upholstery'), 200);
        await tester.tap(find.text('Upholstery'));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreDetailView), findsOneWidget);
        expect(find.text('Döşeme'), findsOneWidget);
        await tester.tap(find.byTooltip('Explore’a dön'));
        await tester.pumpAndSettle();
        await reveal(aiButton, 200);
        expect(find.text('Transformers'), findsNothing);
        await tester.tap(aiButton);
        await tester.pumpAndSettle();
        expect(aiButton, findsNothing);
        await reveal(find.text('Clone Car Style'), 200);
        expect(find.text('Transformers'), findsOneWidget);
        final aiGrid = tester
            .widgetList<ExploreOptionGrid>(find.byType(ExploreOptionGrid))
            .last;
        expect(aiGrid.expanded, isTrue);
        expect(aiGrid.titles, ExploreItems.aiEdits);
        await reveal(find.text('Change Color'), -300);
        await tester.tap(find.text('Change Color'));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreDetailView), findsOneWidget);
        await tester.tap(find.byTooltip('Explore’a dön'));
        await tester.pumpAndSettle();
        final carGrid = tester.widget<ExploreOptionGrid>(
          find.byType(ExploreOptionGrid).first,
        );
        expect(carGrid.expanded, isTrue);
        expect(carGrid.titles, ExploreItems.carMods);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
