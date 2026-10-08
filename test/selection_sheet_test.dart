import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/widget/color_options_panel.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';

Future<void> tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).hitTestable());
  await tester.pumpAndSettle();
}

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final method in ['close', 'back', 'outside', 'swipe']) {
    testWidgets(
      '$method taslağı iptal eder, onaylı seçim ve callback korunur',
      (tester) async {
        phone(tester);
        var saves = 0;
        await tester.pumpWidget(
          MyApp(
            home: ModyHomeView(
              initialSelection: const GenerateSelection(style: 'Klasik'),
              onApplied: (_) => saves++,
            ),
          ),
        );
        await tap(tester, 'Stil');
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(find.text('Custom Edit').hitTestable(), findsNothing);
        await tap(tester, 'SUV');
        switch (method) {
          case 'close':
            await tester.tap(find.byTooltip('Paneli kapat'));
          case 'back':
            await tester.binding.handlePopRoute();
          case 'outside':
            await tester.tapAt(const Offset(15, 120));
          case 'swipe':
            await tester.fling(
              find.byKey(const Key('selectionSheetHandle')),
              const Offset(0, 450),
              1500,
            );
        }
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing);
        expect(saves, 0);
        expect(
          tester.widget<Text>(find.byKey(const Key('selectionStil'))).data,
          'Klasik',
        );
        await tap(tester, 'Stil');
        expect(
          tester
              .widget<Semantics>(find.byKey(const Key('optionKlasik')))
              .properties
              .selected,
          isTrue,
        );
        await tap(tester, 'SUV');
        await tap(tester, 'Uygula');
        expect(saves, 1);
        expect(
          tester.widget<Text>(find.byKey(const Key('selectionStil'))).data,
          'SUV',
        );
      },
    );
  }

  testWidgets('Parça taslağı onaylı haritayı değiştirmez', (tester) async {
    phone(tester);
    var saves = 0;
    await tester.pumpWidget(
      MyApp(
        home: ModyHomeView(
          initialSelection: const GenerateSelection(
            angle: 'Rear',
            parts: {'Spoiler': 0},
          ),
          onApplied: (_) => saves++,
        ),
      ),
    );
    await tap(tester, 'Detail Edit');
    await tap(tester, 'Ayarla');
    await tester.tap(find.byKey(const ValueKey('partSpoiler1')));
    await tester.pumpAndSettle();
    await tester.fling(
      find.byKey(const Key('selectionSheetHandle')),
      const Offset(0, 450),
      1500,
    );
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Spoiler 1'), findsOneWidget);
    await tap(tester, 'Ayarla');
    expect(
      tester
          .widget<Semantics>(find.byKey(const ValueKey('partSpoiler0')))
          .properties
          .selected,
      isTrue,
    );
  });

  testWidgets(
    'Dar yükseklikte renk listesi kayar ve Uygula erişilebilir kalır',
    (tester) async {
      tester.view.physicalSize = const Size(320, 360);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  selected = await showSelectionSheet<String>(
                    context: context,
                    initialValue: '',
                    builder: (context, draft, change, apply) =>
                        ColorOptionsPanel(
                          selectedTitle: draft,
                          onSelected: (name, category) => change(name),
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
      await tap(tester, 'Aç');
      await tap(tester, 'Premium');
      await tester.drag(find.byType(ListView), const Offset(0, -240));
      await tester.pumpAndSettle();
      await tap(tester, 'Premium Gri');
      await tap(tester, 'Uygula');
      expect(selected, 'Premium Gri');
      expect(tester.takeException(), isNull);
    },
  );
}
