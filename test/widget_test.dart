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
