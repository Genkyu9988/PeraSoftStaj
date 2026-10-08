import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/feature/generate/view/widget/detail_adjustment_panel.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tap(WidgetTester tester, String title) async {
  await tester.tap(find.text(title).hitTestable());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('No angle never falls back to unrelated Rear parts', (
    tester,
  ) async {
    phone(tester);
    await tester.pumpWidget(const MyApp());
    await tap(tester, 'Detail Edit');
    await tap(tester, 'Ayarla');
    expect(find.text(GenerateValidationMessages.angle), findsOneWidget);
    expect(find.byType(DetailAdjustmentPanel), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byKey(const Key('partSpoiler0')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final from in DetailPartCatalog.byAngle.keys) {
    for (final to in DetailPartCatalog.byAngle.keys.where(
      (angle) => angle != from,
    )) {
      testWidgets(
        '$from -> $to resets parts only after a different angle is applied',
        (tester) async {
          phone(tester);
          final initial = GenerateSelection(
            vehicleId: 'mustang_classic',
            angle: from,
            parts: {
              for (final category in DetailPartCatalog.forAngle(from))
                category.title: 1,
            },
            detailColor: 'Premium Mor',
            detailColorCategory: 1,
            style: 'Klasik',
            extra: 'Jant',
            color: 'Mavi',
          );
          var applied = initial;
          var saves = 0;
          await tester.pumpWidget(
            MyApp(
              home: ModyHomeView(
                initialSelection: initial,
                onApplied: (value) {
                  applied = value;
                  saves++;
                },
              ),
            ),
          );
          await tap(tester, 'Detail Edit');

          // An unconfirmed angle cannot reset the confirmed parts or write cache.
          await tap(tester, 'Açı');
          await tap(tester, to);
          await tester.tap(find.byTooltip('Paneli kapat'));
          await tester.pumpAndSettle();
          expect(applied.parts, initial.parts);
          expect(saves, 0);
          await tap(tester, 'Ayarla');
          final unchangedPanel = tester.widget<DetailAdjustmentPanel>(
            find.byType(DetailAdjustmentPanel),
          );
          expect(unchangedPanel.categories, DetailPartCatalog.forAngle(from));
          expect(unchangedPanel.selections, initial.parts);
          await tester.tap(find.byTooltip('Paneli kapat'));
          await tester.pumpAndSettle();

          // Re-applying the same angle also keeps the confirmed parts.
          await tap(tester, 'Açı');
          await tap(tester, 'Uygula');
          expect(applied.parts, initial.parts);
          expect(saves, 1);

          await tap(tester, 'Açı');
          await tap(tester, to);
          await tap(tester, 'Uygula');
          expect(applied.angle, to);
          expect(applied.parts, isEmpty);
          expect(applied.detailColor, 'Premium Mor');
          expect(applied.detailColorCategory, 1);
          expect(applied.vehicleId, initial.vehicleId);
          expect(applied.style, initial.style);
          expect(applied.extra, initial.extra);
          expect(applied.color, initial.color);
          expect(find.byKey(const Key('selectionAyarla')), findsNothing);

          await tap(tester, 'Ayarla');
          final panel = tester.widget<DetailAdjustmentPanel>(
            find.byType(DetailAdjustmentPanel),
          );
          expect(panel.categories, DetailPartCatalog.forAngle(to));
          final firstCategory = panel.categories.first.title;
          await tester.tap(find.byKey(Key('part${firstCategory}0')));
          await tester.pumpAndSettle();
          await tap(tester, 'Uygula');
          // Only one part is sufficient to apply; other categories stay optional.
          expect(applied.parts, {firstCategory: 0});

          await tester.tap(find.byTooltip('Araç seçimini kaldır'));
          await tester.pumpAndSettle();
          expect(applied.vehicleId, isEmpty);
          expect(applied.angle, to);
          expect(applied.parts, {firstCategory: 0});
          expect(applied.detailColor, 'Premium Mor');
          await tester.tap(find.byTooltip('Örnek Araç 2'));
          await tester.pumpAndSettle();
          expect(applied.vehicleId, isNotEmpty);
          expect(applied.parts, {firstCategory: 0});
          expect(applied.detailColor, 'Premium Mor');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
