import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/widget/mock_options.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';

void main() {
  test('Every Explore cover maps to an existing option', () {
    expect(ImageItems.exploreCovers.keys.toSet(), {
      ...ExploreItems.carMods,
      ...ExploreItems.styleBuilder,
      ...ExploreItems.wallpaperMaker,
      ...ExploreItems.aiEdits,
    });
    expect(ImageItems.exploreCovers, hasLength(37));
  });

  testWidgets('All cover widgets show their matching image', (tester) async {
    for (final entry in ImageItems.exploreCovers.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: MockOptionCard(title: entry.key, imagePath: entry.value),
            ),
          ),
        ),
      );
      expect(
        tester.widget<ModyAssetImage>(find.byType(ModyAssetImage)).path,
        entry.value,
      );
      expect(find.text(entry.key), findsOneWidget);
      expect(find.text('Mock'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  test('Explore catalogs match the original section counts', () {
    expect(ExploreItems.carMods, hasLength(16));
    expect(ExploreItems.aiEdits, hasLength(11));
    for (final items in [
      ExploreItems.styleBuilder,
      ExploreItems.wallpaperMaker,
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
      for (final title in ExploreItems.carMods.take(9)) {
        expect(find.text(title), findsOneWidget);
      }
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(ModyAssetImage), findsWidgets);
      for (final title in ExploreItems.carMods.take(9)) {
        final card = tester.widget<MockOptionCard>(
          find.byWidgetPredicate(
            (widget) => widget is MockOptionCard && widget.title == title,
          ),
        );
        expect(card.imagePath, ImageItems.exploreCovers[title]);
      }
      expect(
        tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).selectedIndex,
        1,
      );
      await tester.tap(find.text('Change Color'));
      await tester.pumpAndSettle();
      expect(find.byType(ExploreView, skipOffstage: false), findsOneWidget);
      expect(find.text('Resim Seçin'), findsOneWidget);
      expect(
        tester
            .widget<ModyAssetImage>(find.byKey(const Key('detailCover')))
            .path,
        ImageItems.exploreCovers['Change Color'],
      );
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      expect(find.text('Klasik Mustang'), findsOneWidget);
      // The cover stays behind the sheet; the catalog supplies real photos.
      expect(
        find.descendant(
          of: find.byType(VehicleSelectionPanel),
          matching: find.byType(ModyAssetImage),
        ),
        findsWidgets,
      );
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
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
      await tester.drag(
        find.byKey(const Key('exploreScroll')),
        const Offset(0, -150),
      );
      await tester.pumpAndSettle();
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
      await tester.drag(
        find.byKey(const Key('exploreScroll')),
        const Offset(0, -150),
      );
      await tester.pumpAndSettle();
      await tester.drag(wallpaperList, const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Night City').hitTestable(), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('AI Crash Effect'),
        150,
        scrollable: vertical,
      );
      for (final title in ExploreItems.aiEdits.take(9)) {
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
