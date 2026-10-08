import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/ai_video/view/ai_video_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/catalog/ai_video_items.dart';
import 'package:perasoft_staj/product/widget/mock_options.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/feature/editor/view/widget/detail_cover_header.dart';
import 'package:perasoft_staj/product/widget/sample_cars_area.dart';

void main() {
  test('Her AI Video bölümünde beş seçenek vardır', () {
    expect(AiVideoItems.transformations.length, 5);
    expect(AiVideoItems.driveScenes.length, 5);
    expect(AiVideoItems.filters.length, 5);
    expect(ImageItems.aiVideoCovers.keys.toSet(), {
      ...AiVideoItems.transformations,
      ...AiVideoItems.driveScenes,
      ...AiVideoItems.filters,
    });
  });

  for (final width in [390.0, 320.0]) {
    testWidgets('AI Video kartları, seçim ve kaydırma: $width', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp(home: AiVideoView()));
      expect(find.text(AiVideoItems.transformationsTitle), findsOneWidget);
      expect(
        tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).selectedIndex,
        2,
      );
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(ModyAssetImage), findsWidgets);
      await tester.tap(find.text('Apex Transform'));
      await tester.pumpAndSettle();
      expect(find.byType(AiVideoView, skipOffstage: false), findsOneWidget);
      expect(find.text('Renk'), findsNothing);
      expect(find.byType(DetailCoverHeader), findsOneWidget);
      expect(find.byType(SampleCarsArea), findsOneWidget);
      expect(
        tester
            .widget<ModyAssetImage>(find.byKey(const Key('detailCover')))
            .path,
        ImageItems.aiVideoCovers['Apex Transform'],
      );
      await tester.tap(find.byKey(const Key('vehicleInput')));
      await tester.pumpAndSettle();
      expect(find.text('Galeri'), findsNothing);
      expect(find.text('Kamera'), findsNothing);
      await tester.tap(find.text('Klasik Mustang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('AI Video’ya dön'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apex Transform'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Seçilen araç: Klasik Mustang'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('vehicleInput')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Porsche 911'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Seçilen araç: Klasik Mustang'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('AI Video’ya dön'));
      await tester.pumpAndSettle();

      final vertical = find
          .descendant(
            of: find.byKey(const Key('aiVideoScroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      for (final titles in [
        AiVideoItems.transformations,
        AiVideoItems.driveScenes,
      ]) {
        await tester.scrollUntilVisible(
          find.text(titles.first),
          100,
          scrollable: vertical,
        );
        final horizontal = find.ancestor(
          of: find.text(titles.first),
          matching: find.byType(HorizontalMockOptions),
        );
        await tester.drag(horizontal, const Offset(-600, 0));
        await tester.pumpAndSettle();
        expect(find.text(titles.last).hitTestable(), findsOneWidget);
        await tester.tap(find.text(titles.last));
        await tester.pumpAndSettle();
        expect(find.text('Resim Seçin'), findsOneWidget);
        expect(
          tester
              .widget<ModyAssetImage>(find.byKey(const Key('detailCover')))
              .path,
          ImageItems.aiVideoCovers[titles.last],
        );
        expect(
          find.bySemanticsLabel('Seçilen araç: Klasik Mustang'),
          findsNothing,
        );
        await tester.tap(find.byTooltip('AI Video’ya dön'));
        await tester.pumpAndSettle();
      }
      await tester.scrollUntilVisible(
        find.text('Drift Showdown'),
        150,
        scrollable: vertical,
      );
      await tester.pumpAndSettle();
      expect(find.text('Drift Showdown').hitTestable(), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Zoom Out')).dy,
        tester.getTopLeft(find.text('Zoom In')).dy,
      );
      expect(find.text('Mody AI').hitTestable(), findsOneWidget);
      expect(find.text('AI Video').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Drift Showdown'));
      await tester.pumpAndSettle();
      expect(find.text('Resim Seçin'), findsOneWidget);
      expect(find.text('Video Oluştur'), findsOneWidget);
      expect(
        tester
            .widget<ModyAssetImage>(find.byKey(const Key('detailCover')))
            .path,
        ImageItems.aiVideoCovers['Drift Showdown'],
      );
      expect(tester.takeException(), isNull);
    });
  }
}
