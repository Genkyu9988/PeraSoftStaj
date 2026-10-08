import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/validation/explore_validation_messages.dart';

void main() {
  for (final appearance in ModyButtonAppearance.values) {
    testWidgets('$appearance callback ve pasif davranışı korur', (
      tester,
    ) async {
      var taps = 0;
      Future<void> render(bool enabled) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                child: ModyActionButton(
                  title: 'Uzun işlem butonu başlığı',
                  appearance: appearance,
                  icon: Icons.auto_awesome,
                  onPressed: enabled ? () => taps++ : null,
                ),
              ),
            ),
          ),
        ),
      );
      await render(false);
      await tester.tap(find.byType(ModyActionButton));
      expect(taps, 0);
      expect(
        tester
            .widget<ButtonStyleButton>(
              find.byWidgetPredicate((w) => w is ButtonStyleButton),
            )
            .onPressed,
        isNull,
      );
      await render(true);
      await tester.tap(find.byType(ModyActionButton));
      expect(taps, 1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final video in [false, true]) {
    testWidgets('${video ? 'AI Video' : 'Car Mods'} gerekli onayları bekler', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MyApp(
          home: ExploreDetailView(
            title: video ? 'Apex Transform' : 'Change Color',
            isCarMod: !video,
            isVideo: video,
          ),
        ),
      );
      final action = find.widgetWithText(
        ModyActionButton,
        video ? 'Video Oluştur' : 'Arabamı Modifiye Et',
      );
      bool enabled() =>
          tester.widget<ModyActionButton>(action).onPressed != null;
      Future<void> tap(String text) async {
        await tester.tap(find.text(text).hitTestable());
        await tester.pumpAndSettle();
      }

      expect(enabled(), isTrue);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text(ExploreValidationMessages.image), findsOneWidget);
      await tap('Resim Seçin');
      expect(
        tester
            .widget<ModyActionButton>(
              find.widgetWithText(ModyActionButton, 'Uygula'),
            )
            .onPressed,
        isNull,
      );
      await tap('Klasik Mustang');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(enabled(), isTrue);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text(ExploreValidationMessages.image), findsOneWidget);
      await tap('Resim Seçin');
      await tap('Klasik Mustang');
      await tap('Uygula');
      expect(enabled(), isTrue);
      if (!video) {
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(find.text(ExploreValidationMessages.color), findsOneWidget);
        await tap('Renk');
        await tap('Mavi');
        await tap('Uygula');
      }
      expect(enabled(), isTrue);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text('Demo sonuç — AI ile üretilmedi'), findsOneWidget);
    });
  }
}
