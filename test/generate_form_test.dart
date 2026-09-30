import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/demos/mody_home_view.dart';
import 'package:perasoft_staj/product/cache/generate_selection.dart';
import 'package:perasoft_staj/product/form_validator.dart';

const readyMessage =
    'Bilgiler hazır. Bu ekran mock; gerçek görsel üretimi henüz bağlı değil.';
const errorMessage = 'Lütfen yapmak istediğiniz değişikliği yazın.';

void phone(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tap(WidgetTester tester, String text) async {
  if (find.text(text).hitTestable().evaluate().isEmpty) {
    final element = tester.element(find.text(text));
    await Scrollable.of(element).position.ensureVisible(element.renderObject!);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  test('Açıklama doğrulaması boşluğu reddeder, anlamlı metni kabul eder', () {
    const validator = FormValidator();
    for (final value in [null, '', '   ', '\n\t']) {
      expect(validator.description(value), errorMessage);
    }
    expect(validator.description('  Mat siyah tasarım\nYeni jant  '), isNull);
  });

  for (final width in [390.0, 320.0]) {
    testWidgets('Custom Edit doğrulama ve klavye düzeni: $width', (
      tester,
    ) async {
      phone(tester, width);
      await tester.pumpWidget(const MyApp());
      await tap(tester, 'Custom Edit');
      expect(find.text(errorMessage), findsNothing);
      await tap(tester, 'Arabamı Modifiye Et');
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text(readyMessage), findsNothing);
      final field = find.byKey(const Key('customEditDescriptionField'));
      await tester.enterText(field, '   ');
      await tester.pumpAndSettle();
      expect(find.text(errorMessage), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.enterText(field, 'Mat siyah tasarım\nYeni jant');
      await tester.pumpAndSettle();
      expect(find.text(errorMessage), findsNothing);
      await tap(tester, 'Arabamı Modifiye Et');
      expect(find.text(readyMessage), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tap(tester, 'Detail Edit');
      await tap(tester, 'Custom Edit');
      expect(find.text('Mat siyah tasarım\nYeni jant'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Onaylanmamış seçimler üretim kontrolünü geçemez', (
    tester,
  ) async {
    phone(tester, 390);
    await tester.pumpWidget(const MyApp());
    await tap(tester, 'Arabamı Modifiye Et');
    expect(
      find.text('Stil, Ekstra, Renk seçiminizi yapıp Uygula ile onaylayın.'),
      findsOneWidget,
    );
    await tap(tester, 'Stil');
    await tap(tester, 'Klasik');
    await tester.tap(find.byTooltip('Paneli kapat'));
    await tester.pumpAndSettle();
    await tap(tester, 'Arabamı Modifiye Et');
    expect(find.text(readyMessage), findsNothing);
    await tap(tester, 'Detail Edit');
    await tap(tester, 'Modifiye Et');
    expect(
      find.text('Açı, Ayarla, Renk seçiminizi yapıp Uygula ile onaylayın.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Onaylı Style Builder ve Detail Edit seçimleri mock kontrole ulaşır',
    (tester) async {
      phone(tester, 390);
      await tester.pumpWidget(
        const MyApp(
          home: ModyHomeView(
            initialSelection: GenerateSelection(
              style: 'Klasik',
              extra: 'Jant',
              color: 'Mavi',
              angle: 'Rear',
              parts: {'Spoiler': 0},
              detailColor: 'Premium Mor',
              detailColorCategory: 1,
            ),
          ),
        ),
      );
      await tap(tester, 'Arabamı Modifiye Et');
      expect(find.text(readyMessage), findsOneWidget);
      await tap(tester, 'Detail Edit');
      await tap(tester, 'Modifiye Et');
      expect(find.text(readyMessage), findsOneWidget);
    },
  );
}
