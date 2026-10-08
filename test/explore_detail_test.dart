import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';

void main() {
  testWidgets('Explore kartı açılır, katalog resmi ve renk uygulanır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp(home: ExploreView()));
    Future<void> tap(String text) async {
      await tester.ensureVisible(find.text(text));
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    await tap('Change Color');
    expect(find.byType(ExploreDetailView), findsOneWidget);
    final sample = find.byTooltip('Örnek Araç 1');
    expect(tester.getSize(sample), const Size(72, 72));
    await tester.tap(sample);
    await tester.pumpAndSettle();
    expect(find.text('Uygula'), findsNothing);
    expect(
      find.bySemanticsLabel('Seçilen araç: Klasik Mustang'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('vehicleInput')));
    await tester.pumpAndSettle();
    expect(find.text('Galeri'), findsNothing);
    expect(find.text('Kamera'), findsNothing);
    await tap('Porsche 911');
    await tap('Uygula');
    expect(find.bySemanticsLabel('Seçilen araç: Porsche 911'), findsOneWidget);
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
    expect(find.text('Demo sonuç — AI ile üretilmedi'), findsOneWidget);
    await tap('Seçimlere Dön');
    await tester.tap(find.byTooltip('Explore’a dön'));
    await tester.pumpAndSettle();
    expect(find.text('Car Mods'), findsOneWidget);
    await tap('Customize Rims');
    expect(find.bySemanticsLabel('Seçilen araç: Porsche 911'), findsNothing);
    await tap('Rim');
    await tap('Çift Kollu Jant');
    await tap('Uygula');
    await tester.tap(find.byTooltip('Explore’a dön'));
    await tester.pumpAndSettle();
    await tap('Change Color');
    expect(find.bySemanticsLabel('Seçilen araç: Porsche 911'), findsOneWidget);
    expect(find.text('Premium Mavi'), findsOneWidget);
    await tester.tap(find.byKey(const Key('vehicleInput')));
    await tester.pumpAndSettle();
    await tap('Klasik Mustang');
    await tester.tap(find.byTooltip('Paneli kapat'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Seçilen araç: Porsche 911'), findsOneWidget);
    await tester.tap(find.byKey(const Key('vehicleInput')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Semantics>(
            find
                .ancestor(
                  of: find.byKey(const Key('vehicle-porsche_911')),
                  matching: find.byType(Semantics),
                )
                .first,
          )
          .properties
          .selected,
      isTrue,
    );
    await tester.tap(find.byTooltip('Paneli kapat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Explore’a dön'));
    await tester.pumpAndSettle();
    await tap('Customize Rims');
    expect(
      find.bySemanticsLabel('Seçilen modifikasyon: Çift Kollu Jant'),
      findsOneWidget,
    );
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
        await tester.tap(find.text(CarModCatalog.groups[title]![1].label));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(
            'Seçilen modifikasyon: ${CarModCatalog.groups[title]![1].label}',
          ),
          findsOneWidget,
        );
      } else {
        expect(find.text('Renk'), findsNothing);
      }
      await tester.tap(find.text('Resim Seçin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Klasik Mustang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Seçilen araç: Klasik Mustang'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
