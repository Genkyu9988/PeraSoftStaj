import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';
import 'helpers/controlled_generation_service.dart';

const _vehicles = {
  'Klasik': 'mustang_classic',
  'Sportif': 'porsche_911',
  'Off Road': 'jeep_wrangler',
  'SUV': 'bmw_ix5',
  'Yarış': 'porsche_race',
  'Şehir': 'fiat_500',
};
const _existing = GenerateSelection(
  vehicleId: 'mustang_gt',
  style: 'Şehir',
  extra: 'Gövde Kiti',
  color: 'Premium Kırmızı',
  colorCategory: 1,
  angle: 'Rear',
  parts: {'Spoiler': 1},
  detailColor: 'Mor',
);

class _SelectionStorage extends SharedManager {
  String? data;
  int writes = 0;
  @override
  Future<String?> getString(SharedKeys key) async => data;
  @override
  Future<void> saveString(SharedKeys key, String value) async {
    writes++;
    data = value;
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder.hitTestable());
  await tester.pumpAndSettle();
}

void main() {
  test('Each style card has exactly one expected catalog vehicle', () {
    expect(_vehicles.keys, GenerateOptionCatalog.styles);
    expect(GenerateOptionCatalog.styleVehicleIds, _vehicles);
    for (final entry in _vehicles.entries) {
      expect(
        VehicleCatalog.find(entry.value)!.imagePath,
        ImageItems.styleOptions[entry.key],
      );
    }
  });

  for (final entry in _vehicles.entries) {
    for (final initial in [const GenerateSelection(), _existing]) {
      test(
        '${entry.key}: style and vehicle update in one state/cache snapshot (${initial.vehicleId})',
        () async {
          final saved = <GenerateSelection>[];
          final service = ControlledGenerationService();
          final cubit = GenerateCubit(
            initialSelection: initial,
            suggestions: GenerateSuggestions(),
            generationService: service,
            onApplied: saved.add,
          );
          addTearDown(cubit.close);
          final states = <String>[];
          final sub = cubit.stream.listen(
            (s) => states.add('${s.style}/${s.vehicleId}'),
          );
          addTearDown(sub.cancel);
          cubit.selectStyle(entry.key);
          await Future<void>.delayed(Duration.zero);
          expect(cubit.state.style, entry.key);
          expect(cubit.state.vehicleId, entry.value);
          expect(states, ['${entry.key}/${entry.value}']);
          expect(saved, hasLength(1));
          expect(saved.single.vehicleId, entry.value);
          final before = initial.toJson()
            ..remove('style')
            ..remove('vehicleId');
          final after = saved.single.toJson()
            ..remove('style')
            ..remove('vehicleId');
          expect(after, before);
          expect(service.requests, isEmpty);
          final submit = cubit.submit(GenerateMode.styleBuilder);
          final request = service.requests.single as GenerationRequest;
          expect(request.vehicleId, entry.value);
          expect(request.style, entry.key);
          cubit.dismissGeneration();
          service.succeed();
          await submit;
        },
      );

      testWidgets(
        '${entry.key}: preview, cancel, apply and actual image (${initial.vehicleId})',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final saved = <GenerateSelection>[];
          await tester.pumpWidget(
            MyApp(
              home: ModyHomeView(
                initialSelection: initial,
                onApplied: saved.add,
              ),
            ),
          );
          await tester.pumpAndSettle();
          final home = tester.element(find.byType(ModyHomeView));
          final history = home.read<CreationHistoryCubit>();
          final input = find.byType(VehicleImageInput, skipOffstage: false);
          for (final apply in [false, true]) {
            await _tap(tester, find.text('Stil'));
            await _tap(tester, find.byKey(ValueKey('option${entry.key}')));
            // A highlighted draft is not yet a committed source image.
            expect(
              tester.widget<VehicleImageInput>(input).selectedId,
              initial.vehicleId,
            );
            expect(saved, isEmpty);
            if (apply) {
              await _tap(tester, find.text('Uygula'));
            } else {
              await _tap(tester, find.byTooltip('Paneli kapat'));
              expect(
                tester.widget<VehicleImageInput>(input).selectedId,
                initial.vehicleId,
              );
            }
          }
          expect(
            tester.widget<VehicleImageInput>(input).selectedId,
            entry.value,
          );
          expect(
            tester.widget<Text>(find.byKey(const Key('selectionStil'))).data,
            entry.key,
          );
          final sourceImage = find.descendant(
            of: input,
            matching: find.byType(ModyAssetImage, skipOffstage: false),
          );
          expect(
            tester.widget<ModyAssetImage>(sourceImage).path,
            ImageItems.styleOptions[entry.key],
          );
          expect(saved, hasLength(1));
          expect(history.state.records, isEmpty);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  test(
    'Unknown style and blocked generation cannot change the vehicle',
    () async {
      final service = ControlledGenerationService();
      final saved = <GenerateSelection>[];
      final cubit = GenerateCubit(
        initialSelection: _existing,
        suggestions: GenerateSuggestions(),
        generationService: service,
        onApplied: saved.add,
      );
      addTearDown(cubit.close);
      cubit.selectStyle('unknown');
      expect(cubit.state.toSelection().toJson(), _existing.toJson());
      expect(saved, isEmpty);
      final pending = cubit.submit(GenerateMode.styleBuilder);
      cubit.selectStyle('Sportif');
      expect(cubit.state.vehicleId, _existing.vehicleId);
      expect(cubit.state.style, _existing.style);
      expect(saved, isEmpty);
      cubit.dismissGeneration();
      service.succeed();
      await pending;
    },
  );

  testWidgets(
    'Reapplying unchanged style restores its vehicle after clear, and persists on restart',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final storage = _SelectionStorage();
      final manager = SelectionCacheManager(storage);
      await tester.pumpWidget(
        MyApp(
          home: MainTabsView(
            cacheManager: manager,
            initialSelections: AppSelections(generate: _existing),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final clear in [false, true]) {
        if (clear) {
          await _tap(
            tester,
            find.byTooltip('Araç seçimini kaldır', skipOffstage: false),
          );
          expect(
            tester
                .widget<VehicleImageInput>(
                  find.byType(VehicleImageInput, skipOffstage: false),
                )
                .selectedId,
            '',
          );
        }
        await _tap(tester, find.text('Stil'));
        // Şehir is already selected, so Apply alone must still select its car.
        await _tap(tester, find.text('Uygula'));
        expect(
          tester
              .widget<VehicleImageInput>(
                find.byType(VehicleImageInput, skipOffstage: false),
              )
              .selectedId,
          'fiat_500',
        );
      }
      expect(
        storage.writes,
        3,
      ); // apply, clear, apply — no split style/car writes.
      final restored = await manager.load();
      expect(restored.generate.style, 'Şehir');
      expect(restored.generate.vehicleId, 'fiat_500');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MyApp(home: MainTabsView(initialSelections: restored)),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<VehicleImageInput>(
              find.byType(VehicleImageInput, skipOffstage: false),
            )
            .selectedId,
        'fiat_500',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
