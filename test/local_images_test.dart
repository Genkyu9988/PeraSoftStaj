import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/image_items.dart';
import 'package:perasoft_staj/product/mody_asset_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All 12 catalog images are bundled and decode correctly', () async {
    final paths = {
      ...ImageItems.sampleCars,
      ...ImageItems.styleOptions.values,
      ...ImageItems.extraOptions.values,
    };
    expect(paths, hasLength(12));
    expect(ImageItems.sampleCars, hasLength(5));
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
    expect(find.byType(ModyAssetImage), findsNWidgets(5));
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
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Görsel kaynakları'));
      await rootBundle.loadString(ImageItems.credits);
    });
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });
}
