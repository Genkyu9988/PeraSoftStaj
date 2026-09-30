import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/demos/ai_video_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/ai_video_items.dart';
import 'package:perasoft_staj/product/mock_options.dart';
import 'package:perasoft_staj/product/mody_bottom_bar.dart';

void main() {
  test('Her AI Video bölümünde beş seçenek vardır', () {
    expect(AiVideoItems.transformations.length, 5);
    expect(AiVideoItems.driveScenes.length, 5);
    expect(AiVideoItems.filters.length, 5);
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
      expect(find.byType(Image), findsNothing);
      await tester.tap(find.text('Apex Transform'));
      await tester.pumpAndSettle();
      expect(find.byType(AiVideoView, skipOffstage: false), findsOneWidget);
      expect(find.text('Renk'), findsNothing);
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      expect(find.text('Galeri'), findsNothing);
      expect(find.text('Kamera'), findsNothing);
      await tester.tap(find.text('Your Creations'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mock Üretim 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('AI Video’ya dön'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apex Transform'));
      await tester.pumpAndSettle();
      expect(find.text('Mock Üretim 1'), findsOneWidget);
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mock Üretim 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
      expect(find.text('Mock Üretim 1'), findsOneWidget);
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
        expect(find.text('Mock Üretim 1'), findsNothing);
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
      expect(tester.takeException(), isNull);
    });
  }
}
