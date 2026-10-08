// Optional widget-test renders, not screenshots from a device or video output.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import '../test/helpers/controlled_generation_service.dart';

void main() {
  const output = String.fromEnvironment('MODY_PREVIEW_DIR');
  const font = String.fromEnvironment('MODY_PREVIEW_FONT');
  testWidgets(
    'Render AI Video editor, loading, retry, results and cancellation',
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

      for (final title in ['Apex Transform', 'Cliff Drive', 'Race Video']) {
        final service = ControlledGenerationService();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MyApp(
              key: ValueKey(title),
              home: ExploreDetailView(
                title: title,
                isCarMod: false,
                isVideo: true,
                coverImagePath: ImageItems.aiVideoCovers[title],
                generationService: service,
                initialSelection: const ExploreSelection(image: 'bmw_ix5'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(ExploreDetailView));
        await tester.runAsync(() async {
          for (final path in {
            for (final vehicle in VehicleCatalog.samples) vehicle.imagePath,
            ?ImageItems.aiVideoCovers[title],
          }) {
            await precacheImage(AssetImage(path), context);
          }
        });
        final action = find.text('Video Oluştur');
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        if (title == 'Apex Transform') await capture('editor');
        await tester.tap(action);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        if (title == 'Apex Transform') {
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
        final back = find.text('Seçimlere Dön');
        await tester.ensureVisible(back);
        await tester.tap(back);
        await tester.pumpAndSettle();
        if (title == 'Apex Transform') {
          await capture('returned');
          await tester.ensureVisible(action);
          await tester.tap(action);
          await tester.pump();
          await tester.tap(find.text('Vazgeç'));
          service.succeed(2);
          await tester.pumpAndSettle();
          await capture('cancelled');
        }
        expect(tester.takeException(), isNull);
      }
    },
    skip: output.isEmpty,
  );
}
