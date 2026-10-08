import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';

void main() {
  for (final group in CarModCatalog.groups.entries) {
    testWidgets(
      '${group.key}: preview restores and both clear actions are independent',
      (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final vehicle = VehicleCatalog.samples.first;
        final option = group.value.first;
        var saved = ExploreSelection(image: vehicle.id, option: option.id);
        var writes = 0;
        Future<void> start() async {
          await tester.pumpWidget(
            MyApp(
              home: ExploreDetailView(
                title: group.key,
                isCarMod: true,
                coverImagePath: vehicle.imagePath,
                initialSelection: saved,
                onApplied: (value) {
                  saved = value;
                  writes++;
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        String photo(String key) =>
            tester.widget<ModyAssetImage>(find.byKey(Key(key))).path;
        Future<void> clear(String tooltip) async {
          await tester.tap(find.byTooltip(tooltip));
          await tester.pumpAndSettle();
        }

        await start();
        expect(photo('selectedModificationImage'), option.imagePath);
        expect(photo('selectedVehicleImage'), vehicle.imagePath);
        await clear('Araç seçimini kaldır');
        expect(saved.image, '');
        expect(saved.option, option.id);
        expect(photo('selectedModificationImage'), option.imagePath);
        await tester.tap(find.byTooltip('Örnek Araç 1'));
        await tester.pumpAndSettle();
        expect(saved.image, vehicle.id);
        await tester.pumpWidget(const SizedBox());
        saved = ExploreSelection.fromJson(saved.toJson(), group.key);
        await start();
        expect(photo('selectedModificationImage'), option.imagePath);
        final beforeClear = writes;
        await clear('Modifikasyon seçimini kaldır');
        expect(writes, beforeClear + 1);
        expect(saved.option, '');
        expect(saved.image, vehicle.id);
        expect(photo('selectedVehicleImage'), vehicle.imagePath);
        expect(photo('detailCover'), vehicle.imagePath);
        expect(
          find.byKey(const Key('selectedModificationImage')),
          findsNothing,
        );
        expect(
          tester
              .widget<ModyActionButton>(
                find.widgetWithText(ModyActionButton, 'Arabamı Modifiye Et'),
              )
              .onPressed,
          isNotNull,
        );
        expect(find.textContaining('seçin'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        saved = ExploreSelection.fromJson(saved.toJson(), group.key);
        await start();
        expect(
          find.byKey(const Key('selectedModificationImage')),
          findsNothing,
        );
        expect(photo('selectedVehicleImage'), vehicle.imagePath);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
