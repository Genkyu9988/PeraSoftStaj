import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/feature/generate/view/widget/detail_adjustment_panel.dart';

import 'detail_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All active catalog photos are bundled and decode correctly', () async {
    final paths = {
      ...VehicleCatalog.all.map((car) => car.imagePath),
      ...ImageItems.styleOptions.values,
      ...ImageItems.extraOptions.values,
      ...ImageItems.angleOptions.values,
      ...DetailPartCatalog.all.expand((category) => category.images),
      ...ImageItems.exploreCovers.values,
      ...ImageItems.aiVideoCovers.values,
      ...CarModCatalog.groups.values
          .expand((items) => items)
          .map((item) => item.imagePath),
    };
    expect(paths, hasLength(87));
    expect(ImageItems.angleOptions, hasLength(3));
    expect(DetailPartCatalog.all, hasLength(9));
    for (final category in DetailPartCatalog.all) {
      expect(category.images, hasLength(3));
    }
    expect(VehicleCatalog.samples, hasLength(5));
    final credits = await rootBundle.loadString(ImageItems.credits);
    for (final path in paths) {
      final bytes = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(100));
      expect(credits, contains(path.split('/').last));
      frame.image.dispose();
      codec.dispose();
    }
  });

  for (final width in [320.0, 390.0]) {
    for (final angle in DetailPartCatalog.byAngle.keys) {
      testWidgets('$angle images and Apply are reachable at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MyApp());
        await tester.tap(find.text('Detail Edit'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Açı'));
        await tester.pumpAndSettle();
        for (final entry in ImageItems.angleOptions.entries) {
          final card = find.byKey(Key('option${entry.key}'));
          final image = tester.widget<ModyAssetImage>(
            find.descendant(of: card, matching: find.byType(ModyAssetImage)),
          );
          expect(image.path, entry.value);
        }
        await tester.tap(find.text(angle));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ayarla'));
        await tester.pumpAndSettle();
        final expectedCategories = DetailPartCatalog.forAngle(angle);
        expect(
          tester
              .widget<DetailAdjustmentPanel>(find.byType(DetailAdjustmentPanel))
              .categories,
          expectedCategories,
        );
        for (final category in expectedCategories) {
          for (var index = 0; index < category.images.length; index++) {
            final card = await revealDetailPart(tester, category.title, index);
            final image = tester.widget<ModyAssetImage>(
              find.descendant(of: card, matching: find.byType(ModyAssetImage)),
            );
            expect(image.path, category.images[index]);
            await tester.tap(card);
            await tester.pumpAndSettle();
            expect(tester.widget<Semantics>(card).properties.selected, isTrue);
            expect(find.text('Uygula').hitTestable(), findsOneWidget);
          }
        }
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('selectionAyarla')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Missing asset has an accessible fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ModyAssetImage(path: 'assets/missing.jpg', width: 80, height: 80),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Style and Extra cards use the matching local images', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(find.byType(ModyAssetImage), findsWidgets);
    for (final section in ['Stil', 'Ekstra']) {
      await tester.tap(find.text(section));
      await tester.pumpAndSettle();
      final images = section == 'Stil'
          ? ImageItems.styleOptions
          : ImageItems.extraOptions;
      for (final entry in images.entries) {
        final card = find.byKey(Key('option${entry.key}'));
        final image = tester.widget<ModyAssetImage>(
          find.descendant(of: card, matching: find.byType(ModyAssetImage)),
        );
        expect(image.path, entry.value);
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
    }
    expect(find.byTooltip('Görsel kaynakları'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
