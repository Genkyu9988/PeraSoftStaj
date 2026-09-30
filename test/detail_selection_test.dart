import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';

void main() {
  testWidgets('Detail seçimleri uygulanır, iptal edilir ve bağımsız korunur', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    Future<void> tap(String text) async {
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    Future<void> close() async {
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
    }

    String? summary(String title) =>
        tester.widget<Text>(find.byKey(ValueKey('selection$title'))).data;
    bool selected(String key) =>
        tester
            .widget<Semantics>(find.byKey(ValueKey(key)))
            .properties
            .selected ==
        true;

    await tap('Detail Edit');
    await tap('Açı');
    for (final angle in ['Front', 'Rear', 'Side']) {
      expect(find.text(angle), findsOneWidget);
    }
    await tap('Front');
    await close();
    expect(find.byKey(const ValueKey('selectionAçı')), findsNothing);
    await tap('Açı');
    expect(selected('optionFront'), isFalse);
    await tap('Rear');
    await tap('Uygula');
    expect(summary('Açı'), 'Rear');

    await tap('Ayarla');
    await tester.tap(find.byKey(const ValueKey('partSpoiler0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('partExhaust1')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('Rear Bumper & Diffuser'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('partTail Lights2')));
    await tester.pumpAndSettle();
    await tap('Uygula');
    expect(summary('Ayarla'), 'Spoiler 1, Exhaust 2, Tail Lights 3');
    await tap('Ayarla');
    expect(selected('partSpoiler0'), isTrue);
    expect(selected('partExhaust1'), isTrue);
    await tester.tap(find.byKey(const ValueKey('partSpoiler1')));
    await tester.pumpAndSettle();
    await close();
    await tap('Ayarla');
    expect(selected('partSpoiler0'), isTrue);
    expect(selected('partSpoiler1'), isFalse);
    await close();

    await tap('Renk');
    await tap('Özel');
    await tap('Özel Mor');
    await tap('Uygula');
    expect(summary('Renk'), 'Özel Mor');
    await tap('Style Builder');
    expect(find.byKey(const ValueKey('selectionRenk')), findsNothing);
    await tap('Renk');
    await tap('Mavi');
    await tap('Uygula');
    expect(summary('Renk'), 'Mavi');
    await tap('Detail Edit');
    expect(summary('Renk'), 'Özel Mor');
    expect(summary('Açı'), 'Rear');
    await tap('Renk');
    expect(selected('colorÖzel Mor'), isTrue);
    await tap('Mat');
    await tap('Gri');
    await close();
    expect(summary('Renk'), 'Özel Mor');
    expect(tester.takeException(), isNull);
  });
}
