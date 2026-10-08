import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';

void main() {
  test('All Car Mods now have a color flow or nonempty photo catalog', () {
    for (final title in ExploreItems.carMods.where(
      (title) => title != 'Change Color',
    )) {
      expect(CarModCatalog.groups[title], isNotEmpty, reason: title);
    }
  });
  for (final title in ['Spoiler', 'Sound System', 'Window Tints', 'Exhaust']) {
    testWidgets('$title opens from Explore and commits vehicle + option', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      ExploreSelection? saved;
      await tester.pumpWidget(
        MyApp(
          home: ExploreView(
            onApplied: (key, value) {
              expect(key, title);
              saved = value;
            },
          ),
        ),
      );
      await tester.ensureVisible(find.text(title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.byType(ExploreDetailView), findsOneWidget);
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      final vehicle = VehicleCatalog.samples.first;
      await tester.tap(find.text(vehicle.label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      expect(saved?.image, vehicle.id);
      expect(saved?.option, '');
      final dropdown = find.byIcon(Icons.keyboard_arrow_down);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ModyActionButton>(
              find.widgetWithText(ModyActionButton, 'Uygula'),
            )
            .onPressed,
        isNull,
      );
      final option = CarModCatalog.groups[title]!.first;
      await tester.tap(find.byKey(Key('choice${option.id}')));
      await tester.pumpAndSettle();
      expect(saved?.option, '');
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      expect(saved?.option, option.id);
      expect(
        tester
            .widget<ModyAssetImage>(
              find.byKey(const Key('selectedModificationImage')),
            )
            .path,
        option.imagePath,
      );
      expect(
        tester
            .widget<ModyAssetImage>(
              find.byKey(const Key('selectedVehicleImage')),
            )
            .path,
        vehicle.imagePath,
      );
      await tester.tap(find.byTooltip('Explore’a dön'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ModyAssetImage>(
              find.byKey(const Key('selectedModificationImage')),
            )
            .path,
        option.imagePath,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
