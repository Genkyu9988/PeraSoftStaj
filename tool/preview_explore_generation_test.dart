// Optional raster QA; a widget-test render, not a real device screenshot.
// Pass MODY_PREVIEW_DIR and optionally MODY_PREVIEW_FONT as dart-defines.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import '../test/helpers/controlled_generation_service.dart';

void main() {
  const output = String.fromEnvironment('MODY_PREVIEW_DIR');
  const font = String.fromEnvironment('MODY_PREVIEW_FONT');
  testWidgets(
    'Render Explore loading, error and request-specific results',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (font.isNotEmpty) {
        await tester.runAsync(() async {
          await (FontLoader('Roboto')
                ..addFont(File(font).readAsBytes().then(ByteData.sublistView)))
              .load();
        });
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      final boundaryKey = GlobalKey();
      Future<void> capture(String name) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(output).create(recursive: true);
          await File(
            '$output/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      for (final title in [
        'Customize Rims',
        'Window Tints',
        'Japanese',
        'Clone Car Style',
      ]) {
        final service = ControlledGenerationService();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MyApp(
              key: ValueKey(title),
              home: ExploreDetailView(
                title: title,
                coverImagePath: ImageItems.exploreCovers[title],
                isCarMod: CarModCatalog.groups.containsKey(title),
                generationService: service,
                initialSelection: ExploreSelection(
                  image: 'mustang_classic',
                  option: CarModCatalog.groups[title]?.first.id ?? '',
                  referenceImage: ReferenceCarCatalog.items.first.id,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(ExploreDetailView));
        final imagePaths = {
          for (final vehicle in VehicleCatalog.samples) vehicle.imagePath,
          ?ImageItems.exploreCovers[title],
          ?CarModCatalog.groups[title]?.first.imagePath,
          if (title == 'Clone Car Style')
            ReferenceCarCatalog.items.first.imagePath,
        };
        await tester.runAsync(() async {
          for (final path in imagePaths) {
            await precacheImage(AssetImage(path), context);
          }
        });
        final action = find.text('Arabamı Modifiye Et');
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        await tester.tap(action);
        await tester.pump();
        if (title == 'Customize Rims') {
          await tester.pump(const Duration(milliseconds: 500));
          await capture('loading');
          service.fail();
          await tester.pumpAndSettle();
          await capture('failure');
          await tester.tap(find.text('Tekrar Dene'));
          await tester.pump();
          service.succeed(1);
        } else {
          service.succeed();
        }
        await tester.pumpAndSettle();
        await capture(title.replaceAll(' ', '_').toLowerCase());
        expect(tester.takeException(), isNull);
      }
    },
    skip: output.isEmpty,
  );
}
