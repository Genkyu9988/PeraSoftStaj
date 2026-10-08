import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'selection_cache_test.dart' show MemorySharedManager;

void main() {
  test(
    'Reference cache is independent, validated and backward compatible',
    () async {
      final storage = MemorySharedManager();
      for (final reference in ReferenceCarCatalog.items) {
        final data = AppSelections(
          explore: {
            'Clone Car Style': ExploreSelection(
              image: VehicleCatalog.samples.first.id,
              referenceImage: reference.id,
            ),
            'Transformers': ExploreSelection(
              image: VehicleCatalog.samples.last.id,
            ),
          },
        );
        expect(await SelectionCacheManager(storage).save(data), isTrue);
        expect(
          (await SelectionCacheManager(storage).load()).toJson(),
          data.toJson(),
        );
      }
      for (final value in [null, 12, 'deleted', 'tire.offroad']) {
        expect(
          ExploreSelection.fromJson({
            'referenceImage': value,
          }, 'Clone Car Style').referenceImage,
          '',
        );
      }
      final reference = ReferenceCarCatalog.items.first.id;
      expect(
        ExploreSelection.fromJson({
          'referenceImage': reference,
        }, 'Transformers').referenceImage,
        '',
      );
      expect(
        ExploreSelection.fromJson(
          {'referenceImage': reference},
          'Clone Car Style',
          isVideo: true,
        ).referenceImage,
        '',
      );
      expect(
        ExploreSelection.fromJson({
          'image': VehicleCatalog.samples.first.id,
        }, 'Clone Car Style').referenceImage,
        '',
      );
      expect(
        ReferenceCarCatalog.items.map((e) => e.id).toSet().length,
        ReferenceCarCatalog.items.length,
      );
    },
  );

  for (final width in [320.0, 390.0]) {
    testWidgets('Clone apply/cancel, independent clear and restore at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      ExploreSelection saved = const ExploreSelection();
      Widget screen() => MyApp(
        home: ExploreDetailView(
          title: 'Clone Car Style',
          isCarMod: false,
          initialSelection: saved,
          onApplied: (value) => saved = value,
        ),
      );
      await tester.pumpWidget(screen());
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      final vehicle = VehicleCatalog.samples.first;
      await tester.tap(find.text(vehicle.label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      expect(saved.image, vehicle.id);
      expect(
        tester
            .widget<ModyActionButton>(
              find.widgetWithText(ModyActionButton, 'Arabamı Modifiye Et'),
            )
            .onPressed,
        isNotNull,
      );
      for (final reference in ReferenceCarCatalog.items) {
        await tester.tap(find.byKey(const Key('referenceInput')));
        await tester.pumpAndSettle();
        final previous = saved.referenceImage;
        await tester.ensureVisible(find.byKey(Key('choice${reference.id}')));
        await tester.tap(find.byKey(Key('choice${reference.id}')));
        await tester.pumpAndSettle();
        expect(saved.referenceImage, previous);
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        expect(saved.referenceImage, reference.id);
        expect(saved.image, vehicle.id);
        expect(
          tester
              .widget<ModyAssetImage>(
                find.byKey(const Key('selectedReferenceImage')),
              )
              .path,
          reference.imagePath,
        );
      }
      final committed = saved.referenceImage;
      await tester.tap(find.byKey(const Key('referenceInput')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(Key('choice${ReferenceCarCatalog.items.first.id}')),
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(saved.referenceImage, committed);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('selectedReferenceImage')), findsOneWidget);
      expect(find.byKey(const Key('selectedVehicleImage')), findsOneWidget);
      await tester.tap(find.byTooltip('Referans seçimini kaldır'));
      await tester.pumpAndSettle();
      expect(saved.referenceImage, '');
      expect(saved.image, vehicle.id);
      await tester.tap(find.byKey(const Key('referenceInput')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(Key('choice${ReferenceCarCatalog.items.first.id}')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      // Vehicle clear must leave the reference intact.
      await tester.tap(find.byTooltip('Araç seçimini kaldır'));
      await tester.pumpAndSettle();
      expect(saved.image, '');
      expect(saved.referenceImage, ReferenceCarCatalog.items.first.id);
      expect(tester.takeException(), isNull);
    });
  }

  for (final title in ['Transformers', 'Clone Car Style']) {
    testWidgets('$title opens from expanded AI Edits and retains vehicle', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MyApp(home: ExploreView(showBottomBar: false)),
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('expandAiEdits')),
        400,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('exploreScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('expandAiEdits')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('expandAiEdits')));
      await tester.pumpAndSettle();
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
      await tester.ensureVisible(find.text('Resim Seçin'));
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(VehicleCatalog.samples.first.label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      if (title == 'Transformers') {
        expect(find.byKey(const Key('referenceInput')), findsNothing);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      }
      await tester.ensureVisible(find.byTooltip('Explore’a dön'));
      await tester.tap(find.byTooltip('Explore’a dön'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('selectedVehicleImage')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
