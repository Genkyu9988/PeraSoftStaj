import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/feature/generation/view/generation_result_view.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_option_boxes.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/widget/color_options_panel.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';
import 'helpers/controlled_generation_service.dart';

const _selection = GenerateSelection(
  vehicleId: 'bmw_ix5',
  style: 'Off Road',
  extra: 'Gövde Kiti',
  color: 'Premium Kırmızı',
  angle: 'Rear',
  parts: {'Spoiler': 0, 'Exhaust': 1},
  detailColor: 'Özel Mor',
);

void _phone(WidgetTester tester, Size size, double scale) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
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
  if (target.evaluate().isEmpty &&
      find.byKey(const Key('exploreDetailScroll')).evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(
      target,
      160,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('exploreDetailScroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }
  if (target.hitTestable().evaluate().isEmpty) {
    final element = tester.element(target);
    await Scrollable.of(
      element,
    ).position.ensureVisible(element.renderObject!, alignment: 0.5);
    // A controlled service keeps its progress animation running until the test
    // completes it; settling here would advance the clock to the timeout.
    await tester.pump();
  }
  expect(
    target.hitTestable(),
    findsOneWidget,
    reason: 'Target rect: ${tester.getRect(target)}',
  );
  await tester.tap(target.hitTestable());
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  for (final title in [
    'Japanese',
    'Customize Rims',
    'Change Color',
    'Clone Car Style',
    'Cliff Drive',
  ]) {
    testWidgets('$title complete editor at 320px/2x: cancel, retry and back', (
      tester,
    ) async {
      _phone(tester, const Size(320, 568), 2);
      final service = ControlledGenerationService();
      final video = title == 'Cliff Drive';
      final initial = ExploreSelection(
        image: 'bmw_ix5',
        option: title == 'Change Color'
            ? 'Premium Kırmızı'
            : CarModCatalog.groups['Customize Rims']!.first.id,
        referenceImage: ReferenceCarCatalog.items.first.id,
      );
      final writes = <ExploreSelection>[];
      await tester.pumpWidget(
        MyApp(
          home: ExploreDetailView(
            title: title,
            isVideo: video,
            isCarMod: title == 'Customize Rims' || title == 'Change Color',
            coverImagePath: video
                ? ImageItems.aiVideoCovers[title]
                : ImageItems.exploreCovers[title],
            initialSelection: initial,
            onApplied: writes.add,
            generationService: service,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final submit = find.text(video ? 'Video Oluştur' : 'Arabamı Modifiye Et');
      await _tap(tester, submit, settle: false);
      expect(service.requests, hasLength(1));
      await _tap(tester, find.byKey(const Key('dismissGeneration')));
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.byType(GenerationResultView), findsNothing);
      expect(find.byKey(const Key('generationOverlay')), findsNothing);
      await _tap(tester, submit, settle: false);
      service.fail(1);
      await tester.pumpAndSettle();
      await _tap(
        tester,
        find.byKey(const Key('retryGeneration')),
        settle: false,
      );
      expect(service.requests[2], same(service.requests[1]));
      expect(service.requests[2].vehicleId, initial.image);
      if (video) {
        expect(service.requests[2], isA<AiVideoGenerationRequest>());
      }
      service.succeed(2);
      await tester.pumpAndSettle();
      expect(find.byType(GenerationResultView), findsOneWidget);
      await _tap(tester, find.text('Seçimlere Dön'));
      expect(find.byKey(const Key('generationOverlay')), findsNothing);
      expect(writes, isEmpty);
      await _tap(tester, submit, settle: false);
      expect(service.requests[3], service.requests[1]);
      await _tap(tester, find.byKey(const Key('dismissGeneration')));
      service.fail(3);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('generationOverlay')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Small Custom Edit stays usable with keyboard and 2x text', (
    tester,
  ) async {
    _phone(tester, const Size(320, 568), 2);
    await tester.pumpWidget(
      MyApp(
        home: MainTabsView(
          initialSelections: AppSelections(generate: _selection),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Custom Edit'));
    final field = find.byKey(const Key('customEditDescriptionField'));
    await tester.enterText(field, 'Mat mor boya ve altın jant.');
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _tap(tester, find.text('Arabamı Modifiye Et'));
    tester.view.resetViewInsets();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('generationResultPage')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Mat mor boya ve altın jant.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(320, 568), const Size(390, 844)]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Complete main screens at $size, text $scale', (
        tester,
      ) async {
        _phone(tester, size, scale);
        await tester.pumpWidget(
          MyApp(
            home: MainTabsView(
              initialSelections: AppSelections(generate: _selection),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final mode in ['Detail Edit', 'Custom Edit', 'Style Builder']) {
          await _tap(tester, find.text(mode, skipOffstage: false));
          if (mode == 'Custom Edit') {
            await tester.enterText(
              find.byKey(const Key('customEditDescriptionField')),
              'Aracın rengini mor yap.',
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
          expect(tester.takeException(), isNull);
        }
        for (final title in ['Explore', 'AI Video', 'Garaj', 'Üret']) {
          await _tap(
            tester,
            find.descendant(
              of: find.byType(ModyBottomBar),
              matching: find.text(title),
            ),
          );
          expect(tester.takeException(), isNull);
        }
        final boxes = tester.widget<GenerateOptionBoxes>(
          find.byType(GenerateOptionBoxes),
        );
        expect(boxes.firstSelection, _selection.style);
        expect(boxes.secondSelection, _selection.extra);
        expect(boxes.colorSelection, _selection.color);
      });
    }
  }

  for (final size in [const Size(320, 360), const Size(320, 568)]) {
    testWidgets('Color sheet applies and cancels at $size, 2x text', (
      tester,
    ) async {
      _phone(tester, size, 2);
      String? applied = 'Özel Mor';
      await tester.pumpWidget(
        MyApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  applied = await showSelectionSheet<String>(
                    context: context,
                    initialValue: 'Özel Mor',
                    builder: (context, draft, change, apply) =>
                        ColorOptionsPanel(
                          selectedTitle: draft,
                          onSelected: (name, _) => change(name),
                          onApply: apply,
                        ),
                  );
                },
                child: const Text('Aç'),
              ),
            ),
          ),
        ),
      );
      await _tap(tester, find.text('Aç'));
      await _tap(tester, find.text('Premium'));
      await tester.scrollUntilVisible(
        find.text('Premium Kırmızı'),
        80,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await _tap(tester, find.text('Premium Kırmızı'));
      await _tap(tester, find.text('Uygula'));
      expect(applied, 'Premium Kırmızı');
      expect(tester.takeException(), isNull);
      await _tap(tester, find.text('Aç'));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(applied, isNull);
      expect(find.byType(BottomSheet), findsNothing);
    });
  }

  testWidgets(
    'Vehicle sheet with large text and keyboard keeps Apply reachable',
    (tester) async {
      _phone(tester, const Size(320, 568), 2);
      String? applied;
      await tester.pumpWidget(
        MyApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  applied = await showSelectionSheet<String>(
                    context: context,
                    initialValue: 'bmw_ix5',
                    builder: (context, draft, change, apply) =>
                        VehicleSelectionPanel(
                          selected: draft,
                          onSelected: change,
                          onApply: apply,
                        ),
                  );
                },
                child: const Text('Aç'),
              ),
            ),
          ),
        ),
      );
      await _tap(tester, find.text('Aç'));
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Uygula'));
      expect(applied, 'bmw_ix5');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Option titles and choices do not clip at 320px with 2x text', (
    tester,
  ) async {
    _phone(tester, const Size(320, 568), 2);
    await tester.pumpWidget(
      MyApp(
        home: Scaffold(
          body: GenerateOptionBoxes(
            firstTitle: 'Stil',
            secondTitle: 'Ekstra',
            firstSelection: _selection.style,
            secondSelection: _selection.extra,
            colorSelection: _selection.color,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    for (final text in ['Stil', 'Ekstra', 'Renk', 'Premium Kırmızı']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
      expect(paragraph.didExceedMaxLines, isFalse, reason: text);
    }
    expect(tester.takeException(), isNull);
  });
}
