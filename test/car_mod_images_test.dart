import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';

void main() {
  const groups = {
    'Customize Rims': 'Rim',
    'Suspension': 'Suspension',
    'Neons': 'Neon',
    'Tire': 'Tire',
    'Spoiler': 'Spoiler',
    'Sound System': 'Ses Sistemi',
    'Window Tints': 'Cam Filmi',
    'Exhaust': 'Egzoz',
    'Chrome Delete': 'Krom Detay',
    'Body Kit': 'Gövde Kiti',
    'Perspective': 'Açı',
    'Mirror Swap': 'Ayna',
    'Sunroof Mood': 'Tavan',
    'Put On Sticker': 'Kaplama',
    'Upholstery': 'Döşeme',
  };
  test('Stable ids, migration and group validation', () {
    final all = CarModCatalog.groups.values.expand((items) => items).toList();
    expect(all, hasLength(51));
    expect(all.map((item) => item.id).toSet(), hasLength(51));
    for (final entry in groups.entries) {
      for (final item in CarModCatalog.groups[entry.key]!) {
        expect(item.instruction, isNotEmpty);
        expect(item.label, isNot(contains(RegExp(r' [1-5]$'))));
        expect(
          CarModCatalog.restoreId(entry.key, item.legacyName),
          entry.key == 'Neons' || item.legacyName.isEmpty ? '' : item.id,
        );
        final selected = ExploreSelection(option: item.id);
        expect(
          ExploreSelection.fromJson(selected.toJson(), entry.key).option,
          selected.option,
        );
      }
    }
    expect(CarModCatalog.restoreId('Tire', 'rim.mesh'), '');
    expect(CarModCatalog.restoreId('Tire', null), '');
    expect(CarModCatalog.restoreId('Tire', 'Tire 99'), '');
  });
  for (final width in [320.0, 390.0]) {
    for (final group in groups.entries) {
      testWidgets(
        '${group.value} images, last choice, apply and cancel at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var writes = 0;
          ExploreSelection? saved;
          final options = CarModCatalog.groups[group.key]!;
          await tester.pumpWidget(
            MyApp(
              home: ExploreDetailView(
                title: group.key,
                isCarMod: true,
                initialSelection: ExploreSelection(option: options[1].id),
                onApplied: (value) {
                  writes++;
                  saved = value;
                },
              ),
            ),
          );
          Future<void> tap(String text) async {
            await tester.tap(find.text(text).last);
            await tester.pumpAndSettle();
          }

          await tester.tap(find.byKey(const Key('modificationInput')));
          await tester.pumpAndSettle();
          expect(find.text('${group.value} seçin'), findsOneWidget);
          expect(
            tester
                .widget<Semantics>(find.byKey(Key('choice${options[1].id}')))
                .properties
                .selected,
            isTrue,
          );
          final scroll = find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Scrollable),
          );
          for (final option in options) {
            final name = option.id;
            final card = find.byKey(Key('choice$name'));
            await tester.scrollUntilVisible(card, 90, scrollable: scroll);
            await tester.pumpAndSettle();
            final image = tester.widget<ModyAssetImage>(
              find.descendant(of: card, matching: find.byType(ModyAssetImage)),
            );
            expect(image.path, option.imagePath);
            expect(
              find.descendant(of: card, matching: find.text(option.label)),
              findsOneWidget,
            );
            expect(find.text('Uygula').hitTestable(), findsOneWidget);
          }
          await tap(options.last.label);
          expect(writes, 0);
          await tap('Uygula');
          expect(writes, 1);
          expect(saved?.option, options.last.id);
          await tester.tap(find.byKey(const Key('modificationInput')));
          await tester.pumpAndSettle();
          await tap(options[0].label);
          await tester.tap(find.byTooltip('Paneli kapat'));
          await tester.pumpAndSettle();
          expect(writes, 1);
          expect(
            tester
                .widget<ModyAssetImage>(
                  find.byKey(const Key('selectedModificationImage')),
                )
                .path,
            options.last.imagePath,
          );
          await tap('Resim Seçin');
          expect(
            find.descendant(
              of: find.byType(VehicleSelectionPanel),
              matching: find.byType(ModyAssetImage),
            ),
            findsWidgets,
          );
          expect(find.text('Klasik Mustang'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
