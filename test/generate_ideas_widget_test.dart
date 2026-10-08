import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';
import 'package:perasoft_staj/feature/generate/data/modification_prompts.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';

import 'helpers/sequence_random.dart';

class IdeaMemoryStore extends SharedManager {
  String? value;
  int writes = 0;

  @override
  Future<String?> getString(SharedKeys key) async => value;

  @override
  Future<void> saveString(SharedKeys key, String value) async {
    this.value = value;
    writes++;
  }
}

const initial = GenerateSelection(
  vehicleId: 'mustang_classic',
  style: 'Klasik',
  extra: 'Jant',
  color: 'Mavi',
  angle: 'Rear',
  parts: {'Spoiler': 0, 'Exhaust': 1},
  detailColor: 'Mor',
);
const readyMessage = 'Demo sonuç — AI ile üretilmedi';
final ideaButton = find.byKey(const Key('suggestIdea'), skipOffstage: false);
final magicButton = find.byKey(const Key('suggestDescription'));
final clearButton = find.byKey(const Key('clearDescription'));
final field = find.byKey(const Key('customEditDescriptionField'));

void phone(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tap(WidgetTester tester, Finder target) async {
  if (target.hitTestable().evaluate().isEmpty) {
    final element = tester.element(target);
    await Scrollable.of(
      element,
    ).position.ensureVisible(element.renderObject!, alignment: 0.5);
    await tester.pumpAndSettle();
  }
  await tester.tap(target.hitTestable());
  await tester.pumpAndSettle();
}

Future<void> reassemble(WidgetTester tester) async {
  final completed = tester.binding.reassembleApplication();
  // Reassemble waits for a frame; the fake test clock must render it first.
  await tester.pumpAndSettle();
  await completed;
}

Future<void> render(
  WidgetTester tester,
  SequenceRandom random,
  List<GenerateSelection> saved, {
  GenerateSelection selection = initial,
}) => tester.pumpWidget(
  MyApp(
    home: ModyHomeView(
      initialSelection: selection,
      suggestions: GenerateSuggestions(random: random),
      onApplied: saved.add,
    ),
  ),
);

String description(WidgetTester tester) =>
    tester.widget<TextFormField>(field).controller!.text;

bool selected(WidgetTester tester, String key) =>
    tester.widget<Semantics>(find.byKey(Key(key))).properties.selected == true;

void expectNoGeneration() {
  expect(find.text(readyMessage), findsNothing);
  expect(find.byKey(const Key('generateWarning')), findsNothing);
  expect(find.text('Uygula'), findsNothing);
}

void main() {
  testWidgets('Default suggestions work in all modes after reassemble', (
    tester,
  ) async {
    phone(tester, 390);
    final saved = <GenerateSelection>[];
    await tester.pumpWidget(MyApp(home: ModyHomeView(onApplied: saved.add)));
    // Reassemble is the widget lifecycle used by hot reload. Unlike the other
    // tests, no selector is injected: exercise the production lazy default.
    // Adding a field to an already-running VM still needs a live reload check.
    await reassemble(tester);
    await tap(tester, ideaButton);
    expect(saved, hasLength(1));
    expect(saved.last.vehicleId, isNotEmpty);
    expect(saved.last.style, isNotEmpty);
    expect(saved.last.extra, isNotEmpty);
    expect(saved.last.color, isNotEmpty);
    final styleSelection = saved.last;

    await tap(tester, find.text('Custom Edit'));
    await tester.enterText(field, 'Mevcut açıklamam');
    await reassemble(tester);
    await tap(tester, ideaButton);
    expect(saved, hasLength(2));
    expect(saved.last.vehicleId, isNotEmpty);
    expect(saved.last.style, styleSelection.style);
    expect(saved.last.extra, styleSelection.extra);
    expect(saved.last.color, styleSelection.color);
    expect(description(tester), 'Mevcut açıklamam');

    await tap(tester, find.text('Detail Edit'));
    await reassemble(tester);
    await tap(tester, ideaButton);
    expect(saved, hasLength(3));
    expect(saved.last.vehicleId, isNotEmpty);
    expect(saved.last.detailColor, isNotEmpty);
    expect(saved.last.parts, hasLength(1));
    expect(
      DetailPartCatalog.restoreSelections(saved.last.angle, saved.last.parts),
      saved.last.parts,
    );
    expectNoGeneration();
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets(
      'Style fills all fields atomically and preserves Detail: $width',
      (tester) async {
        phone(tester, width);
        final saved = <GenerateSelection>[];
        final random = SequenceRandom([11, 5, 5, 11]);
        await render(tester, random, saved);
        await tap(tester, ideaButton);
        expect(saved, hasLength(1));
        expect(saved.single.toJson(), {
          ...initial.toJson(),
          'vehicleId': 'buick_classic',
          'style': 'Şehir',
          'extra': 'Gövde Kiti',
          'color': 'Özel Gri',
          'colorCategory': 2,
        });
        expect(
          tester
              .widget<VehicleImageInput>(find.byType(VehicleImageInput))
              .selectedId,
          'buick_classic',
        );
        expectNoGeneration();
        expect(random.exhausted, isTrue);

        // Random choices and the existing Apply/cancel panels use one catalog.
        await tap(tester, find.text('Stil'));
        expect(selected(tester, 'optionŞehir'), isTrue);
        await tap(tester, find.text('Sportif'));
        await tap(tester, find.byTooltip('Paneli kapat'));
        expect(saved, hasLength(1));
        await tap(tester, find.text('Ekstra'));
        expect(selected(tester, 'optionGövde Kiti'), isTrue);
        await tap(tester, find.byTooltip('Paneli kapat'));
        await tap(tester, find.text('Renk'));
        expect(selected(tester, 'colorÖzel Gri'), isTrue);
        await tap(tester, find.text('Mat'));
        await tap(tester, find.text('Mavi'));
        await tap(tester, find.text('Uygula'));
        expect(saved, hasLength(2));
        expect(saved.last.color, 'Mavi');
        expect(saved.last.colorCategory, 0);
        await tap(tester, find.text('Arabamı Modifiye Et'));
        expect(find.text(readyMessage), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Custom idea changes only car, magic replaces text: $width', (
      tester,
    ) async {
      phone(tester, width);
      final saved = <GenerateSelection>[];
      final random = SequenceRandom([9, 0, 1]);
      await render(tester, random, saved);
      await tap(tester, find.text('Custom Edit'));
      await tester.enterText(field, 'Kendi açıklamam');
      await tap(tester, ideaButton);
      expect(saved, hasLength(1));
      expect(saved.single.toJson(), {
        ...initial.toJson(),
        'vehicleId': 'skyline_gtr',
      });
      expect(description(tester), 'Kendi açıklamam');
      await tap(tester, magicButton);
      expect(description(tester), ModificationPrompts.values[0]);
      await tap(tester, magicButton);
      expect(description(tester), ModificationPrompts.values[1]);
      expect(saved, hasLength(1));
      expect(random.exhausted, isTrue);
      expectNoGeneration();
      expect(tester.testTextInput.isVisible, isFalse);
      expect(
        tester.widget<TextFormField>(field).controller!.selection.baseOffset,
        ModificationPrompts.values[1].length,
      );
      await tester.enterText(field, 'Öneriyi elle değiştirdim');
      await tester.pumpAndSettle();
      await tap(tester, find.text('Detail Edit'));
      await tap(tester, find.text('Custom Edit'));
      expect(description(tester), 'Öneriyi elle değiştirdim');
      await tap(tester, clearButton);
      expect(description(tester), isEmpty);
      expect(clearButton, findsNothing);
      await tap(tester, find.text('Arabamı Modifiye Et'));
      expect(find.text(GenerateValidationMessages.description), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Magic works without a car; submit still needs a car: $width', (
      tester,
    ) async {
      phone(tester, width);
      final saved = <GenerateSelection>[];
      final random = SequenceRandom([0, 1, 1]);
      await render(tester, random, saved, selection: const GenerateSelection());
      await tap(tester, find.text('Custom Edit'));
      await tap(tester, find.text('Arabamı Modifiye Et'));
      expect(find.text(GenerateValidationMessages.vehicle), findsOneWidget);
      await tap(tester, magicButton);
      expect(description(tester), ModificationPrompts.values.first);
      expect(saved, isEmpty);
      expect(find.byKey(const Key('selectedVehicleImage')), findsNothing);
      expectNoGeneration();
      await tap(tester, find.text('Arabamı Modifiye Et'));
      expect(find.text(GenerateValidationMessages.vehicle), findsOneWidget);
      await tap(tester, magicButton);
      await tap(tester, magicButton);
      expect(description(tester), ModificationPrompts.values.last);
      expect(random.exhausted, isTrue);
      expect(tester.takeException(), isNull);
    });

    for (var a = 0; a < 3; a++) {
      final angle = DetailPartCatalog.byAngle.keys.elementAt(a);
      final category = DetailPartCatalog.forAngle(angle).last;
      testWidgets(
        'Detail idea $angle clears old parts and persists once: $width',
        (tester) async {
          phone(tester, width);
          final saved = <GenerateSelection>[];
          final random = SequenceRandom([
            11,
            a,
            DetailPartCatalog.forAngle(angle).length - 1,
            2,
            9,
          ]);
          await render(tester, random, saved);
          await tap(tester, find.text('Detail Edit'));
          await tap(tester, ideaButton);
          expect(saved, hasLength(1));
          expect(saved.single.toJson(), {
            ...initial.toJson(),
            'vehicleId': 'buick_classic',
            'angle': angle,
            'parts': {category.title: 2},
            'detailColor': 'Özel Mavi',
            'detailColorCategory': 2,
          });
          expectNoGeneration();
          expect(random.exhausted, isTrue);
          await tap(tester, find.text('Açı'));
          expect(selected(tester, 'option$angle'), isTrue);
          await tap(tester, find.byTooltip('Paneli kapat'));
          await tap(tester, find.text('Renk'));
          expect(selected(tester, 'colorÖzel Mavi'), isTrue);
          await tap(tester, find.byTooltip('Paneli kapat'));
          expect(saved, hasLength(1));
          await tap(tester, find.text('Modifiye Et'));
          expect(find.text(readyMessage), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tap(tester, find.byTooltip('Araç seçimini kaldır'));
          expect(saved.last.angle, angle);
          expect(saved.last.parts, {category.title: 2});
          expect(saved.last.detailColor, 'Özel Mavi');
          await tap(tester, find.text('Modifiye Et'));
          expect(find.text(GenerateValidationMessages.vehicle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'Removed help/live edit; Detail action uses full width: $width',
      (tester) async {
        phone(tester, width);
        await render(tester, SequenceRandom([]), []);
        for (final mode in ['Style Builder', 'Custom Edit', 'Detail Edit']) {
          await tap(tester, find.text(mode));
          expect(find.text('?'), findsNothing);
          expect(find.text('Canlı\nEdit'), findsNothing);
          expect(find.byIcon(Icons.connected_tv_outlined), findsNothing);
        }
        final button = find.widgetWithText(ModyActionButton, 'Modifiye Et');
        expect(
          tester.getSize(button).width,
          tester.getSize(find.byType(VehicleImageInput)).width,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Detail random then manual angle uses existing reset/color rules',
    (tester) async {
      phone(tester, 390);
      final saved = <GenerateSelection>[];
      await render(tester, SequenceRandom([0, 1, 0, 1, 5]), saved);
      await tap(tester, find.text('Detail Edit'));
      await tap(tester, ideaButton);
      expect(saved.last.parts, {'Spoiler': 1});
      await tap(tester, find.text('Açı'));
      await tap(tester, find.text('Uygula'));
      expect(saved.last.parts, {'Spoiler': 1});
      await tap(tester, find.text('Açı'));
      await tap(tester, find.text('Front'));
      await tap(tester, find.text('Uygula'));
      expect(saved.last.angle, 'Front');
      expect(saved.last.parts, isEmpty);
      expect(saved.last.detailColor, 'Premium Mavi');
      await tap(tester, find.text('Modifiye Et'));
      expect(find.text(readyMessage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Complete suggested selections restore in a new screen', (
    tester,
  ) async {
    phone(tester, 390);
    final saved = <GenerateSelection>[];
    await render(tester, SequenceRandom([11, 5, 5, 11, 9, 2, 6, 2, 5]), saved);
    await tap(tester, ideaButton);
    await tap(tester, find.text('Detail Edit'));
    await tap(tester, ideaButton);
    final restored = GenerateSelection.fromJson(saved.last.toJson());
    expect(restored.toJson(), saved.last.toJson());
    await tester.pumpWidget(const SizedBox.shrink());
    await render(tester, SequenceRandom([]), [], selection: restored);
    expect(find.text('Şehir'), findsOneWidget);
    expect(find.text('Gövde Kiti'), findsOneWidget);
    expect(find.text('Özel Gri'), findsOneWidget);
    await tap(tester, find.text('Detail Edit'));
    expect(find.text('Side'), findsOneWidget);
    expect(find.text('Side Skirts 3'), findsOneWidget);
    expect(find.text('Premium Mavi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Main tabs persist each idea once and preserve the prompt', (
    tester,
  ) async {
    phone(tester, 390);
    final storage = IdeaMemoryStore();
    final manager = SelectionCacheManager(storage);
    await tester.pumpWidget(MyApp(home: MainTabsView(cacheManager: manager)));
    await tap(tester, ideaButton);
    expect(storage.writes, 1);
    final style = (await manager.load()).generate;
    expect(style.vehicleId, isNotEmpty);
    expect(style.style, isNotEmpty);
    expect(style.extra, isNotEmpty);
    expect(style.color, isNotEmpty);
    await tap(tester, find.text('Detail Edit'));
    await tap(tester, ideaButton);
    expect(storage.writes, 2);
    final detail = (await manager.load()).generate;
    expect(detail.parts, hasLength(1));
    expect(
      DetailPartCatalog.restoreSelections(detail.angle, detail.parts),
      detail.parts,
    );
    expect(detail.style, style.style);
    expect(detail.color, style.color);
    await tap(tester, find.text('Custom Edit'));
    await tap(tester, magicButton);
    final prompt = description(tester);
    expect(ModificationPrompts.values, contains(prompt));
    expect(storage.writes, 2); // Description remains session-only, as before.
    await tap(tester, ideaButton);
    expect(storage.writes, 3);
    final custom = (await manager.load()).generate;
    expect(custom.parts, detail.parts);
    expect(custom.angle, detail.angle);
    await tap(tester, find.text('Explore'));
    await tap(tester, find.text('Üret'));
    expect(description(tester), prompt);
    expect(storage.writes, 3);
    await tester.pumpWidget(const SizedBox.shrink());
    final restored = await SelectionCacheManager(storage).load();
    expect(restored.generate.toJson(), custom.toJson());
    await tester.pumpWidget(
      MyApp(home: MainTabsView(initialSelections: restored)),
    );
    expect(
      tester
          .widget<VehicleImageInput>(find.byType(VehicleImageInput))
          .selectedId,
      custom.vehicleId,
    );
    expect(find.text(custom.style), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rapid Detail ideas each replace the entire part selection', (
    tester,
  ) async {
    phone(tester, 390);
    final random = SequenceRandom([
      0, 1, 0, 0, 0, // Rear/Spoiler
      1, 0, 1, 1, 1, // Front/Hood
      2, 2, 6, 2, 2, // Side/Side Skirts
    ]);
    final saved = <GenerateSelection>[];
    await render(tester, random, saved);
    await tap(tester, find.text('Detail Edit'));
    for (var i = 0; i < 3; i++) {
      await tester.tap(ideaButton);
    }
    await tester.pumpAndSettle();
    expect(saved.map((s) => s.angle), ['Rear', 'Front', 'Side']);
    expect(saved.map((s) => s.parts), [
      {'Spoiler': 0},
      {'Hood': 1},
      {'Side Skirts': 2},
    ]);
    expect(random.exhausted, isTrue);
    expect(find.text('Side Skirts 3'), findsOneWidget);
    expectNoGeneration();
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('Short screen, large text and keyboard remain usable: $width', (
      tester,
    ) async {
      phone(tester, width);
      tester.view.physicalSize = Size(width, 568);
      final random = SequenceRandom([0, 1, 0]);
      await tester.pumpWidget(
        MyApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.4)),
              child: ModyHomeView(
                suggestions: GenerateSuggestions(random: random),
              ),
            ),
          ),
        ),
      );
      await tap(tester, find.text('Custom Edit'));
      await tap(tester, magicButton);
      expect(description(tester), ModificationPrompts.values.first);
      expect(
        tester
            .widget<VehicleImageInput>(
              find.byType(VehicleImageInput, skipOffstage: false),
            )
            .height,
        140,
      );
      await tap(tester, ideaButton);
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.resetViewInsets);
      await tester.enterText(field, 'Elle yazılan metin');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<VehicleImageInput>(
              find.byType(VehicleImageInput, skipOffstage: false),
            )
            .height,
        100,
      );
      await tap(tester, magicButton);
      expect(description(tester), ModificationPrompts.values.first);
      expect(tester.testTextInput.isVisible, isFalse);
      // A real keyboard removes its insets after unfocus. The fake view does not.
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tap(tester, clearButton);
      expect(description(tester), isEmpty);
      await tap(tester, find.text('Arabamı Modifiye Et'));
      expect(find.text(GenerateValidationMessages.description), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }
}
