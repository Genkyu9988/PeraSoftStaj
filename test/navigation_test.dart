import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/demos/main_tabs_view.dart';
import 'package:perasoft_staj/product/mody_bottom_bar.dart';

void main() {
  for (final width in [390.0, 320.0]) {
    testWidgets('Ana sekmeler ve gerçek geri dönüş seçimleri korur: $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      Future<void> tap(String text) async {
        await tester.tap(find.text(text).hitTestable());
        await tester.pumpAndSettle();
      }

      Future<void> back() async {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      await tap('Stil');
      await tap('Klasik');
      await tap('Uygula');
      await tap('Custom Edit');
      await tester.enterText(
        find.byKey(const Key('customEditDescriptionField')),
        'Mock tasarım',
      );
      tester.testTextInput.hide();
      await tap('Explore');
      expect(find.byType(ModyBottomBar), findsOneWidget);
      await tap('Change Color');
      expect(find.byType(ModyBottomBar), findsNothing);
      await tap('Resim Seçin');
      await tap('Mock Araç 1');
      await tap('Uygula');
      await tap('Renk');
      await tap('Premium');
      await tap('Premium Mavi');
      await tap('Uygula');
      await tap('Renk');
      await tap('Mat');
      await tap('Kırmızı');
      await back();
      expect(find.text('Renk seçin'), findsNothing);
      expect(find.text('Premium Mavi'), findsOneWidget);
      await back();
      expect(find.text('Car Mods'), findsOneWidget);
      await tap('AI Video');
      await tap('Apex Transform');
      await tap('Resim Seçin');
      await tap('Your Creations');
      await tap('Mock Üretim 2');
      await tap('Uygula');
      await back();
      await tap('Garaj');
      await tester.tap(find.byKey(const Key('garageTabVideolar')));
      await tester.pumpAndSettle();
      await tap('Üret');
      expect(find.text('Mock tasarım'), findsOneWidget);
      await tap('Style Builder');
      expect(find.text('Klasik'), findsOneWidget);
      await tap('Stil');
      await tap('Sportif');
      await back();
      expect(find.text('Stil seçin'), findsNothing);
      expect(find.text('Klasik'), findsOneWidget);
      await tap('Stil');
      expect(find.text('Explore').hitTestable(), findsNothing);
      await back();
      await tap('Explore');
      await tap('Change Color');
      expect(find.text('Mock Araç 1'), findsOneWidget);
      expect(find.text('Premium Mavi'), findsOneWidget);
      await back();
      await tap('AI Video');
      await tap('Apex Transform');
      expect(find.text('Mock Üretim 2'), findsOneWidget);
      await back();
      await tap('Garaj');
      expect(find.text('Herhangi bir video üretmediniz'), findsOneWidget);
      await tap('Üret');
      expect(find.text('Stil seçin'), findsNothing);
      expect(find.text('Klasik'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Alternatif giriş sekmesinden de bütün bölümler açılır', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(home: MainTabsView(initialTab: MainTab.aiVideo)),
    );
    expect(
      tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).selectedIndex,
      2,
    );
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Car Mods'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
