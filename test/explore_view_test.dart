import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/demos/explore_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/explore_items.dart';
import 'package:perasoft_staj/product/mody_bottom_bar.dart';

void main() {
  test('Explore bölümleri beşer mock seçenek içerir', () {
    for (final items in [
      ExploreItems.carMods,
      ExploreItems.styleBuilder,
      ExploreItems.wallpaperMaker,
      ExploreItems.aiEdits,
    ]) {
      expect(items.length, 5);
      expect(items.toSet().length, 5);
    }
  });

  for (final width in [390.0, 320.0]) {
    testWidgets('Explore kaydırılır ve kart detayından geri dönülür: $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp(home: ExploreView()));

      expect(find.text('Car Mods'), findsOneWidget);
      for (final title in ExploreItems.carMods) {
        expect(find.text(title), findsOneWidget);
      }
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(
        tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).selectedIndex,
        1,
      );
      await tester.tap(find.text('Change Color'));
      await tester.pumpAndSettle();
      expect(find.byType(ExploreView, skipOffstage: false), findsOneWidget);
      expect(find.text('Resim Seçin'), findsOneWidget);
      await tester.tap(find.byTooltip('Explore’a dön'));
      await tester.pumpAndSettle();

      final vertical = find
          .descendant(
            of: find.byKey(const Key('exploreScroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('American'),
        150,
        scrollable: vertical,
      );
      final styleList = find
          .ancestor(of: find.text('American'), matching: find.byType(ListView))
          .first;
      await tester.drag(styleList, const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Racing').hitTestable(), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Most WT'),
        150,
        scrollable: vertical,
      );
      final wallpaperList = find
          .ancestor(of: find.text('Most WT'), matching: find.byType(ListView))
          .first;
      await tester.drag(wallpaperList, const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Night City').hitTestable(), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('AI Crash Effect'),
        150,
        scrollable: vertical,
      );
      for (final title in ExploreItems.aiEdits) {
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('Mody AI').hitTestable(), findsOneWidget);
      expect(find.text('Explore').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const Key('exploreScroll')),
        const Offset(0, 1600),
      );
      await tester.pumpAndSettle();
      expect(find.text('Car Mods').hitTestable(), findsOneWidget);
    });
  }
}
