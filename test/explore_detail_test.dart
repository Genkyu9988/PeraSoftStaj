import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/demos/explore_view.dart';
import 'package:perasoft_staj/demos/explore_detail_view.dart';

void main() {
  testWidgets('Explore kartı açılır, mock resim ve renk uygulanır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp(home: ExploreView()));
    Future<void> tap(String text) async {
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    await tap('Change Color');
    expect(find.byType(ExploreDetailView), findsOneWidget);
    final sample = find.byTooltip('Örnek Araç 1');
    expect(tester.getSize(sample), const Size(72, 72));
    await tester.tap(sample);
    await tester.pumpAndSettle();
    await tap('Uygula');
    expect(find.text('Örnek Araç 1'), findsOneWidget);
    await tap('Resim Seçin');
    expect(find.text('Galeri'), findsNothing);
    expect(find.text('Kamera'), findsNothing);
    await tap('Your Creations');
    await tap('Mock Üretim 2');
    await tap('Uygula');
    expect(find.text('Mock Üretim 2'), findsOneWidget);
    await tap('Renk');
    await tap('Premium');
    await tap('Premium Mavi');
    await tap('Uygula');
    expect(find.text('Premium Mavi'), findsOneWidget);
    await tap('Renk');
    await tap('Mat');
    await tap('Kırmızı');
    await tester.tap(find.byTooltip('Paneli kapat'));
    await tester.pumpAndSettle();
    expect(find.text('Premium Mavi'), findsOneWidget);
    await tap('Arabamı Modifiye Et');
    expect(
      find.text('Bu bir mock önizlemedir; gerçek görsel üretilmez.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Explore’a dön'));
    await tester.pumpAndSettle();
    expect(find.text('Car Mods'), findsOneWidget);
    await tap('Customize Rims');
    expect(find.text('Mock Üretim 2'), findsNothing);
    await tap('Rim');
    await tap('Rim 3');
    await tap('Uygula');
    await tester.tap(find.byTooltip('Explore’a dön'));
    await tester.pumpAndSettle();
    await tap('Change Color');
    expect(find.text('Mock Üretim 2'), findsOneWidget);
    expect(find.text('Premium Mavi'), findsOneWidget);
    await tap('Resim Seçin');
    await tap('Mock Üretim 1');
    await tester.tap(find.byTooltip('Paneli kapat'));
    await tester.pumpAndSettle();
    expect(find.text('Mock Üretim 2'), findsOneWidget);
    await tap('Resim Seçin');
    expect(find.text('Seçilen: Mock Üretim 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Paneli kapat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Explore’a dön'));
    await tester.pumpAndSettle();
    await tap('Customize Rims');
    expect(find.text('Rim 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final title in [
    'Customize Rims',
    'Suspension',
    'Neons',
    'Tire',
    'American',
    'Most WT',
    'Car Enhance',
  ]) {
    testWidgets('$title doğru seçenek panelini kullanır', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final labels = {
        'Customize Rims': 'Rim',
        'Suspension': 'Suspension',
        'Neons': 'Neon',
        'Tire': 'Tire',
      };
      final label = labels[title];
      await tester.pumpWidget(
        MyApp(
          home: ExploreDetailView(
            title: title,
            isCarMod: label != null,
            onBack: () {},
          ),
        ),
      );
      if (label != null) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('$label 2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        expect(find.text('$label 2'), findsOneWidget);
      } else {
        expect(find.text('Renk'), findsNothing);
      }
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mock Araç 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      expect(find.text('Mock Araç 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
