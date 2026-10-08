import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/feature/creations/view/widget/creation_grid.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/feature/garage/view/garage_view.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/cache/creation_cache_manager.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';
import 'helpers/controlled_generation_service.dart';

const _initial = GenerateSelection(
  vehicleId: 'mustang_classic',
  style: 'Sportif',
  angle: 'Rear',
  parts: {'Spoiler': 0},
);

CreationRecord _record(String id, {bool video = false}) {
  final vehicle = video ? 'bmw_ix5' : 'porsche_911';
  return CreationRecord(
    id: id,
    createdAt: DateTime.utc(2026, 10, 8, 12),
    result: DemoGenerationResult(
      originalImagePath: VehicleCatalog.find(vehicle)!.imagePath,
      request: video
          ? AiVideoGenerationRequest(
              template: AiVideoTemplate.cliffDrive,
              vehicleId: vehicle,
            )
          : GenerationRequest(
              mode: GenerateMode.customEdit,
              vehicleId: vehicle,
              description: 'Mat boya',
            ),
    ),
  );
}

void _phone(WidgetTester tester, double scale) {
  tester.view.physicalSize = scale == 1
      ? const Size(390, 844)
      : const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _tap(
  WidgetTester tester,
  Finder target, {
  bool settle = true,
}) async {
  await tester.pump();
  if (target.hitTestable().evaluate().isEmpty) {
    final element = tester.element(target);
    await Scrollable.ensureVisible(element, alignment: 0.5);
    await tester.pump();
  }
  await tester.tap(target.hitTestable());
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

CreationHistoryCubit _history(WidgetTester tester, Type view) => tester
    .element(find.byType(view, skipOffstage: false).first)
    .read<CreationHistoryCubit>();

Future<CreationGrid> _visibleGrid(WidgetTester tester) async {
  // At 320px/2x the profile can fill the viewport; reveal the lazy page by
  // scrolling the real nested container, just as on the device.
  if (find.byType(CreationGrid).evaluate().isEmpty) {
    await tester.dragFrom(
      tester.getTopLeft(find.byType(NestedScrollView)) + const Offset(30, 50),
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();
  }
  return tester.widget<CreationGrid>(find.byType(CreationGrid));
}

class _Storage extends SharedManager {
  final data = <SharedKeys, String>{};
  bool failWrite = false;
  @override
  Future<String?> getString(SharedKeys key) async => data[key];
  @override
  Future<void> saveString(SharedKeys key, String value) async {
    if (failWrite) throw StateError('disk full');
    data[key] = value;
  }
}

void main() {
  for (final scale in [1.0, 2.0]) {
    for (final mode in [
      'Style Builder',
      'Custom Edit',
      'Detail Edit',
      'Japanese',
      'Cliff Drive',
    ]) {
      testWidgets('$mode: shared Your Creations apply/cancel at scale $scale', (
        tester,
      ) async {
        _phone(tester, scale);
        final repository = MemoryCreationRepository();
        await repository.save([
          _record('still'),
          _record('video', video: true),
        ]);
        final generate = mode.endsWith('Edit') || mode == 'Style Builder';
        await tester.pumpWidget(
          MyApp(
            historyRepository: repository,
            home: generate
                ? const ModyHomeView(initialSelection: _initial)
                : ExploreDetailView(
                    title: mode,
                    isCarMod: false,
                    isVideo: mode == 'Cliff Drive',
                    initialSelection: const ExploreSelection(
                      image: 'mustang_classic',
                    ),
                  ),
          ),
        );
        await tester.pumpAndSettle();
        if (generate) await _tap(tester, find.text(mode, skipOffstage: false));
        for (final apply in [false, true]) {
          await _tap(
            tester,
            find.byKey(const Key('vehicleInput'), skipOffstage: false),
          );
          await _tap(tester, find.text('Your Creations'));
          await _tap(tester, find.byKey(const ValueKey('creation-still')));
          if (apply) {
            await _tap(tester, find.text('Uygula'));
          } else {
            await _tap(tester, find.text('Hazır Arabalar'));
            await _tap(
              tester,
              find.byKey(const ValueKey('vehicle-mustang_classic')),
            );
            await _tap(tester, find.text('Your Creations'));
            expect(
              tester.widget<CreationGrid>(find.byType(CreationGrid)).selectedId,
              isNull,
            );
            await _tap(tester, find.byKey(const ValueKey('creation-still')));
            Navigator.of(
              tester.element(find.byType(VehicleSelectionPanel)),
            ).pop();
            await tester.pumpAndSettle();
          }
          expect(
            tester
                .widget<VehicleImageInput>(
                  find.byType(VehicleImageInput, skipOffstage: false),
                )
                .selectedId,
            apply ? 'porsche_911' : 'mustang_classic',
          );
          expect(tester.takeException(), isNull);
        }
        expect((await repository.load()), hasLength(2));
      });
    }

    testWidgets(
      'Garaj filters, truthful video detail and counts at scale $scale',
      (tester) async {
        _phone(tester, scale);
        final repository = MemoryCreationRepository();
        await repository.save([
          _record('still'),
          _record('video', video: true),
        ]);
        await tester.pumpWidget(
          MyApp(historyRepository: repository, home: const GarageView()),
        );
        await tester.pumpAndSettle();
        final history = _history(tester, GarageView);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey("creation-count-Mody's")))
              .data,
          '1',
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('creation-count-Videolar')),
              )
              .data,
          '1',
        );
        expect((await _visibleGrid(tester)).records, hasLength(2));
        await _tap(
          tester,
          find.byKey(const Key("garageTabMody's"), skipOffstage: false),
        );
        expect(
          (await _visibleGrid(tester)).records.single.isVideoDemo,
          isFalse,
        );
        await _tap(
          tester,
          find.byKey(const Key('garageTabVideolar'), skipOffstage: false),
        );
        expect((await _visibleGrid(tester)).records.single.isVideoDemo, isTrue);
        await _tap(tester, find.byKey(const ValueKey('creation-video')));
        expect(find.text('Cliff Drive'), findsOneWidget);
        expect(find.textContaining('gerçek video üretilmedi.'), findsOneWidget);
        await _tap(tester, find.text('Garaja Dön'));
        expect(history.state.records, hasLength(2));
        expect((await repository.load()), hasLength(2));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Real Generate completions update Garage and survive app recreation',
    (tester) async {
      _phone(tester, 1);
      final storage = _Storage();
      await tester.pumpWidget(
        MyApp(
          historyRepository: CreationCacheManager(storage),
          home: MainTabsView(
            initialSelections: AppSelections(generate: _initial),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final mode in ['Style Builder', 'Custom Edit', 'Detail Edit']) {
        await _tap(tester, find.text(mode, skipOffstage: false));
        if (mode == 'Custom Edit') {
          await tester.enterText(
            find.byKey(const Key('customEditDescriptionField')),
            'Mat boya',
          );
        }
        await _tap(
          tester,
          find.text(
            mode == 'Detail Edit' ? 'Modifiye Et' : 'Arabamı Modifiye Et',
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('generationResultPage')), findsOneWidget);
        await _tap(tester, find.text('Seçimlere Dön'));
      }
      final history = _history(tester, MainTabsView);
      expect(history.state.records, hasLength(3));
      await _tap(
        tester,
        find.descendant(
          of: find.byType(ModyBottomBar),
          matching: find.text('Garaj'),
        ),
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey("creation-count-Mody's")))
            .data,
        '3',
      );
      await history.pendingSave;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MyApp(
          historyRepository: CreationCacheManager(storage),
          home: const GarageView(),
        ),
      );
      await tester.pumpAndSettle();
      expect(_history(tester, GarageView).state.records, hasLength(3));
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey("creation-count-Mody's")))
            .data,
        '3',
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final video in [false, true]) {
    testWidgets(
      'Editor video=$video records only accepted success in shared app history',
      (tester) async {
        _phone(tester, 1);
        final service = ControlledGenerationService();
        await tester.pumpWidget(
          MyApp(
            home: ExploreDetailView(
              title: video ? 'Cliff Drive' : 'Japanese',
              isCarMod: false,
              isVideo: video,
              generationService: service,
              initialSelection: const ExploreSelection(image: 'porsche_911'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final history = _history(tester, ExploreDetailView);
        final submit = find.text(
          video ? 'Video Oluştur' : 'Arabamı Modifiye Et',
        );
        await _tap(tester, submit, settle: false);
        await _tap(tester, find.text('Vazgeç'));
        service.succeed();
        await tester.pumpAndSettle();
        expect(history.state.records, isEmpty);
        await _tap(tester, submit, settle: false);
        service.fail(1);
        await tester.pumpAndSettle();
        expect(history.state.records, isEmpty);
        await _tap(tester, find.text('Tekrar Dene'), settle: false);
        service.succeed(2);
        await tester.pumpAndSettle();
        expect(history.state.records, hasLength(1));
        expect(
          history.state.records.single.source,
          video ? 'AI Video' : 'Explore',
        );
        await _tap(tester, find.text('Seçimlere Dön'));
        await _tap(tester, find.byKey(const Key('vehicleInput')));
        await _tap(tester, find.text('Your Creations'));
        expect(
          tester.widget<CreationGrid>(find.byType(CreationGrid)).records,
          history.state.records,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Device save error is visible, retriable and not a generation error',
    (tester) async {
      _phone(tester, 1);
      final storage = _Storage()..failWrite = true;
      final service = ControlledGenerationService();
      await tester.pumpWidget(
        MyApp(
          historyRepository: CreationCacheManager(storage),
          home: ModyHomeView(
            initialSelection: _initial,
            generationService: service,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final history = _history(tester, ModyHomeView);
      await _tap(tester, find.text('Arabamı Modifiye Et'), settle: false);
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('generationResultPage')), findsOneWidget);
      expect(find.textContaining('cihaza kaydedilemedi'), findsOneWidget);
      expect(find.text('İşlem tamamlanamadı'), findsNothing);
      storage.failWrite = false;
      await _tap(tester, find.text('Kaydı tekrar dene'));
      expect(find.textContaining('cihaza kaydedilemedi'), findsNothing);
      expect(history.state.records, hasLength(1));
      expect(await CreationCacheManager(storage).load(), history.state.records);
      expect(tester.takeException(), isNull);
    },
  );
}
