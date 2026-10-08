import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';

void main() {
  test('12 unique vehicles; five samples are the same catalog objects', () {
    expect(VehicleCatalog.all, hasLength(12));
    expect(VehicleCatalog.all.map((v) => v.id).toSet(), hasLength(12));
    expect(VehicleCatalog.all.map((v) => v.imagePath).toSet(), hasLength(12));
    expect(VehicleCatalog.samples, hasLength(5));
    for (final car in VehicleCatalog.samples) {
      expect(identical(VehicleCatalog.find(car.id), car), isTrue);
    }
  });

  test('Restore validates types and migrates only real sample selections', () {
    for (final value in [
      null,
      42,
      {},
      'removed',
      'Mock Araç 1',
      'Mock Üretim 2',
    ]) {
      expect(VehicleCatalog.restoreId(value), '');
      expect(GenerateSelection.fromJson({'vehicleId': value}).vehicleId, '');
      expect(ExploreSelection.fromJson({'image': value}, 'Neons').image, '');
    }
    for (var i = 0; i < VehicleCatalog.samples.length; i++) {
      expect(
        VehicleCatalog.restoreId('Örnek Araç ${i + 1}'),
        VehicleCatalog.samples[i].id,
      );
    }
    for (final car in VehicleCatalog.all) {
      final generate = GenerateSelection(vehicleId: car.id, style: 'Klasik');
      expect(GenerateSelection.fromJson(generate.toJson()).vehicleId, car.id);
      final detail = ExploreSelection(image: car.id);
      expect(
        ExploreSelection.fromJson(
          detail.toJson(),
          'Apex Transform',
          isVideo: true,
        ).image,
        car.id,
      );
    }
  });

  for (final width in [320.0, 390.0]) {
    testWidgets(
      'Generate sample, full catalog, cancel, clear and restore: $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var saved = const GenerateSelection(style: 'Klasik');
        var writes = 0;
        Future<void> start() async {
          await tester.pumpWidget(
            MyApp(
              home: ModyHomeView(
                initialSelection: saved,
                onApplied: (selection) {
                  saved = selection;
                  writes++;
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        String photo() => tester
            .widget<ModyAssetImage>(
              find.byKey(const Key('selectedVehicleImage')),
            )
            .path;
        Future<void> open() async {
          await tester.tap(find.byKey(const Key('vehicleInput')));
          await tester.pumpAndSettle();
        }

        await start();
        await tester.tap(find.byTooltip('Örnek Araç 1'));
        await tester.pumpAndSettle();
        expect(photo(), VehicleCatalog.samples.first.imagePath);
        expect(saved.vehicleId, VehicleCatalog.samples.first.id);
        expect(writes, 1);
        expect(find.byType(VehicleSelectionPanel), findsNothing);
        await open();
        await tester.tap(find.byKey(const Key('vehicle-porsche_911')));
        await tester.tap(find.byTooltip('Paneli kapat'));
        await tester.pumpAndSettle();
        expect(writes, 1);
        expect(photo(), VehicleCatalog.samples.first.imagePath);
        await open();
        final target = find.byKey(const Key('vehicle-buick_classic'));
        await tester.scrollUntilVisible(
          target,
          140,
          scrollable: find.descendant(
            of: find.byType(VehicleSelectionPanel),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        expect(saved.vehicleId, 'buick_classic');
        expect(photo(), VehicleCatalog.all.last.imagePath);
        await tester.pumpWidget(const SizedBox());
        saved = GenerateSelection.fromJson(saved.toJson());
        await start();
        expect(photo(), VehicleCatalog.all.last.imagePath);
        await tester.tap(find.byTooltip('Araç seçimini kaldır'));
        await tester.pumpAndSettle();
        expect(saved.vehicleId, '');
        expect(saved.style, 'Klasik');
        expect(find.byKey(const Key('selectedVehicleImage')), findsNothing);
        expect(find.text('Resim Seçin'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('No fake history/creations; clear preserves effect and cover', (
    tester,
  ) async {
    ExploreSelection? saved;
    await tester.pumpWidget(
      MyApp(
        home: ExploreDetailView(
          title: 'Change Color',
          isCarMod: true,
          coverImagePath: VehicleCatalog.samples.last.imagePath,
          initialSelection: const ExploreSelection(
            image: 'porsche_911',
            option: 'Mavi',
          ),
          onApplied: (value) => saved = value,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Araç seçimini kaldır'));
    await tester.pumpAndSettle();
    expect(saved?.image, '');
    expect(saved?.option, 'Mavi');
    expect(
      tester.widget<ModyAssetImage>(find.byKey(const Key('detailCover'))).path,
      VehicleCatalog.samples.last.imagePath,
    );
    await tester.tap(find.byKey(const Key('vehicleInput')));
    await tester.pumpAndSettle();
    expect(find.text('Hazır Arabalar'), findsOneWidget);
    expect(find.text('Son Kullanılanlar'), findsNothing);
    expect(find.text('Galeri'), findsNothing);
    expect(find.text('Kamera'), findsNothing);
    await tester.tap(find.text('Your Creations'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz oluşturulmuş bir görsel yok.'), findsOneWidget);
    expect(
      tester
          .widget<ModyActionButton>(
            find.widgetWithText(ModyActionButton, 'Uygula'),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}
