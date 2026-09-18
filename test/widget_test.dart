import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('Mody ana ekranı doğru içerikle görünür', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(const MyApp());

    expect(find.text('Mody AI'), findsOneWidget);
    expect(find.text('Style Builder'), findsOneWidget);
    expect(find.text('Araç Fotoğrafı Yüklemek İçin Dokunun'), findsOneWidget);
    expect(find.text('Örnek Arabalar'), findsOneWidget);
    expect(find.text('Arabamı Modifiye Et'), findsOneWidget);
    expect(find.text('Üret'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ekranda tıklanabilir bir buton bulunmaz', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(const MyApp(contentIndex: 0));

    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('Custom Edit içeriği statik olarak görünür', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(const MyApp(contentIndex: 1));

    expect(find.text('Modifikasyonunuzu tanımlayın'), findsOneWidget);
    expect(find.textContaining('Spor görünümlü'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail Edit içeriği aynı tasarım diliyle görünür', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(const MyApp(contentIndex: 2));

    expect(find.text('Açı'), findsOneWidget);
    expect(find.text('Ayarla'), findsOneWidget);
    expect(find.text('Canlı\nEdit'), findsOneWidget);
    expect(find.text('Örnek Arabalar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mock seçenek panelleri statik olarak görünür', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(const MyApp(contentIndex: 0, panelIndex: 1));
    expect(find.text('Stil seçin'), findsOneWidget);
    expect(find.text('Klasik'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MyApp(contentIndex: 0, panelIndex: 2));
    expect(find.text('Ekstra seçin'), findsOneWidget);
    expect(find.text('Jant'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MyApp(contentIndex: 0, panelIndex: 3));
    expect(find.text('Renk seçin'), findsOneWidget);
    expect(find.text('Kırmızı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail Edit mock panelleri statik olarak görünür', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(const MyApp(contentIndex: 2, panelIndex: 1));
    expect(find.text('Açı seçin'), findsOneWidget);
    expect(find.text('Ön Görünüm'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MyApp(contentIndex: 2, panelIndex: 2));
    expect(find.text('Yapılandırma seçin'), findsOneWidget);
    expect(find.text('Spoiler'), findsOneWidget);
    expect(find.text('Egzoz'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MyApp(contentIndex: 2, panelIndex: 3));
    expect(find.text('Renk seçin'), findsOneWidget);
    expect(find.text('Kırmızı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
