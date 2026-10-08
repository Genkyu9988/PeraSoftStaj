import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/garage/view/garage_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/feature/garage/data/garage_items.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(320, 640)]) {
    testWidgets('Garaj sekmeleri, kaydırma ve mock profil: $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp(home: GarageView()));
      expect(find.byType(Image), findsNothing);
      expect(find.text(GarageItems.count), findsNWidgets(2));
      expect(find.byKey(const Key('garageAvatar')), findsOneWidget);
      expect(
        tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).selectedIndex,
        3,
      );
      for (final title in [
        GarageItems.videos,
        GarageItems.modys,
        GarageItems.all,
      ]) {
        await tester.tap(find.byKey(Key('garageTab$title')));
        await tester.pumpAndSettle();
        final line = tester.widget<Container>(
          find.byKey(Key('garageUnderline$title')),
        );
        expect(
          (line.decoration! as BoxDecoration).color,
          ColorItems.primaryText,
        );
        expect(
          find.text(
            title == GarageItems.videos
                ? GarageItems.emptyVideos
                : GarageItems.emptyImages,
          ),
          findsOneWidget,
        );
      }
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      final line = tester.widget<Container>(
        find.byKey(const Key("garageUnderlineMody's")),
      );
      expect((line.decoration! as BoxDecoration).color, ColorItems.primaryText);
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text(GarageItems.emptyVideos), findsOneWidget);
      expect(find.text('Get All Access'), findsNothing);
      expect(
        tester
            .widgetList<Container>(find.byType(Container))
            .where(
              (container) =>
                  container.decoration is BoxDecoration &&
                  (container.decoration! as BoxDecoration).gradient != null,
            ),
        isEmpty,
      );
      expect(find.byType(TextButton), findsNWidgets(3));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }
}
