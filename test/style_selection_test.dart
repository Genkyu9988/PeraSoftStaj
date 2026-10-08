import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';

Future<void> tapText(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> closePanel(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Paneli kapat'));
  await tester.pumpAndSettle();
}

bool selected(WidgetTester tester, String key) {
  return tester.widget<Semantics>(find.byKey(Key(key))).properties.selected ==
      true;
}

void main() {
  testWidgets('Stil, Ekstra ve Renk yalnızca Uygula ile kaydedilir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    await tapText(tester, 'Stil');
    await tapText(tester, 'Sportif');
    expect(selected(tester, 'optionSportif'), isTrue);
    expect(find.text('Uygula'), findsOneWidget);
    final card = find
        .ancestor(of: find.text('Sportif'), matching: find.byType(Container))
        .first;
    expect(tester.getSize(card).width, greaterThan(100));
    await closePanel(tester);
    expect(find.byKey(const Key('selectionStil')), findsNothing);
    await tapText(tester, 'Stil');
    expect(selected(tester, 'optionSportif'), isFalse);
    await tapText(tester, 'SUV');
    expect(selected(tester, 'optionSportif'), isFalse);
    await tapText(tester, 'Uygula');
    expect(find.text('Stil'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('selectionStil'))).data,
      'SUV',
    );
    await tapText(tester, 'Stil');
    expect(selected(tester, 'optionSUV'), isTrue);
    await tapText(tester, 'Yarış');
    await closePanel(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('selectionStil'))).data,
      'SUV',
    );

    await tapText(tester, 'Ekstra');
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tapText(tester, 'Jant');
    await closePanel(tester);
    await tapText(tester, 'Ekstra');
    expect(selected(tester, 'optionJant'), isFalse);
    await tapText(tester, 'Boya');
    await tapText(tester, 'Uygula');
    expect(find.text('Ekstra seçin'), findsNothing);
    expect(find.text('Ekstra'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('selectionEkstra'))).data,
      'Boya',
    );
    await tapText(tester, 'Ekstra');
    expect(selected(tester, 'optionBoya'), isTrue);
    await tapText(tester, 'Neon');
    await closePanel(tester);
    await tapText(tester, 'Ekstra');
    expect(selected(tester, 'optionBoya'), isTrue);
    expect(selected(tester, 'optionNeon'), isFalse);
    await closePanel(tester);

    await tapText(tester, 'Renk');
    await tapText(tester, 'Premium');
    await tapText(tester, 'Premium Mavi');
    expect(selected(tester, 'colorPremium Mavi'), isTrue);
    expect(find.text('Uygula'), findsOneWidget);
    await closePanel(tester);
    await tapText(tester, 'Renk');
    expect(selected(tester, 'colorMavi'), isFalse);
    await tapText(tester, 'Premium');
    expect(selected(tester, 'colorPremium Mavi'), isFalse);
    await tapText(tester, 'Premium Mavi');
    await tapText(tester, 'Uygula');
    await tapText(tester, 'Renk');
    expect(selected(tester, 'colorPremium Mavi'), isTrue);
    await tapText(tester, 'Mat');
    expect(selected(tester, 'colorMavi'), isFalse);
    await tapText(tester, 'Özel');
    await tapText(tester, 'Özel Mor');
    await closePanel(tester);
    expect(find.text('Renk'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('selectionRenk'))).data,
      'Premium Mavi',
    );

    await tapText(tester, 'Detail Edit');
    await tapText(tester, 'Açı');
    await tapText(tester, 'Front');
    await tapText(tester, 'Uygula');
    await tapText(tester, 'Renk');
    expect(selected(tester, 'colorMor'), isFalse);
    await closePanel(tester);
    await tapText(tester, 'Style Builder');
    await tapText(tester, 'Stil');
    expect(selected(tester, 'optionSUV'), isTrue);
    await closePanel(tester);
    await tapText(tester, 'Ekstra');
    expect(selected(tester, 'optionBoya'), isTrue);
    await closePanel(tester);
    await tapText(tester, 'Renk');
    expect(selected(tester, 'colorPremium Mavi'), isTrue);
    expect(tester.takeException(), isNull);
  });
}
