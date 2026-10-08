import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/product/catalog/ai_video_items.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/validation/explore_validation_messages.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/feature/editor/view/widget/selection_warning_frame.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';

const imageReady = 'Demo sonuç — AI ile üretilmedi';
const videoReady =
    'Aşağıdaki fotoğraf seçtiğiniz orijinal araçtır. Seçilen şablon uygulanmadı; gerçek video üretilmedi.';
final warning = find.byKey(const Key('exploreWarning'));
final vehicle = VehicleCatalog.samples.first.id;
final reference = ReferenceCarCatalog.items.first.id;

void phone(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tap(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
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
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target.hitTestable());
  await tester.pumpAndSettle();
}

Finder action([bool video = false]) => find.widgetWithText(
  ModyActionButton,
  video ? 'Video Oluştur' : 'Arabamı Modifiye Et',
);

Future<void> render(
  WidgetTester tester,
  String title, {
  ExploreSelection selection = const ExploreSelection(),
  bool video = false,
  ValueChanged<ExploreSelection>? onApplied,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MyApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: ExploreDetailView(
            key: ValueKey(Object()),
            title: title,
            isCarMod: ExploreItems.carMods.contains(title),
            isVideo: video,
            coverImagePath: video
                ? ImageItems.aiVideoCovers[title]
                : ImageItems.exploreCovers[title],
            initialSelection: selection,
            onApplied: onApplied,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void expectWarning(WidgetTester tester, String text) {
  expect(warning, findsOneWidget);
  expect(
    find.descendant(of: warning, matching: find.text(text)),
    findsOneWidget,
  );
  expect(tester.widget<Material>(warning).color, ColorItems.warningRed);
  expect(
    find.descendant(of: warning, matching: find.byIcon(Icons.error_outline)),
    findsOneWidget,
  );
  expect(find.byType(AlertDialog), findsNothing);
  expect(find.text(imageReady), findsNothing);
  expect(find.text(videoReady), findsNothing);
  final rect = tester.getRect(warning);
  final inputs = tester.getRect(find.byType(SelectionWarningFrame));
  expect(rect.bottom, closeTo(inputs.bottom - 6, .01));
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(tester.view.physicalSize.width));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.bottom, lessThanOrEqualTo(tester.view.physicalSize.height));
  expect(tester.takeException(), isNull);
}

void main() {
  for (final width in [320.0, 390.0]) {
    for (final title in [...ExploreItems.carMods, 'Clone Car Style']) {
      testWidgets(
        '$title: all four input states, first error and no cache writes ($width)',
        (tester) async {
          phone(tester, width: width);
          final clone = title == 'Clone Car Style';
          final option = clone
              ? ''
              : title == 'Change Color'
              ? 'Mavi'
              : CarModCatalog.groups[title]!.first.id;
          var writes = 0;
          for (final imagePresent in [false, true]) {
            for (final secondPresent in [false, true]) {
              await render(
                tester,
                title,
                selection: ExploreSelection(
                  image: imagePresent ? vehicle : '',
                  option: secondPresent ? option : '',
                  referenceImage: clone && secondPresent ? reference : '',
                ),
                onApplied: (_) => writes++,
              );
              expect(warning, findsNothing);
              expect(
                tester.widget<ModyActionButton>(action()).onPressed,
                isNotNull,
              );
              await tap(tester, action());
              if (!imagePresent) {
                expectWarning(
                  tester,
                  clone
                      ? ExploreValidationMessages.cloneImage
                      : ExploreValidationMessages.image,
                );
              } else if (!secondPresent) {
                expectWarning(
                  tester,
                  clone
                      ? ExploreValidationMessages.referenceImage
                      : title == 'Change Color'
                      ? ExploreValidationMessages.color
                      : ExploreValidationMessages.targetImage,
                );
              } else {
                expect(warning, findsNothing);
                expect(find.text(imageReady), findsOneWidget);
                await tap(tester, find.text('Seçimlere Dön'));
              }
              expect(writes, 0);
              expect(
                find.byKey(const Key('selectedVehicleImage')),
                imagePresent ? findsOneWidget : findsNothing,
              );
              expect(tester.takeException(), isNull);
            }
          }
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  final singles = [
    ...ExploreItems.styleBuilder,
    ...ExploreItems.wallpaperMaker,
    ...ExploreItems.aiEdits.where((title) => title != 'Clone Car Style'),
  ];
  final videos = [
    ...AiVideoItems.transformations,
    ...AiVideoItems.driveScenes,
    ...AiVideoItems.filters,
  ];
  for (final title in [...singles, ...videos]) {
    testWidgets('$title needs only a vehicle; no hidden second requirement', (
      tester,
    ) async {
      phone(tester);
      final video = videos.contains(title);
      await render(tester, title, video: video);
      expect(warning, findsNothing);
      expect(
        tester.widget<ModyActionButton>(action(video)).onPressed,
        isNotNull,
      );
      await tap(tester, action(video));
      expectWarning(tester, ExploreValidationMessages.image);
      await tap(tester, find.byTooltip('Örnek Araç 1'));
      expect(warning, findsNothing);
      await tap(tester, action(video));
      expect(find.text(video ? videoReady : imageReady), findsOneWidget);
      await tap(tester, find.text('Seçimlere Dön'));
      await tap(tester, find.byTooltip('Araç seçimini kaldır'));
      await tap(tester, action(video));
      expectWarning(tester, ExploreValidationMessages.image);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'Invalid restored mod selections still request a target image for every Car Mod',
    (tester) async {
      phone(tester);
      for (final title in ExploreItems.carMods.where(
        (title) => title != 'Change Color',
      )) {
        await render(
          tester,
          title,
          selection: ExploreSelection(image: vehicle, option: 'removed-option'),
        );
        expect(
          tester.widget<ModyActionButton>(action()).onPressed,
          isNotNull,
          reason: title,
        );
        expect(warning, findsNothing);
        await tap(tester, action());
        expectWarning(tester, ExploreValidationMessages.targetImage);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final title in [...ExploreItems.carMods, 'Clone Car Style']) {
    testWidgets('$title panel has no new vehicle gate; cancel is not Apply', (
      tester,
    ) async {
      phone(tester, width: 320);
      final clone = title == 'Clone Car Style';
      final color = title == 'Change Color';
      var saved = const ExploreSelection();
      var writes = 0;
      await render(
        tester,
        title,
        onApplied: (value) {
          saved = value;
          writes++;
        },
      );
      await tap(tester, action());
      final input = clone
          ? find.byKey(const Key('referenceInput'))
          : find.byIcon(Icons.keyboard_arrow_down);
      await tap(tester, input);
      expect(warning, findsNothing);
      expect(find.byType(BottomSheet), findsOneWidget);
      final choice = clone
          ? find.byKey(Key('choice$reference'))
          : color
          ? find.text('Mavi')
          : find.byKey(Key('choice${CarModCatalog.groups[title]!.first.id}'));
      await tap(tester, choice);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(writes, 0);
      // Add vehicle, then ensure the canceled draft does not satisfy validation.
      await tap(tester, find.byTooltip('Örnek Araç 1'));
      await tap(tester, action());
      expectWarning(
        tester,
        clone
            ? ExploreValidationMessages.referenceImage
            : color
            ? ExploreValidationMessages.color
            : ExploreValidationMessages.targetImage,
      );
      await tap(tester, input);
      await tap(tester, choice);
      await tap(tester, find.text('Uygula'));
      expect(writes, 2);
      final committed = saved.toJson();
      await tap(tester, action());
      expect(find.text(imageReady), findsOneWidget);
      await tap(tester, find.text('Seçimlere Dön'));
      expect(saved.toJson(), committed);
      expect(writes, 2);
      await tap(tester, find.byTooltip('Araç seçimini kaldır'));
      expect(saved.image, '');
      expect(
        clone ? saved.referenceImage : saved.option,
        clone
            ? reference
            : color
            ? 'Mavi'
            : CarModCatalog.groups[title]!.first.id,
      );
      await tap(tester, action());
      expectWarning(
        tester,
        clone
            ? ExploreValidationMessages.cloneImage
            : ExploreValidationMessages.image,
      );
      expect(writes, 3);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('Repeated warnings replace, restart timeout and leave no queue', (
    tester,
  ) async {
    phone(tester);
    await render(tester, 'Neons');
    await tap(tester, action());
    final callback = tester.widget<ModyActionButton>(action()).onPressed!;
    for (var i = 0; i < 5; i++) {
      callback();
    }
    await tester.pumpAndSettle();
    expectWarning(tester, ExploreValidationMessages.image);
    await tester.pump(const Duration(seconds: 3));
    callback();
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(warning, findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(warning, findsNothing);
    await tester.pump(const Duration(seconds: 20));
    expect(warning, findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final systemBack in [false, true]) {
    testWidgets(
      'Back ($systemBack) removes route-local warning and cancels timer',
      (tester) async {
        phone(tester);
        await tester.pumpWidget(const MyApp(home: ExploreView()));
        await tap(tester, find.text('Change Color'));
        await tap(tester, action());
        expectWarning(tester, ExploreValidationMessages.image);
        if (systemBack) {
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        } else {
          await tap(tester, find.byTooltip('Explore’a dön'));
        }
        expect(warning, findsNothing);
        await tap(tester, find.text('Change Color'));
        expect(warning, findsNothing);
        await tester.pump(const Duration(seconds: 10));
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final scale in [1.0, 1.4]) {
    testWidgets(
      'Long Clone warning remains visible on short phone; scale $scale',
      (tester) async {
        phone(tester, width: 320, height: 568);
        await render(tester, 'Clone Car Style', textScale: scale);
        await tap(tester, action());
        expectWarning(tester, ExploreValidationMessages.cloneImage);
        // Banner lets the user tap through to fix the missing input immediately.
        await tap(tester, find.byKey(const Key('vehicleInput')));
        expect(warning, findsNothing);
        expect(find.byType(BottomSheet), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 10));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
