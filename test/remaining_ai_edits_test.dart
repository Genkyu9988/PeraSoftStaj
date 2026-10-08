import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/feature/editor/view/widget/detail_cover_header.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'selection_cache_test.dart' show MemorySharedManager;

const _titles = [
  'AI Car Restore',
  'Mini Toy Car',
  'Mody AI Technic',
  '3D Car Figurine',
];

void main() {
  test(
    'Four AI Edits save independently and preserve cleared selections',
    () async {
      final storage = MemorySharedManager();
      final data = AppSelections(
        explore: {
          for (var i = 0; i < _titles.length; i++)
            _titles[i]: ExploreSelection(image: VehicleCatalog.all[i].id),
        },
      );
      expect(await SelectionCacheManager(storage).save(data), isTrue);
      expect(
        (await SelectionCacheManager(storage).load()).toJson(),
        data.toJson(),
      );
      data.explore[_titles.first] = const ExploreSelection();
      expect(await SelectionCacheManager(storage).save(data), isTrue);
      expect(
        (await SelectionCacheManager(storage).load()).toJson(),
        data.toJson(),
      );
    },
  );

  for (final width in [320.0, 390.0]) {
    for (final title in _titles) {
      testWidgets('$title single vehicle flow at $width', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        ExploreSelection saved = const ExploreSelection();
        await tester.pumpWidget(
          MyApp(
            home: ExploreView(
              onApplied: (key, selection) {
                expect(key, title);
                saved = selection;
              },
            ),
          ),
        );
        await tester.scrollUntilVisible(
          find.text(title),
          200,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('exploreScroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreDetailView), findsOneWidget);
        expect(
          tester.widget<DetailCoverHeader>(find.byType(DetailCoverHeader)).path,
          ImageItems.exploreCovers[title],
        );
        expect(find.byKey(const Key('referenceInput')), findsNothing);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);

        Future<void> tapVisible(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.pumpAndSettle();
          await tester.tap(finder);
          await tester.pumpAndSettle();
        }

        final input = find.byKey(const Key('vehicleInput'));
        await tapVisible(input);
        final vehicle = VehicleCatalog.samples.first;
        await tester.tap(find.byKey(Key('vehicle-${vehicle.id}')));
        await tester.pumpAndSettle();
        expect(saved.image, '');
        await tester.tap(find.byTooltip('Paneli kapat'));
        await tester.pumpAndSettle();
        expect(saved.image, '');
        await tapVisible(input);
        await tester.tap(find.byKey(Key('vehicle-${vehicle.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        expect(saved.image, vehicle.id);
        expect(saved.option, '');
        expect(saved.referenceImage, '');
        expect(
          tester
              .widget<ModyAssetImage>(
                find.byKey(const Key('selectedVehicleImage')),
              )
              .path,
          vehicle.imagePath,
        );
        await tapVisible(
          find.widgetWithText(ModyActionButton, 'Arabamı Modifiye Et'),
        );
        expect(find.text('Demo sonuç — AI ile üretilmedi'), findsOneWidget);
        await tapVisible(find.text('Seçimlere Dön'));
        await tapVisible(find.byTooltip('Explore’a dön'));
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('selectedVehicleImage')), findsOneWidget);
        await tapVisible(find.byTooltip('Araç seçimini kaldır'));
        expect(saved.image, '');
        expect(find.byKey(const Key('selectedVehicleImage')), findsNothing);
        await tapVisible(find.byTooltip('Örnek Araç 2'));
        expect(saved.image, VehicleCatalog.samples[1].id);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
