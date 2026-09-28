import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _tap(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Ortak başlıklar tema stilini kullanır', (tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    final context = tester.element(find.text('Mody AI'));
    final textTheme = Theme.of(context).textTheme;
    expect(
      tester.widget<Text>(find.text('Mody AI')).style,
      textTheme.titleLarge,
    );
    expect(
      tester.widget<Text>(find.text('Örnek Arabalar')).style,
      textTheme.titleMedium,
    );
    expect(textTheme.titleMedium?.fontWeight, FontWeight.bold);
  });

  testWidgets('Aynı sekmeye basmak açık paneli kapatır', (tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await _tap(tester, 'Renk');
    await _tap(tester, 'Metalik');
    await _tap(tester, 'Metalik');
    expect(find.text('Premium Kırmızı'), findsOneWidget);
    await _tap(tester, 'Style Builder');
    expect(find.text('Renk seçin'), findsNothing);
    expect(find.text('Stil'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Renk kategorileri iki modda da mock isimleri değiştirir', (
    tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    for (final mode in ['Style Builder', 'Detail Edit']) {
      await _tap(tester, mode);
      await _tap(tester, 'Renk');
      for (final name in ['Kırmızı', 'Mavi', 'Mor', 'Gri']) {
        expect(find.text(name), findsOneWidget);
      }
      await _tap(tester, 'Metalik');
      for (final name in ['Kırmızı', 'Mavi', 'Mor', 'Gri']) {
        expect(find.text('Premium $name'), findsOneWidget);
        expect(find.text(name), findsNothing);
      }
      await _tap(tester, 'Özel');
      for (final name in ['Kırmızı', 'Mavi', 'Mor', 'Gri']) {
        expect(find.text('Özel $name'), findsOneWidget);
        expect(find.text('Premium $name'), findsNothing);
      }
      await _tap(tester, 'Mat');
      expect(find.text('Kırmızı'), findsOneWidget);
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sekmeler aynı ekranın içeriğini günceller', (tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    expect(find.text('Mody AI'), findsOneWidget);
    expect(find.text('Stil'), findsOneWidget);
    await _tap(tester, 'Custom Edit');
    expect(find.text('Modifikasyonunuzu tanımlayın'), findsOneWidget);
    expect(find.text('Stil'), findsNothing);
    await _tap(tester, 'Detail Edit');
    expect(find.text('Açı'), findsOneWidget);
    expect(find.text('Ayarla'), findsOneWidget);
    await _tap(tester, 'Style Builder');
    expect(find.text('Stil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sayfalar kaydırılır ve Custom Edit metni korunur', (
    tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('Modifikasyonunuzu tanımlayın'), findsOneWidget);

    final descriptionField = find.byKey(
      const Key('customEditDescriptionField'),
    );
    await tester.enterText(descriptionField, 'Mat siyah sportif tasarım');
    expect(find.text('Mat siyah sportif tasarım'), findsOneWidget);

    await _tap(tester, 'Detail Edit');
    await _tap(tester, 'Custom Edit');
    expect(find.text('Mat siyah sportif tasarım'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Her iki modun panelleri açılıp kapatılır', (tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    for (final mode in ['Style Builder', 'Detail Edit']) {
      await _tap(tester, mode);
      final panels = mode == 'Style Builder'
          ? {
              'Stil': 'Stil seçin',
              'Ekstra': 'Ekstra seçin',
              'Renk': 'Renk seçin',
            }
          : {
              'Açı': 'Açı seçin',
              'Ayarla': 'Yapılandırma seçin',
              'Renk': 'Renk seçin',
            };
      for (final entry in panels.entries) {
        await _tap(tester, entry.key);
        expect(find.text(entry.value), findsOneWidget);
        await tester.tap(find.byTooltip('Paneli kapat'));
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsNothing);
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sekme değişince açık panel sıfırlanır', (tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await _tap(tester, 'Renk');
    expect(find.text('Kırmızı'), findsOneWidget);
    await _tap(tester, 'Custom Edit');
    expect(find.text('Renk seçin'), findsNothing);
    await _tap(tester, 'Style Builder');
    expect(find.text('Renk seçin'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
