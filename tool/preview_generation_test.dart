// Optional visual QA, not a network test or a checked-in platform golden.
// flutter test tool/preview_generation_test.dart --dart-define=MODY_PREVIEW_DIR=...
//   --dart-define=MODY_PREVIEW_FONT=C:/Windows/Fonts/arial.ttf
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';
import '../test/helpers/controlled_generation_service.dart';

void main() {
  const output = String.fromEnvironment('MODY_PREVIEW_DIR');
  const font = String.fromEnvironment('MODY_PREVIEW_FONT');
  testWidgets(
    'Render generation loading, error and three demo results',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (font.isNotEmpty) {
        await tester.runAsync(() async {
          final loader = FontLoader('Roboto')
            ..addFont(File(font).readAsBytes().then(ByteData.sublistView));
          await loader.load();
        });
      }
      final iconLoader = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await iconLoader.load();
      final boundaryKey = GlobalKey();
      final service = ControlledGenerationService();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MyApp(
            home: ModyHomeView(
              generationService: service,
              initialSelection: const GenerateSelection(
                vehicleId: 'mustang_classic',
                style: 'Sportif',
                extra: 'Jant',
                color: 'Mavi',
                angle: 'Rear',
                parts: {'Spoiler': 2, 'Exhaust': 0},
                detailColor: 'Mor',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => precacheImage(
          AssetImage(VehicleCatalog.find('mustang_classic')!.imagePath),
          tester.element(find.byType(ModyHomeView)),
        ),
      );
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(VehicleImageInput))
          .read<GenerateCubit>();
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

      cubit.submit(GenerateMode.styleBuilder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await capture('loading');
      service.fail();
      await tester.pumpAndSettle();
      await capture('failure');
      cubit.retryGeneration();
      await tester.pump();
      service.succeed(1);
      await tester.pumpAndSettle();
      await capture('result_style');
      await tester.pageBack();
      await tester.pumpAndSettle();
      cubit.submit(GenerateMode.detailEdit);
      service.succeed(2);
      await tester.pumpAndSettle();
      await capture('result_detail');
      await tester.pageBack();
      await tester.pumpAndSettle();
      cubit.submit(
        GenerateMode.customEdit,
        description:
            'Mat siyah boya, altın jantlar ve alçaltılmış süspansiyon.',
      );
      service.succeed(3);
      await tester.pumpAndSettle();
      await capture('result_custom');
      expect(tester.takeException(), isNull);
    },
    skip: output.isEmpty,
  );
}
