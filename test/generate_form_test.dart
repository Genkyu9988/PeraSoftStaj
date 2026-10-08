import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';

const readyMessage = 'Demo sonuç — AI ile üretilmedi';
final warning = find.byKey(const Key('generateWarning'));

void phone(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tap(WidgetTester tester, String text) async {
  // The responsive header can scroll offscreen; reveal it before tapping.
  final target = find.text(
    text,
    skipOffstage: ![
      'Style Builder',
      'Custom Edit',
      'Detail Edit',
    ].contains(text),
  );
  if (target.hitTestable().evaluate().isEmpty) {
    final element = tester.element(target);
    await Scrollable.of(element).position.ensureVisible(element.renderObject!);
    await tester.pumpAndSettle();
  }
  await tester.tap(target.hitTestable());
  await tester.pumpAndSettle();
}

Future<void> render(
  WidgetTester tester, {
  GenerateSelection selection = const GenerateSelection(),
}) => tester.pumpWidget(
  MyApp(
    home: MainTabsView(initialSelections: AppSelections(generate: selection)),
  ),
);

void expectWarning(WidgetTester tester, String message) {
  expect(warning, findsOneWidget);
  expect(
    find.descendant(of: warning, matching: find.text(message)),
    findsOneWidget,
  );
  expect(
    tester.widget<SnackBar>(warning).backgroundColor,
    ColorItems.warningRed,
  );
  expect(tester.widget<SnackBar>(warning).behavior, SnackBarBehavior.floating);
  expect(
    find.descendant(of: warning, matching: find.byIcon(Icons.error_outline)),
    findsOneWidget,
  );
  expect(find.byType(AlertDialog), findsNothing);
  expect(find.text(readyMessage), findsNothing);
}

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets(
      'Üç modda boş form önce araç ister; bildirim alt çubuğun üstünde: $width',
      (tester) async {
        phone(tester, width);
        await render(tester);
        for (final mode in ['Style Builder', 'Custom Edit', 'Detail Edit']) {
          await tap(tester, mode);
          expect(warning, findsNothing);
          await tap(
            tester,
            mode == 'Detail Edit' ? 'Modifiye Et' : 'Arabamı Modifiye Et',
          );
          expectWarning(tester, GenerateValidationMessages.vehicle);
          expect(
            tester.getBottomLeft(warning).dy,
            lessThanOrEqualTo(tester.getTopLeft(find.byType(ModyBottomBar)).dy),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'Custom: araç önceliği, boş metin, klavye, geçerli metin: $width',
      (tester) async {
        phone(tester, width);
        await render(tester);
        await tap(tester, 'Custom Edit');
        final field = find.byKey(const Key('customEditDescriptionField'));
        // Metin önce girilebilir; araç olmadan üretim başlatılamaz.
        await tester.enterText(field, 'Mat siyah tasarım');
        await tap(tester, 'Arabamı Modifiye Et');
        expectWarning(tester, GenerateValidationMessages.vehicle);
        await tap(tester, 'Style Builder');
        await tester.tap(find.byTooltip('Örnek Araç 1'));
        await tester.pumpAndSettle();
        await tap(tester, 'Custom Edit');
        await tester.enterText(field, '');
        await tester.pumpAndSettle();
        expect(warning, findsNothing);
        await tap(tester, 'Arabamı Modifiye Et');
        expectWarning(tester, GenerateValidationMessages.description);
        expect(
          find.text(GenerateValidationMessages.description),
          findsOneWidget,
        );
        expect(tester.widget<TextFormField>(field).validator, isNull);

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.enterText(field, ' \n\t ');
        await tester.pumpAndSettle();
        await tap(tester, 'Arabamı Modifiye Et');
        expectWarning(tester, GenerateValidationMessages.description);
        await tester.enterText(field, '  Mat siyah tasarım\nYeni jant  ');
        await tester.pumpAndSettle();
        await tap(tester, 'Arabamı Modifiye Et');
        expect(warning, findsNothing);
        expect(find.text(readyMessage), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tap(tester, 'Detail Edit');
        await tap(tester, 'Custom Edit');
        expect(find.text('  Mat siyah tasarım\nYeni jant  '), findsOneWidget);
      },
    );
  }

  for (final choice in ['style', 'extra', 'color']) {
    testWidgets('Style: araç + yalnızca $choice yeterlidir', (tester) async {
      phone(tester, 390);
      await render(
        tester,
        selection: GenerateSelection(
          style: choice == 'style' ? 'Klasik' : '',
          extra: choice == 'extra' ? 'Jant' : '',
          color: choice == 'color' ? 'Mavi' : '',
        ),
      );
      await tap(tester, 'Arabamı Modifiye Et');
      expectWarning(tester, GenerateValidationMessages.vehicle);
      await tester.tap(find.byTooltip('Örnek Araç 1'));
      await tester.pumpAndSettle();
      await tap(tester, 'Arabamı Modifiye Et');
      expect(warning, findsNothing);
      expect(find.text(readyMessage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    });
  }

  for (final angle in ['Front', 'Rear', 'Side']) {
    testWidgets('Detail: araç + $angle ile parça/renk olmadan geçer', (
      tester,
    ) async {
      phone(tester, 390);
      await render(
        tester,
        selection: GenerateSelection(
          vehicleId: 'mustang_classic',
          angle: angle,
        ),
      );
      await tap(tester, 'Detail Edit');
      await tap(tester, 'Modifiye Et');
      expect(find.byKey(const Key('selectionAyarla')), findsNothing);
      expect(find.byKey(const Key('selectionRenk')), findsNothing);
      expect(warning, findsNothing);
      expect(find.text(readyMessage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'Style boş seçim ve Detail boş açı için doğru mesaj; iptal edilmiş taslak sayılmaz',
    (tester) async {
      phone(tester, 390);
      await render(
        tester,
        selection: const GenerateSelection(vehicleId: 'mustang_classic'),
      );
      await tap(tester, 'Arabamı Modifiye Et');
      expectWarning(tester, GenerateValidationMessages.styleChoice);
      await tap(tester, 'Stil');
      expect(warning, findsNothing);
      await tap(tester, 'Klasik');
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
      await tap(tester, 'Arabamı Modifiye Et');
      expectWarning(tester, GenerateValidationMessages.styleChoice);
      await tap(tester, 'Detail Edit');
      await tap(tester, 'Açı');
      await tap(tester, 'Front');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tap(tester, 'Modifiye Et');
      expectWarning(tester, GenerateValidationMessages.angle);
      await tap(tester, 'Ayarla');
      expectWarning(tester, GenerateValidationMessages.angle);
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  for (final vehicle in ['', 'mustang_classic']) {
    testWidgets('Ayarla/Renk ön koşulu yalnızca açı: vehicle=$vehicle', (
      tester,
    ) async {
      phone(tester, 390);
      await render(tester, selection: GenerateSelection(vehicleId: vehicle));
      await tap(tester, 'Detail Edit');
      for (final panel in ['Ayarla', 'Renk']) {
        await tap(tester, panel);
        expectWarning(tester, GenerateValidationMessages.angle);
        expect(find.byType(BottomSheet), findsNothing);
      }
      // Uyarı panel kilidini açık bırakmaz; açı paneli hemen açılabilir.
      await tap(tester, 'Açı');
      expect(warning, findsNothing);
      await tap(tester, 'Rear');
      await tap(tester, 'Uygula');
      // Ayarla seçilmeden önce renk seçmek serbesttir.
      await tap(tester, 'Renk');
      await tap(tester, 'Mavi');
      await tap(tester, 'Uygula');
      await tap(tester, 'Ayarla');
      await tester.tap(find.byKey(const Key('partSpoiler0')));
      await tester.pumpAndSettle();
      await tap(tester, 'Uygula');
      await tap(tester, 'Modifiye Et');
      if (vehicle.isEmpty) {
        expectWarning(tester, GenerateValidationMessages.vehicle);
      } else {
        expect(find.text(readyMessage), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Uyarı ve araç kaldırma mevcut seçimleri silmez; uyarı cache yazmaz',
    (tester) async {
      phone(tester, 390);
      const initial = GenerateSelection(
        style: 'Klasik',
        extra: 'Jant',
        color: 'Mavi',
        angle: 'Rear',
        parts: {'Spoiler': 0},
        detailColor: 'Premium Mor',
        detailColorCategory: 1,
      );
      var saved = initial;
      var saves = 0;
      await tester.pumpWidget(
        MyApp(
          home: ModyHomeView(
            initialSelection: initial,
            onApplied: (value) {
              saved = value;
              saves++;
            },
          ),
        ),
      );
      await tap(tester, 'Arabamı Modifiye Et');
      expectWarning(tester, GenerateValidationMessages.vehicle);
      await tap(tester, 'Detail Edit');
      await tap(tester, 'Modifiye Et');
      expectWarning(tester, GenerateValidationMessages.vehicle);
      expect(saves, 0);
      await tester.tap(find.byTooltip('Örnek Araç 1'));
      await tester.pumpAndSettle();
      await tap(tester, 'Modifiye Et');
      expect(find.text(readyMessage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Araç seçimini kaldır'));
      await tester.pumpAndSettle();
      expect(saved.toJson(), initial.toJson());
      expect(saves, 2);
      await tap(tester, 'Modifiye Et');
      expectWarning(tester, GenerateValidationMessages.vehicle);
      expect(saves, 2);
      expect(find.text('Rear'), findsOneWidget);
      expect(find.text('Spoiler 1'), findsOneWidget);
      expect(find.text('Premium Mor'), findsOneWidget);
    },
  );

  testWidgets(
    'Hızlı tekrar basışlar birikmez; iç ve ana sekme değişimi uyarıyı temizler',
    (tester) async {
      phone(tester, 390);
      await render(tester);
      final action = tester.widget<ModyActionButton>(
        find.widgetWithText(ModyActionButton, 'Arabamı Modifiye Et'),
      );
      // Aynı frame içinde bile kuyruk birikmemeli.
      for (var i = 0; i < 5; i++) {
        action.onPressed!();
      }
      await tester.pumpAndSettle();
      expectWarning(tester, GenerateValidationMessages.vehicle);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      await tap(tester, 'Arabamı Modifiye Et');
      await tap(tester, 'Custom Edit');
      expect(warning, findsNothing);
      await tap(tester, 'Arabamı Modifiye Et');
      await tap(tester, 'Explore');
      expect(warning, findsNothing);
      await tap(tester, 'Üret');
      expect(warning, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
